//
//  SignInWithGoogleVC.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/11.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class SignInWithGoogleVC: UIViewController {
    
    @IBOutlet weak var signInWithGoogleBtn: GIDSignInButton!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var linkToOtherAccountBtn: UIButton!
    
    var isSignIn: Bool = false
    var isLink: Bool = false
    let idToken = GIDSignIn.sharedInstance.currentUser?.authentication.idToken
    let accessToken = GIDSignIn.sharedInstance.currentUser?.authentication.accessToken
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signOutBtnInit(enable: false, hidden: true)
        self.linkToAccountBtnInit(enable: false, hidden: true)
        self.signInWithGoogleBtn.style = .wide
    }
    
    // MARK: - 加入 Firebase 帳號狀態監聽
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let idToken = idToken {
            CustomFunc.customAlert(title: "帳號已登入過！", message: "", vc: self, actionHandler: self.getFirebaseUserInfo)
            self.signInWithGoogleBtnInit(enable: false)
            self.signOutBtnInit(enable: true, hidden: false)
            self.isSignIn = true
        } else {
            // 目前尚無用戶登入
            print("目前尚無用戶登入！")
        }
    }
    
    // MARK: - 帳號登入／登出功能
    @IBAction func signInWithGoogle(_ sender: Any) {
        self.signInWithGoogle()
    }
    
    @IBAction func googleAccountSignOut(_ sender: UIButton) {
        self.googleAccountSignOut()
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
    func signOutBtnInit(enable: Bool, hidden: Bool) {
        self.signOutBtn.isEnabled = enable
        self.signOutBtn.isHidden = hidden
    }
    
    func signInWithGoogleBtnInit(enable: Bool) {
        self.signInWithGoogleBtn.isEnabled = enable
    }
    
    func linkToAccountBtnInit(enable: Bool, hidden: Bool) {
        self.linkToOtherAccountBtn.isEnabled = enable
        self.linkToOtherAccountBtn.isHidden = hidden
    }

}

extension SignInWithGoogleVC {
    // MARK: - Firebase Sign in with Google
    // 登入帳號
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID) // 創建 Google Sign In Config 物件
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            guard error == nil else {
                CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
                return
            }
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            self.firebaseSignInWithGoogle(credential: credential)
        }
    }
    
    func firebaseSignInWithGoogle(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil else {
                CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
                return
            }
            CustomFunc.customAlert(title: "", message: "登入成功！", vc: self, actionHandler: self.getFirebaseUserInfo)
            self.signOutBtnInit(enable: true, hidden: false)
            self.signInWithGoogleBtnInit(enable: false)
        }
    }
    
    // 登出帳號
    func googleAccountSignOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            CustomFunc.customAlert(title: "", message: "帳號已登出！", vc: self, actionHandler: nil)
            self.isSignIn = false
            self.signOutBtnInit(enable: false, hidden: true)
            self.signInWithGoogleBtnInit(enable: true)
        } catch let error as NSError {
            CustomFunc.customAlert(title: "", message: "\(String(describing: error.localizedDescription))", vc: self, actionHandler: nil)
        }
    }
    
    // MARK: - Firebase Link To Other OAuth2.0
    // 與其他登入方式進行連結
    func linkToOtherOAuth() {
        print("點擊與其他帳號進行連結按鈕")
        let googleCredential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: accessToken!)
        if let user = Auth.auth().currentUser {
            user.link(with: googleCredential) { authResult, error in
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
