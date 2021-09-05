//
//  SecondVC.swift
//  DelegateSendValueDemo
//
//  Created by Leo Ho on 2021/7/20.
//

import UIKit

class SecondVC: UIViewController {

    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// 讓 SecondVC 遵守 FetchTextDelegate 這個 Protocol
extension SecondVC: FetchTextDelegate {
    func fetchTextFromTextField(_ text: String) {
        textView.text = text
    }
}
