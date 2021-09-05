//
//  MainVC.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/10.
//

import UIKit

class MainVC: UIViewController {

    var controller = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func goToNextVC(_ sender: UIButton) {
        if (sender.tag == 0) {
            self.controller = EmailVC(nibName: "EmailVC", bundle: nil)
        } else if (sender.tag == 1) {
            self.controller = SignInWithGoogleVC(nibName: "SignInWithGoogleVC", bundle: nil)
        } else if (sender.tag == 2) {
            self.controller = SignInWithFacebookVC(nibName: "SignInWithFacebookVC", bundle: nil)
        } else if (sender.tag == 3) {
            self.controller = SignInWithAppleVC(nibName: "SignInWithAppleVC", bundle: nil)
        } else if (sender.tag == 4) {
            self.controller = RealtimeDataBaseVC(nibName: "RealtimeDataBaseVC", bundle: nil)
        } else if (sender.tag == 5) {
            self.controller = CloudFirestoreDatabaseVC(nibName: "CloudFirestoreDatabaseVC", bundle: nil)
        }
        self.controller.modalTransitionStyle = .flipHorizontal
        self.controller.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(self.controller, animated: true)
    }

}
