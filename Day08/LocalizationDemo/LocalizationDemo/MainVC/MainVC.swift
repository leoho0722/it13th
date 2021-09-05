//
//  MainVC.swift
//  LocalizationDemo
//
//  Created by Leo Ho on 2021/7/29.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = NSLocalizedString("Hello", comment: "")
    }
}
