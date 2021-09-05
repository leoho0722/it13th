//
//  CustomFunc.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/11.
//

import Foundation
import UIKit

class CustomFunc {
    /// 提示框
    /// - Parameters:
    ///   - title: 提示框標題
    ///   - message: 提示訊息
    ///   - vc: 要在哪一個 UIViewController 上呈現
    ///   - actionHandler: 按下按鈕後要執行的動作，沒有的話就填 nil
    class func customAlert(title: String, message: String, vc: UIViewController, actionHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "關閉", style: .default) { action in
            actionHandler?()
        }
        alertController.addAction(closeAction)
        vc.present(alertController, animated: true)
    }
    
    // MARK: - 取得送出/更新留言的當下時間
    class func getSystemTime() -> String {
        let currectDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.ReferenceType.system
        dateFormatter.timeZone = TimeZone.ReferenceType.system
        return dateFormatter.string(from: currectDate)
    }
}
