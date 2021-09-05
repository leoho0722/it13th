//
//  SignInWithFacebookVC.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/13.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class SignInWithFacebookVC: UIViewController {
    
    @IBOutlet weak var signInWithFacebookBtn: UIButton!
    @IBOutlet weak var linkToOtherAccountBtn: UIButton!
    
    var isSignIn: Bool = false
    var isLink: Bool = false
    let loginManager = LoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.linkToAccountBtnInit(enable: false, hidden: true)
    }
    
    // MARK: - 加入 Firebase 帳號狀態監聽
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let token = AccessToken.current, !token.isExpired {
            CustomFunc.customAlert(title: "帳號已登入過！", message: "", vc: self, actionHandler: self.getFirebaseUserInfo)
            self.signInWithFacebookBtn.setTitle("Sign Out", for: .normal)
            self.isSignIn = true
        } else {
            // 目前尚無用戶登入
            print("目前尚無用戶登入！")
        }
    }
    
    // MARK: - 帳號登入／登出功能
    @IBAction func signInWithFacebook(sender: UIButton) {
        if (self.isSignIn) {
            self.facebookAccountSignOut()
        } else {
            self.signInWithFacebook()
        }
    }
    
    @IBAction func linkToAccount(_ sender: UIButton) {
        if (isLink) {
            // 已經將帳號與其他登入方式連結
            self.unlinkToOtherOAuth()
        } else {
            // 尚未將帳號與其他登入方式連結
            self.linkToOtherOAuth()
        }
    }

    // MARK: - Button 狀態初始化設定
    func linkToAccountBtnInit(enable: Bool, hidden: Bool) {
        self.linkToOtherAccountBtn.isEnabled = enable
        self.linkToOtherAccountBtn.isHidden = hidden
    }
}

extension SignInWithFacebookVC {
    // MARK: - Firebase Sign in with Facebook
    // 登入帳號
    func signInWithFacebook() {
        loginManager.logIn(permissions: ["email"], from: self) { loginResult, error in
            guard error == nil else {
                CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
                return
            }
            guard ((loginResult?.isCancelled) != nil) else {
                CustomFunc.customAlert(title: "", message: "Facebook 登入失敗！", vc: self, actionHandler: nil)
                return
            }
            guard let accessToken = AccessToken.current else {
                CustomFunc.customAlert(title: "", message: "無法取得 AccessToken！", vc: self, actionHandler: nil)
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            self.firebaseSignInWithFacebook(credential: credential)
        }
    }
    
    func firebaseSignInWithFacebook(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil else {
                CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
                print("\(String(describing: error!.localizedDescription))")
                return
            }
            CustomFunc.customAlert(title: "登入成功！", message: "", vc: self, actionHandler: self.getFirebaseUserInfo)
            self.signInWithFacebookBtn.setTitle("Facebook Account Sign Out", for: .normal)
            self.isSignIn = true
        }
    }
    
    // 登出帳號
    func facebookAccountSignOut() {
        do {
            try Auth.auth().signOut()
            loginManager.logOut()
            CustomFunc.customAlert(title: "帳號已登出！", message: "", vc: self, actionHandler: nil)
            self.signInWithFacebookBtn.setTitle("Connect with Facebook", for: .normal)
            self.isSignIn = false
        } catch let error as NSError {
            CustomFunc.customAlert(title: "", message: "\(String(describing: error.localizedDescription))", vc: self, actionHandler: nil)
        }
    }
    
    // MARK: - Firebase Link To Other OAuth2.0
    // 與其他登入方式進行連結
    func linkToOtherOAuth() {
        print("點擊與其他帳號進行連結按鈕")
        let fbCredential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        if let user = Auth.auth().currentUser {
            user.link(with: fbCredential) { authResult, error in
                if let error = error {
                    CustomFunc.customAlert(title: "", message: "\(String(describing: error.localizedDescription))", vc: self, actionHandler: nil)
                    return
                }
                CustomFunc.customAlert(title: "與其他登入方式的帳號連結成功！", message: "", vc: self, actionHandler: nil)
                self.isLink = true
                self.linkToOtherAccountBtn.setTitle("取消連結", for: .normal)
            }
        }
    }
    
    // 取消與其他登入方式進行連結
    func unlinkToOtherOAuth() {
        print("點擊取消與其他帳號進行連結按鈕")
        let providerID = Auth.auth().currentUser?.providerID
        Auth.auth().currentUser?.unlink(fromProvider: providerID!) { user, error in
            if let error = error {
                CustomFunc.customAlert(title: "", message: "\(String(describing: error.localizedDescription))", vc: self, actionHandler: nil)
                return
            }
            CustomFunc.customAlert(title: "已取消與其他登入方式的帳號連結！", message: "", vc: self, actionHandler: nil)
            self.isLink = false
            self.linkToOtherAccountBtn.setTitle("與其他帳號進行連結", for: .normal)
        }
    }
    
    // MARK: - Firebase 取得登入使用者的資訊
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            CustomFunc.customAlert(title: "使用者資訊", message: "無法取得使用者資料", vc: self, actionHandler: nil)
            return
        }
        let uid = user.uid
        let email = user.email
        let name = user.displayName
        CustomFunc.customAlert(title: "使用者資訊", message: "User Name：\(name!)\nUID：\(uid)\nEmail：\(email!)", vc: self, actionHandler: nil)
    }
}
