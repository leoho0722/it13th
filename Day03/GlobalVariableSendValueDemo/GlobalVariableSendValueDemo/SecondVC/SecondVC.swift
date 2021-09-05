//
//  SecondVC.swift
//  GlobalVariableSendValueDemo
//
//  Created by Leo Ho on 2021/7/26.
//

import UIKit

class SecondVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = globalVariable
    }

}
