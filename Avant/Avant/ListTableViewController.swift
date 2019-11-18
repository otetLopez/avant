//
//  ListTableViewController.swift
//  Avant
//
//  Created by otet_tud on 11/10/19.
//  Copyright © 2019 otet_tud. All rights reserved.
//

import UIKit
import UserNotifications
import MessageUI

class ListTableViewController: UITableViewController, UNUserNotificationCenterDelegate, MFMailComposeViewControllerDelegate {

    struct Notification {
        struct Category {
            static let alarm = "Reminder"
        }
        struct Action {
            static let send = "sendEmail"
            static let cancel = "cancel"
        }
    }
    
    var msgs = [Message]()
    var sent = [Message]()
    var msgIdx : Int = -1
    var isEditingList : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserNotificationsCenter()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return msgs.count
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        msgIdx = -1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "msglist", for: indexPath)
        cell.textLabel?.text = msgs[indexPath.row].title
        cell.detailTextLabel?.text = msgs[indexPath.row].recipient
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        msgIdx = indexPath.row
        print("DEBUG: You selected msg \(msgs[indexPath.row].title)")
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let DeleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, success) in
        self.msgs.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)})
        return UISwipeActionsConfiguration(actions: [DeleteAction])
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        msgIdx = indexPath.row
        print("DEBUG: You selected to view Msg \(msgs[indexPath.row]) at \(msgIdx)")
        alert(title: "Message not yet sent", msg: "\(msgs[indexPath.row])")
        
    }
    
    func alert(title: String, msg : String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
          
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
    
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addMsg (newMsg : Message) {
        msgs.append(newMsg)
        //scheduleNotification(alertMsg: newMsg)
        addNotification(msg: newMsg)
    }
    
    func addMsg (newMsg : Message, idx : Int) {
        msgs.insert(newMsg, at: idx)
        //scheduleNotification(alertMsg: newMsg)
        addNotification(msg: newMsg)
    }
    
    func deleteMsg(idx : Int) {
        msgs.remove(at: idx)
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        print("DEBUG: Edit Button Pressed")
        if isEditingList {
            self.tableView.isEditing = false
            isEditingList = false
        } else {
            self.tableView.isEditing = true
            isEditingList = true
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func addNotification (msg: Message) {
        // TO DO needs to be changed
        //msgToSend = msg
        
        // Request Notification Settings
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }

                    // Schedule Local Notification
                    self.scheduleNotification(alertMsg: msg)
                })
            case .authorized:
                // Schedule Local Notification
                self.scheduleNotification(alertMsg: msg)
            case .denied:
                print("Application Not Allowed to Display Notifications")
            case .provisional: break
                //Do nothing
            @unknown default: break
                // Do nothing
            }
        }
    }
    
    private func configureUserNotificationsCenter() {
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self

        // Define Actions
        let actionSend = UNNotificationAction(identifier: Notification.Action.send, title: "Send It!", options: [.foreground])
//        let actionShowDetails = UNNotificationAction(identifier: Notification.Action.showDetails, title: "Show Details", options: [.foreground])
        let actionUnsubscribe = UNNotificationAction(identifier: Notification.Action.cancel, title: "Cancel", options: [.destructive, .authenticationRequired])

        // Define Category
        let category = UNNotificationCategory(identifier: Notification.Category.alarm, actions: [actionSend, actionUnsubscribe], intentIdentifiers: [], options: [])

        // Register Category
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }

    func scheduleNotification(alertMsg : Message) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = alertMsg.title
        content.body = alertMsg.msg
        content.subtitle = alertMsg.msgId
        content.categoryIdentifier = Notification.Category.alarm
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        let calendar = Calendar.current
        
        dateComponents.year = calendar.component(.year, from: alertMsg.schedule)
        dateComponents.month = calendar.component(.month, from: alertMsg.schedule)
        dateComponents.day = calendar.component(.day, from: alertMsg.schedule)
        dateComponents.hour = calendar.component(.hour, from: alertMsg.schedule)
        dateComponents.minute = calendar.component(.minute, from: alertMsg.schedule)
        dateComponents.second = 0//calendar.component(.second, from: alertMsg.schedule)
        
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let identifierStr : String = "\(alertMsg.title)\(alertMsg.msgId)"
        let request = UNNotificationRequest(identifier: /*UUID().uuidString*//*"cocoacasts_local_notification"*/identifierStr, content: content, trigger: trigger)
        center.add(request)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    func sendemail(id : String) {
        var isMsgSending : Bool = false
        var msgToSend : Message
        var idx : Int = 0
        for message in msgs {
            if message.msgId == id {
                msgToSend = message
                isMsgSending = true
                if MFMailComposeViewController.canSendMail() {
                    let mailComposeViewController = configureMailComposer(newMsg: msgToSend)
                    present(mailComposeViewController, animated: true, completion: nil)
                    //updateLists(msg: msgToSend)
                    updateLists(idx: idx)
                } else { print("DEBUG: Cannot send email") }
                break
            }
            idx += 1
        }
        print("DEBUG: Message sending \(isMsgSending)")
    }
        
    func configureMailComposer(newMsg: Message) -> MFMailComposeViewController  {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject(newMsg.title)
        mail.setCcRecipients([newMsg.cc])
        mail.setToRecipients([newMsg.recipient])
        mail.setMessageBody("\(newMsg.msg)", isHTML: true)
        return mail
    }
    
    //func updateLists(msg : Message) {
    func updateLists(idx : Int) {
//        var idx : Int = 0
//        for message in msgs {
//            if message.msgId == msg.msgId {
//                break
//            }
//            idx += 1
//        }
        sent.append(msgs[idx])
        msgs.remove(at: idx)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let compose = segue.destination as? ComposeTableViewController {
            compose.delegateMsgList = self
        }
        if let info = segue.destination as? InfoViewController {
            info.delegateinfo = self
        }
        if let history = segue.destination as? HistoryTableViewController {
            history.delegatehistory = self
        }

        let backItem = UIBarButtonItem()
        backItem.title = "Messages"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
}

extension ListTableViewController {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case Notification.Action.send:
            print("DEBUG: Sending your precious email")
            print("original body was : \(response.notification.request.content.subtitle)")
            var msgId : String = response.notification.request.content.subtitle
            sendemail(id: msgId)
        case Notification.Action.cancel:
            print("DEBUG: Ignoring whatever you have decided to set day(s) ago")
        default:
            print("Other Action")
        }
        completionHandler()
    }
}
