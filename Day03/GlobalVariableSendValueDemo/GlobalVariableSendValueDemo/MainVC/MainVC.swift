//
//  MainVC.swift
//  GlobalVariableSendValueDemo
//
//  Created by Leo Ho on 2021/7/26.
//

import UIKit

var globalVariable: String? // 宣告在 class 外面的叫全域變數

class MainVC: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // 點擊空白處關閉鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func pushToSecondVC(_ sender: UIButton) {
        let vc = SecondVC(nibName: "SecondVC", bundle: nil)
        globalVariable = textField.text
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
