//
//  EmailVC.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/11.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseAuth

class EmailVC: UIViewController {
    
    @IBOutlet weak var accountTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signInOrSignOutBtn: UIButton!
    @IBOutlet weak var showPasswordBtn: UIButton!
    
    var isSignIn: Bool = false
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomFunc.customAlert(title: "", message: "如果尚未註冊過帳號的話，請點擊左側的「註冊帳號」按鈕進行註冊\n\n已經註冊過帳號的話，請點擊右側的「帳號登入」按鈕進行登入", vc: self, actionHandler: nil)
    }
    
    // MARK: - 加入 Firebase 帳號狀態監聽
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if (user != nil) {
                if (self.isSignIn) {
                    print("目前已有使用者登入！")
                    self.signInOrSignOutBtn.setTitle("帳號登出", for: .normal)
                    self.passwordTF.isEnabled = false
                } else {
                    self.signInOrSignOutBtn.setTitle("帳號登入", for: .normal)
                    self.passwordTF.isEnabled = true
                }
            } else {
                // 目前尚無用戶登入
                print("目前尚無用戶登入！")
            }
        }
    }
    
    // MARK: - 移除 Firebase 帳號狀態監聽
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Firebase 註冊帳號
    @IBAction func registerAccount(_ sender: UIButton) {
        if (accountTF.text == "") {
            CustomFunc.customAlert(title: "", message: "請輸入帳號！", vc: self, actionHandler: nil)
        } else {
            Auth.auth().createUser(withEmail:accountTF.text!, password: passwordTF.text!) { (user, error) in
                if (error == nil) {
                    CustomFunc.customAlert(title: "", message: "帳號已成功建立！", vc: self, actionHandler: nil)
                } else {
                    CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
                }
            }
        }
    }
    
    // MARK: - Firebase 帳號登入／登出
    @IBAction func accountSignInOrSignOut(_ sender: UIButton) {
        if (Auth.auth().currentUser == nil || !isSignIn) {
            // 無用戶登入
            if (accountTF.text == "" || passwordTF.text == "") {
                CustomFunc.customAlert(title: "", message: "請重新輸入帳號密碼！", vc: self, actionHandler: nil)
            } else {
                Auth.auth().signIn(withEmail:accountTF.text!, password: passwordTF.text!) { (user, error) in
                    guard error == nil else {
                        CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
                        return
                    }
                    CustomFunc.customAlert(title: "", message: "登入成功！", vc: self, actionHandler: self.getFirebaseUserInfo)
                    self.cleanTextField()
                    self.isSignIn = true
                    self.signInOrSignOutBtn.setTitle("帳號登出", for: .normal)
                }
            }
        } else {
            // 有用戶登入
            do {
                try Auth.auth().signOut()
                CustomFunc.customAlert(title: "", message: "登出成功！", vc: self, actionHandler: nil)
                self.cleanTextField()
                self.isSignIn = false
                self.signInOrSignOutBtn.setTitle("帳號登入", for: .normal)
            } catch let error as NSError {
                CustomFunc.customAlert(title: "", message: "\(String(describing: error.localizedDescription))", vc: self, actionHandler: nil)
            }
        }
    }
    
    // MARK: - Firebase 密碼重設
    @IBAction func resetPassword(_ sender: UIButton) {
        if (accountTF.text == "") {
            CustomFunc.customAlert(title: "", message: "請輸入要重設密碼的 Email！", vc: self, actionHandler: nil)
        } else {
            Auth.auth().sendPasswordReset(withEmail: accountTF.text!, completion: { (error) in
                guard error == nil else {
                    CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
                    return
                }
                CustomFunc.customAlert(title: "", message: "重設密碼的連結已寄到信箱內，請點擊信中的連結進行密碼重設！", vc: self, actionHandler: nil)
            })
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
        CustomFunc.customAlert(title: "使用者資訊", message: "UID：\(uid)\nEmail：\(email!)", vc: self, actionHandler: nil)
    }
    
    // MARK: - 顯示／關閉密碼的黑點
    @IBAction func showPassword(_ sender: UIButton) {
        if (passwordTF.isSecureTextEntry) {
            passwordTF.isSecureTextEntry = false
            showPasswordBtn.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            passwordTF.isSecureTextEntry = true
            showPasswordBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    // MARK: - 其他 Function
    func cleanTextField() {
        self.accountTF.text = ""
        self.passwordTF.text = ""
    }
    
}
