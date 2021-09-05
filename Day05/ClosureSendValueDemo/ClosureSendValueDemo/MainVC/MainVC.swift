//
//  MainVC.swift
//  MainVC
//
//  Created by Leo Ho on 2021/7/25.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // 點擊空白處來關閉鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func pushToSecondVC(_ sender: UIButton) {
        let vc = SecondVC(nibName: "SecondVC", bundle: nil)
        vc.mainVC = self // 加入這一行，將 SecondVC 裡的 mainVC 指向 MainVC 這個檔案
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 透過閉包 (closure) 來傳值
    func closureSendValue(_ handler: (String) -> Void) {
        guard let text = textField.text else { return }
        handler(text)
    }
    
}

/*
 參考資料：https://reurl.cc/O0gv33
 */
