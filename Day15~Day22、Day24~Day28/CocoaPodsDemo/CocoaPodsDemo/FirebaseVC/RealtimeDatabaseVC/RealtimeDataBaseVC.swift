//
//  RealtimeDataBaseVC.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/11.
//

import UIKit
import FirebaseDatabase

class RealtimeDataBaseVC: UIViewController {
    
    @IBOutlet weak var messagePeopleTF: UITextField!
    @IBOutlet weak var messageContentTV: UITextView!
    @IBOutlet weak var sortBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    
    var databaseRef: DatabaseReference!
    var messageList = [MessageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference().child("messages")
        messageTableView.register(UINib(nibName: "RealtimeDatabaseCell", bundle: nil), forCellReuseIdentifier: "RealtimeDatabaseCell")
        self.fetchMessageFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseRef.observe(.value) { snapshot in
            if let output = snapshot.value as? [String: Any] {
                print("目前資料庫內有 \(output.count) 筆留言")
            } else {
                print("目前資料庫內沒有留言！")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseRef.removeAllObservers()
    }
    
    @IBAction func sendMessageToRealtimeDatabase(_ sender: UIButton) {
        self.sendMessageToFirebase()
    }
    
    @IBAction func sortMessageFromRealtimeDatabase(_ sender: UIButton) {
        self.sortMessageFromFirebase()
    }
}

extension RealtimeDataBaseVC {
    // MARK: - 新增留言到 Firebase Realtime Database
    func sendMessageToFirebase() {
        let key = databaseRef.childByAutoId().key
        let message = [
            "id": key,
            "name": messagePeopleTF.text!,
            "content": messageContentTV.text!,
            "time": CustomFunc.getSystemTime()
        ]
        self.databaseRef.child("\(String(describing: key!))").setValue(message)
        CustomFunc.customAlert(title: "留言已送出！", message: "", vc: self, actionHandler: self.fetchMessageFromFirebase)
        self.messagePeopleTF.text = ""
        self.messageContentTV.text = ""
    }
    
    // MARK: - 從 Firebase Realtime Database 讀取留言
    func fetchMessageFromFirebase() {
        self.databaseRef.observe(.value) { snapshot in
            if (snapshot.childrenCount > 0) {
                self.messageList.removeAll()
                for messages in snapshot.children.allObjects as! [DataSnapshot] {
                    let messageObject = messages.value as? [String: AnyObject]
                    let messageID = messageObject?["id"]
                    let messageName = messageObject?["name"]
                    let messageContent = messageObject?["content"]
                    let messageTime = messageObject?["time"]
                    
                    let message = MessageModel(
                        id: messageID as! String,
                        name: messageName as! String,
                        content: messageContent as! String,
                        time: messageTime as! String
                    )
                    self.messageList.append(message)
                }
                self.messageTableView.reloadData()
            } else {
                self.messageList.removeAll()
                self.messageTableView.reloadData()
            }
        }
    }
    
    // MARK: - 留言排序
    enum sortMode {
        case defaultSort // 預設排序 (從新到舊)
        case fromNewToOldSort // 從新到舊
        case fromOldToNewSort // 從舊到新
    }
    
    func sortMessageFromFirebase() {
        let alertController = UIAlertController(title: "請選擇留言排序方式", message: "排序方式為送出/更新留言的時間早晚", preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "預設排序", style: .default) { action in
            self.sortMessageList(sortMode: .defaultSort)
        }
        let fromNewToOldAction = UIAlertAction(title: "從新到舊", style: .default) { action in
            self.sortMessageList(sortMode: .fromNewToOldSort)
        }
        let fromOldToNewAction = UIAlertAction(title: "從舊到新", style: .default) { action in
            self.sortMessageList(sortMode: .fromOldToNewSort)
        }
        let closeAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        alertController.addAction(fromNewToOldAction)
        alertController.addAction(fromOldToNewAction)
        alertController.addAction(closeAction)
        self.present(alertController, animated: true)
    }
    
    func sortMessageList(sortMode: sortMode) {
        if (sortMode == .defaultSort || sortMode == .fromNewToOldSort) {
            self.messageList.sort(by: >)
        } else if (sortMode == .fromOldToNewSort) {
            self.messageList.sort(by: <)
        }
        self.messageTableView.reloadData()
    }
}

extension RealtimeDataBaseVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RealtimeDatabaseCell", for: indexPath) as! RealtimeDatabaseCell
        cell.messagePeople.text = messageList[indexPath.row].name
        cell.messageContent.text = messageList[indexPath.row].content
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "編輯") { action, view, completeHandler in
            let alertController = UIAlertController(title: "更新留言", message: "", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.text = self.messageList[indexPath.row].name
            }
            alertController.addTextField { textField in
                textField.text = self.messageList[indexPath.row].content
            }
            let updateAction = UIAlertAction(title: "更新", style: .default) { action in
                let updateMessage = [
                    "id": self.messageList[indexPath.row].id,
                    "name": alertController.textFields?[0].text!,
                    "content": alertController.textFields?[1].text!,
                    "time": CustomFunc.getSystemTime()
                ]
                self.databaseRef.child("\(String(describing: self.messageList[indexPath.row].id))").setValue(updateMessage)
                CustomFunc.customAlert(title: "留言更新成功！", message: "", vc: self, actionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(updateAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
            completeHandler(true)
        }
        let leadingSwipeAction = UISwipeActionsConfiguration(actions: [editAction])
        editAction.backgroundColor = UIColor(red: 0.0/255.0, green: 127.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        return leadingSwipeAction
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { action, view, completeHandler in
            self.databaseRef.child(self.messageList[indexPath.row].id).setValue(nil)
            completeHandler(true)
        }
        let trailingSwipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return trailingSwipeAction
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
