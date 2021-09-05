//
//  ViewController.swift
//  SegueSendValueDemo
//
//  Created by Leo Ho on 2021/7/26.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // 點擊空白處來關閉鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToSecondVC") {
            let controller = segue.destination as! SecondVC
            controller.text = textField.text
        }
        
//        /* 上面那段也可以改寫成下面這樣 */
//        guard segue.identifier == "goToSecondVC" else { return }
//        let controller = segue.destination as! SecondVC
//        controller.text = textField.text
    }

}

