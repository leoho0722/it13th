//
//  ViewController.swift
//  PDFViewDemo
//
//  Created by Leo Ho on 2021/7/20.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    @IBOutlet var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileURL = Bundle.main.url(forResource: "TUTK P2P", withExtension: "pdf") // 指定專案內的檔案路徑
        pdfView.document = PDFDocument(url: fileURL!) // 將 PDF 檔案路徑給 pdfView，讓他去顯示檔案
    }


}

