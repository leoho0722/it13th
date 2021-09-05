//
//  SignInWithAppleVC.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/11.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class SignInWithAppleVC: UIViewController {
    
    var appleUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSignInWithAppleBtn()
        self.observeAppleIDState()
        self.checkAppleIDCredentialState(userID: appleUserID ?? "")
    }
    
    // MARK: - 監聽目前的 Apple ID 的登入狀況
    // 主動監聽
    func checkAppleIDCredentialState(userID: String) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { credentialState, error in
            switch credentialState {
            case .authorized:
                CustomFunc.customAlert(title: "使用者已授權！", message: "", vc: self, actionHandler: nil)
            // 進入主畫面
            case .revoked:
                CustomFunc.customAlert(title: "使用者憑證已被註銷，請重新使用 Apple ID 登入！", message: "請到\n「設定 → Apple ID → 密碼與安全性 → 使用 Apple ID 的 App」\n將此 App 停止使用 Apple ID\n並再次使用 Apple ID 登入本 App！", vc: self, actionHandler: nil)
            //
            case .notFound:
                CustomFunc.customAlert(title: "", message: "使用者尚未使用過 Apple ID 登入！", vc: self, actionHandler: nil)
            // 跳轉到登入畫面
            case .transferred:
                CustomFunc.customAlert(title: "請與開發者團隊進行聯繫，以利進行使用者遷移！", message: "", vc: self, actionHandler: nil)
            default:
                break
            }
        }
    }
    
    // 被動監聽 (使用 Apple ID 登入或登出都會觸發)
    func observeAppleIDState() {
        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { (notification: Notification) in
            CustomFunc.customAlert(title: "使用者登入或登出", message: "", vc: self, actionHandler: nil)
        }
    }
    
    // MARK: - 在畫面上產生 Sign in with Apple 按鈕
    func setSignInWithAppleBtn() {
        let signInWithAppleBtn = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: chooseAppleButtonStyle())
        view.addSubview(signInWithAppleBtn)
        signInWithAppleBtn.cornerRadius = 25
        signInWithAppleBtn.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        signInWithAppleBtn.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signInWithAppleBtn.widthAnchor.constraint(equalToConstant: 280).isActive = true
        signInWithAppleBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInWithAppleBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
    }
    
    func chooseAppleButtonStyle() -> ASAuthorizationAppleIDButton.Style {
        return (UITraitCollection.current.userInterfaceStyle == .light) ? .black : .white // 淺色模式就顯示黑色的按鈕，深色模式就顯示白色的按鈕
    }
    
    // MARK: - Sign in with Apple 登入
    fileprivate var currentNonce: String?
    
    @objc func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while(remainingLength > 0) {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if (errorCode != errSecSuccess) {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if (remainingLength == 0) {
                    return
                }
                
                if (random < charset.count) {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

extension SignInWithAppleVC {
    // MARK: - 透過 Credential 與 Firebase Auth 串接
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil else {
                CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
                return
            }
            CustomFunc.customAlert(title: "登入成功！", message: "", vc: self, actionHandler: self.getFirebaseUserInfo)
        }
        //        if let user = Auth.auth().currentUser {
        //            user.link(with: credential) { authResult, error in
        //                if let error = error {
        //                    CustomFunc.customAlert(title: "", message: "\(String(describing: error.localizedDescription))", vc: self, actionHandler: nil)
        //                    return
        //                }
        //                CustomFunc.customAlert(title: "與其他登入方式的帳號連結成功！", message: "", vc: self, actionHandler: nil)
        //            }
        //        } else {
        //            Auth.auth().signIn(with: credential) { authResult, error in
        //                guard error == nil else {
        //                    CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
        //                    return
        //                }
        //                CustomFunc.customAlert(title: "登入成功！", message: "", vc: self, actionHandler: self.getFirebaseUserInfo)
        //            }
        //        }
    }
    
    // MARK: - Firebase Link To Other OAuth2.0
    // 與其他登入方式進行連結
    //        func linkToOtherOAuth() {
    //            print("點擊與其他帳號進行連結按鈕")
    //            if let user = Auth.auth().currentUser {
    //                user.link(with: credential) { authResult, error in
    //                    if let error = error {
    //                        CustomFunc.customAlert(title: "", message: "\(String(describing: error.localizedDescription))", vc: self, actionHandler: nil)
    //                        return
    //                    }
    //                    CustomFunc.customAlert(title: "與其他登入方式的帳號連結成功！", message: "", vc: self, actionHandler: nil)
    //                }
    //            }
    //        }
    //
    //        // 取消與其他登入方式進行連結
    //        func unlinkToOtherOAuth() {
    //            print("點擊取消與其他帳號進行連結按鈕")
    //            let providerID = Auth.auth().currentUser?.providerID
    //            Auth.auth().currentUser?.unlink(fromProvider: providerID!) { user, error in
    //                if let error = error {
    //                    CustomFunc.customAlert(title: "", message: "\(String(describing: error.localizedDescription))", vc: self, actionHandler: nil)
    //                    return
    //                }
    //                CustomFunc.customAlert(title: "已取消與其他登入方式的帳號連結！", message: "", vc: self, actionHandler: nil)
    //            }
    //        }
    
    // MARK: - Firebase 取得登入使用者的資訊
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            CustomFunc.customAlert(title: "無法取得使用者資料！", message: "", vc: self, actionHandler: nil)
            return
        }
        let uid = user.uid
        let email = user.email
        CustomFunc.customAlert(title: "使用者資訊", message: "UID：\(uid)\nEmail：\(email!)", vc: self, actionHandler: nil)
    }
}

// MARK: - ASAuthorizationControllerDelegate
// 用來處理授權登入成功或是失敗
extension SignInWithAppleVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 登入成功
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                CustomFunc.customAlert(title: "Unable to fetch identity token", message: "", vc: self, actionHandler: nil)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                CustomFunc.customAlert(title: "Unable to serialize token string from data", message: "\(appleIDToken.debugDescription)", vc: self, actionHandler: nil)
                return
            }
            print("User：\(appleIDCredential.user)")
            self.appleUserID = appleIDCredential.user
            print("Apple UserID：\(appleUserID!)")
            // 產生 Apple ID 登入的 Credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // 與 Firebase Auth 進行串接
            firebaseSignInWithApple(credential: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登入失敗，處理 Error
        switch error {
        case ASAuthorizationError.canceled:
            CustomFunc.customAlert(title: "使用者取消登入", message: "", vc: self, actionHandler: nil)
            print("使用者取消登入")
            break
        case ASAuthorizationError.failed:
            CustomFunc.customAlert(title: "授權請求失敗", message: "", vc: self, actionHandler: nil)
            print("授權請求失敗")
            break
        case ASAuthorizationError.invalidResponse:
            CustomFunc.customAlert(title: "授權請求無回應", message: "", vc: self, actionHandler: nil)
            print("授權請求無回應")
            break
        case ASAuthorizationError.notHandled:
            CustomFunc.customAlert(title: "授權請求未處理", message: "", vc: self, actionHandler: nil)
            print("授權請求未處理")
            break
        case ASAuthorizationError.unknown:
            CustomFunc.customAlert(title: "授權失敗，原因不知", message: "", vc: self, actionHandler: nil)
            print("授權失敗，原因不知")
            break
        default:
            break
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
// 在畫面上顯示授權畫面
extension SignInWithAppleVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
