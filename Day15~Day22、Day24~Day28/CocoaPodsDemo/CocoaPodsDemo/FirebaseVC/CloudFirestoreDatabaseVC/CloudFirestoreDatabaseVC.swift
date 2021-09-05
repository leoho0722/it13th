//
//  CloudFirestoreDatabaseVC.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/11.
//

import UIKit
import FirebaseFirestore

class CloudFirestoreDatabaseVC: UIViewController {
    
    @IBOutlet weak var messagePeopleTF: UITextField!
    @IBOutlet weak var messageContentTV: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    
    let dataBase = Firestore.firestore()
    var docRef: DocumentReference? = nil
    var messageList = [MessageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.register(UINib(nibName: "FirestoreDatabaseCell", bundle: nil), forCellReuseIdentifier: "FirestoreDatabaseCell")
        self.fetchMessageFromFirestore()
    }
    
    @IBAction func sendMessageToFirestoreDatabase(_ sender: UIButton) {
        self.sendMessageToFirestore()
    }
    
    @IBAction func sortMessage(_ sender: UIButton) {
        self.sortMessageFromFirestore()
    }
}

extension CloudFirestoreDatabaseVC {
    // MARK: - 送出留言到 Cloud Firestore
    func sendMessageToFirestore() {
        let message = [
            "id": nil,
            "name": self.messagePeopleTF.text!,
            "content": self.messageContentTV.text!,
            "time": CustomFunc.getSystemTime()
        ]
        docRef = dataBase.collection("messages").addDocument(data: message as [String : Any], completion: { error in
            guard error == nil else {
                CustomFunc.customAlert(title: "錯誤訊息", message: "Error adding document: \(String(describing: error))", vc: self, actionHandler: nil)
                return
            }
            CustomFunc.customAlert(title: "留言已送出！", message: "", vc: self, actionHandler: self.fetchMessageFromFirestore)
        })
        self.messagePeopleTF.text = ""
        self.messageContentTV.text = ""
    }
    
    // MARK: - 從 Cloud Firestore 抓取留言
    func fetchMessageFromFirestore() {
        dataBase.collection("messages").getDocuments { snapshot, error in
            if let error = error {
                CustomFunc.customAlert(title: "錯誤訊息", message: "Error getting document: \(String(describing: error))", vc: self, actionHandler: nil)
            } else {
                self.messageList.removeAll()
                for messages in snapshot!.documents {
                    let messageObject = messages.data(with: ServerTimestampBehavior.none)
//                    let messageID = messageObject["id"]
                    let messageName = messageObject["name"]
                    let messageContent = messageObject["content"]
                    let messageTime = messageObject["time"]
                    
                    let message = MessageModel(
                        id: messages.documentID,
                        name: messageName as! String,
                        content: messageContent as! String,
                        time: messageTime as! String
                    )
                    self.messageList.append(message)
                    print(self.messageList)
                }
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
    
    func sortMessageFromFirestore() {
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

extension CloudFirestoreDatabaseVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirestoreDatabaseCell", for: indexPath) as! FirestoreDatabaseCell
        cell.messagePeople.text = messageList[indexPath.row].name
        cell.messageContent.text = messageList[indexPath.row].content
        return cell
    }
    
    // MARK: - 更新留言到 Cloud Firestore
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
                DispatchQueue.main.async {
                    self.dataBase.collection("messages").document("\(String(describing: self.messageList[indexPath.row].id))").updateData(updateMessage as [AnyHashable : Any])
                    CustomFunc.customAlert(title: "留言更新成功！", message: "", vc: self, actionHandler: self.fetchMessageFromFirestore)
                }
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
    
    // MARK: - 從 Cloud Firestore 刪除留言
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { action, view, completeHandler in
            DispatchQueue.main.async {
                self.dataBase.collection("messages").document("\(String(describing: self.messageList[indexPath.row].id))").delete { error in
                    if let error = error {
                        CustomFunc.customAlert(title: "錯誤訊息", message: "Error removing document: \(String(describing: error))", vc: self, actionHandler: nil)
                    } else {
                        CustomFunc.customAlert(title: "已成功刪除留言！", message: "", vc: self, actionHandler: self.fetchMessageFromFirestore)
                    }
                }
            }
            completeHandler(true)
        }
        let trailingSwipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return trailingSwipeAction
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
