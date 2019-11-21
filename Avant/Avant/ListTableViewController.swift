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
    var mccIdx : Int = -1
    var isEditingList : Bool = false
    var isScheduleUpdated : Bool = false
    let format = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        format.dateFormat = "dd-MM-yy HH:mm"
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
        if !checkDate(date: msgs[indexPath.row].schedule) {
            self.tableView.cellForRow(at: indexPath)?.accessoryView?.tintColor = UIColor.red
            cell.tintColor = UIColor.red
        } else {
            self.tableView.cellForRow(at: indexPath)?.accessoryView?.tintColor = UIColor.darkGray
            cell.tintColor = UIColor.darkGray
        }
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
        //msgIdx = indexPath.row
        print("DEBUG: You selected to view Msg \(msgs[indexPath.row]) at \(indexPath.row)")
        if checkDate(date: msgs[indexPath.row].schedule) {
            alert(title: "Message not yet sent", msg: "\(getTimeLeft(date: msgs[indexPath.row].schedule))")
        } else {
            // We need to let user send email
            alert(title: "Your message is due", idx: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.msgs[sourceIndexPath.row]
        msgs.remove(at: sourceIndexPath.row)
        msgs.insert(movedObject, at: destinationIndexPath.row)
    }
    
    func getTimeLeft(date: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute, .second, .day, .weekOfYear, .month, .year], from: Date(), to: date)
        var msg : String = ""
        if components.year ?? 0 > 0 { msg.append("\(components.year!) year(s), ") }
        if components.month ?? 0 > 0 { msg.append("\(components.month!) month(s), ") }
        if components.day ?? 0 > 0 { msg.append("\(components.day!) day(s), ") }
        msg.append("\(String(format: "%02d", components.hour ?? 0)):\(String(format: "%02d", components.minute ?? 0)):\(String(format: "%02d", components.second ?? 0)) left to send message")
        return msg
        
    }
    
    func checkDate(date: Date) -> Bool {
        let current : Date = Date()
        print("DEBUG: Schedule \(date) vs. \(current)")
        if date  <  current  || date == current {
            print("DEBUG: date is earlier than current date")
            return false
        }

        let sched : String = format.string(from: date)
        let now : String = format.string(from: current)
        print("DEBUG: \(sched) vs \(now) than current date")
        if sched == now {
            print("DEBUG: Time to send message")
            return false
        }
        return true
    }
    
    func alert(title: String, idx: Int) {
        let alertController = UIAlertController(title: title, message: "\(msgs[idx])", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Ignore", style: .cancel, handler: nil)
        let sendAction = UIAlertAction(title: "Send It!", style: .destructive) { (action) in
            self.sendemail(idx: idx)
        }
        sendAction.setValue(UIColor.red, forKey: "titleTextColor")

        alertController.addAction(cancelAction)
        alertController.addAction(sendAction)
        self.present(alertController, animated: true, completion: nil)
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
        if isScheduleUpdated {
            addNotification(msg: newMsg)
        }
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
    
    func sendemail(idx: Int) {
        if MFMailComposeViewController.canSendMail() {
            var msgToSend : Message = msgs[idx]
            let mailComposeViewController = configureMailComposer(newMsg: msgToSend)
            present(mailComposeViewController, animated: true, completion: nil)
            mccIdx = idx
            //updateLists(idx: idx)
        } else { print("DEBUG: Cannot send email") }
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
                    //updateLists(idx: idx)
                    mccIdx = idx
                    //mailComposeViewController.dismiss(animated: true, completion: nil)
                } else { print("DEBUG: Cannot send email") }
                break
            }
            idx += 1
        }
        print("DEBUG: Message sending \(isMsgSending)")
    }
        
    func configureMailComposer(newMsg: Message) -> MFMailComposeViewController  {
        let mail = MFMailComposeViewController()
        print("DEBUG: configureMailComposer \(newMsg)")
        mail.mailComposeDelegate = self
        mail.setSubject(newMsg.title)
        mail.setCcRecipients([newMsg.cc])
        mail.setToRecipients([newMsg.recipient])
        mail.setMessageBody("\(newMsg.msg)", isHTML: true)
        return mail
    }
    
     func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        // Dismiss the mail compose view controller.
        print("DEBUG: Message is sent")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
         print("DEBUG: Message is sent 2 ")
        switch result {
        case .sent:
            updateLists(idx: mccIdx)
        case .failed:
            alert(title: "Error", msg: "MFMailComposeViewController failed to send message")
        default:
            alert(title: "Warning", msg: "User opt not to send email")
        }
        mccIdx = -1
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    func updateLists(idx : Int) {
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
