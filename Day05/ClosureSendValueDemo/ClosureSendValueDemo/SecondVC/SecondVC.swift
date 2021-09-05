//
//  SecondVC.swift
//  SecondVC
//
//  Created by Leo Ho on 2021/7/25.
//

import UIKit

class SecondVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var mainVC: MainVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainVC?.closureSendValue({ text in
            textView.text = text
        })
    }
    
}
