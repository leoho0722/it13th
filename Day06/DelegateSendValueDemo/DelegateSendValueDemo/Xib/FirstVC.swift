//
//  FirstVC.swift
//  DelegateSendValueDemo
//
//  Created by Leo Ho on 2021/7/20.
//

import UIKit

class FirstVC: UIViewController {

    @IBOutlet var textField: UITextField!
    
    var delegate: FetchTextDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // 點擊空白處關閉鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func pushToSecondVC(_ sender: UIButton) {
        let controller = SecondVC(nibName: "SecondVC", bundle: nil)
        self.navigationController?.pushViewController(controller, animated: true, completion: {
            self.delegate = controller
            self.delegate?.fetchTextFromTextField(self.textField.text!)
        })
    }
}

/*
 純 Xib 畫面設計步驟：
 1.將 Main Interface 清空 (在 xcodeproj → TARGETS → Deployment Info 裡面)
 2.將 Info.plist 裡的 Storyboard Name 整個刪除 (在 Application Scene Manifest → Scene Configuration → Application Session Role 裡面)
 3.將 Main.storyboard 刪除
 4.新增 Xib 畫面
 5.修改 SceneDelegate.swift (OS Version >= iOS 13) / AppDelegate.swift (OS Version <= iOS 12)
 
 參考資料：
 (1)https://ithelp.ithome.com.tw/articles/10222934 // 純 Xib 畫面設計
 (2)https://reurl.cc/qg4o3g // Delegate 範例
 (3)https://gist.github.com/matsuda/3b06eb3d3081b059035fc80d4b677c78 // NavigationController Completion
 */
