//
//  ComposeTableViewController.swift
//  Avant
//
//  Created by otet_tud on 11/10/19.
//  Copyright © 2019 otet_tud. All rights reserved.
//

import UIKit
import MessageUI

class ComposeTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

     weak var delegateMsgList: ListTableViewController?
    

    
    var datePickerIndexPath: IndexPath?
    var isPickingDate : Bool = false
    var inputTexts: [String] = ["Start date", "End date", "Another date"]
    var inputDates: [Date] = []
    
    var date : Date = Date()
    let formatter = DateFormatter()
    var msgIdx : Int = -1
    
    /** This is for the user input text field **/
    let tfBody = UITextField(frame: CGRect(x: 10, y: 12, width: 200, height: 20))
    let tfRecipient = UITextField(frame: CGRect(x: 50, y: 12, width: 300, height: 20))
    let tfTitle = UITextField(frame: CGRect(x: 130, y: 12, width: 300, height: 20))
    let tfSender = UITextField(frame: CGRect(x: 50, y: 12, width: 300, height: 20))

    //@IBOutlet weak var planeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        msgIdx = self.delegateMsgList!.msgIdx
        setuptfs()
        addInitailValues()
        formatter.dateFormat = "dd-MM-yy HH:mm"
        
        tableView.register(UINib(nibName: DateTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: DateTableViewCell.reuseIdentifier())
        tableView.register(UINib(nibName: DatePickerTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: DatePickerTableViewCell.reuseIdentifier())
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(_ sender: UIView) {
        tfBody.resignFirstResponder()
        tfRecipient.resignFirstResponder()
        tfTitle.resignFirstResponder()
        //cells.resignFirstResponder()
        //tfSender.resignFirstResponder()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return  section == 0 ? (datePickerIndexPath != nil ? 5 : 4) : 1  //removed CC no time to support
        return  section == 0 ? (datePickerIndexPath != nil ? 4 : 3) : 1
    
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.tableView.cellForRow(at: indexPath)?.isHighlighted = false
        self.tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        print("DEBUG: DidSelect \(indexPath.row)")
        if indexPath.row == 2 {
            tableView.beginUpdates()
            if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
                tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                self.datePickerIndexPath = nil
            } else {
                print("DEBUG: Setting DatePicker")
//                if let datePickerIndexPath = datePickerIndexPath {
//                    tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
//                }
                datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
                tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
//                tableView.deselectRow(at: indexPath, animated: true)
            }
            tableView.endUpdates()
        }
    }
    
    func addInitailValues() {
        inputDates = Array(repeating: Date(), count: 10)
    }
    
    func setuptfs() {
        tfBody.font = UIFont.systemFont(ofSize: 15)
        tfRecipient.font = UIFont.systemFont(ofSize: 15)
        tfSender.font = UIFont.systemFont(ofSize: 15)
        tfTitle.font = UIFont.systemFont(ofSize: 15)
        tfBody.placeholder = "Your email body here..."
        tfRecipient.placeholder = "recipient@email.com"
        tfSender.placeholder = "sender@email.com"
        tfTitle.placeholder = "Some title"
        tfBody.autocorrectionType = .no
        tfRecipient.autocorrectionType = .no
        tfSender.autocorrectionType = .no
        tfTitle.autocorrectionType = .no
 
        tfRecipient.autocapitalizationType = .none
        tfSender.autocapitalizationType = .none
        
        if msgIdx >= 0 {
            tfBody.text = self.delegateMsgList?.msgs[msgIdx].msg
            tfRecipient.text = self.delegateMsgList?.msgs[msgIdx].recipient
            tfSender.text = self.delegateMsgList?.msgs[msgIdx].cc
            tfTitle.text = self.delegateMsgList?.msgs[msgIdx].title
            date = (self.delegateMsgList?.msgs[msgIdx].schedule)!
        }
    }
    
    func checkFlds() -> Bool {
        var err_msg : String = ""
        if tfRecipient.text!.isEmpty { err_msg.append("Recipient") }
        if tfTitle.text!.isEmpty { if !(err_msg.isEmpty) { err_msg.append(", ") }; err_msg.append("Subject") }
        if tfBody.text!.isEmpty { if !(err_msg.isEmpty) { err_msg.append(", ") }; err_msg.append("Message Body") }

        if !err_msg.isEmpty {
            err_msg.append("field(s) are empty")
            alert(title: "Error", msg : err_msg)
            return false
        }
        return true
    }
    
    func alertAddConfirmation()  {
        let alertController = UIAlertController(title: "Setting Message", message: "Are you sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: "Set it!", style: .destructive) { (action) in
            self.setMsg()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(sureAction)
               
        self.present(alertController, animated: true, completion: nil)
    }
      
    func alert(title: String, msg : String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
          
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
    
        self.present(alertController, animated: true, completion: nil)
    }
    
    func clearFlds() {
        msgIdx = -1
        self.delegateMsgList?.msgIdx = msgIdx
        
        tfBody.text?.removeAll()
        tfRecipient.text?.removeAll()
        tfSender.text?.removeAll()
        tfTitle.text?.removeAll()
        date = Date()
        
        // TODO
        //tableView.deleteRows(at: [datePickerIndexPath!], with: .fade)
        //self.datePickerIndexPath = nil
        
        tableView.reloadData()
    }
    
    func generateMsgId () -> String {
        let format = DateFormatter()
        format.dateFormat = "ddMMyyHHmm"
        var formattedId : String = format.string(from: date)
        var count : Int = 0
        if self.delegateMsgList?.msgs.count ?? 0 > 0 {
            for idx in self.delegateMsgList!.msgs {
                if idx.msgId.contains(formattedId) {
                    count += 1
                }
            }
        }
        formattedId.append("\(count)")
        return formattedId
    }

    func setMsg () {
        let msgId : String = (msgIdx>=0) ? (self.delegateMsgList?.msgs[msgIdx].msgId)! : generateMsgId()
        let fixDate = Calendar.current.date(bySetting: .second, value: 0, of: date)!
        print("DEBUG: Set schedule will be on \(fixDate)")
        let newMsg : Message = Message(recipient: tfRecipient.text!, cc: tfSender.text!, title: tfTitle.text!, msg: tfBody.text!, msgId: msgId, schedule: date)
        if msgIdx >= 0 {
            checkSchedule()
            self.delegateMsgList?.deleteMsg(idx: msgIdx)
            self.delegateMsgList?.addMsg(newMsg: newMsg, idx: msgIdx)
        } else {
            self.delegateMsgList?.addMsg(newMsg: newMsg) }
        clearFlds()
    }
    
    func checkSchedule() {
        let previous = formatter.string(from: (self.delegateMsgList?.msgs[msgIdx].schedule)!)
        let current = formatter.string(from: date)
        print("DEBUG: Previous date \(self.delegateMsgList?.msgs[msgIdx].schedule) vs. \(date)")
        if previous == current {
            print("DEBUG: Dates are the same")
            self.delegateMsgList?.isScheduleUpdated = false
        } else {
            self.delegateMsgList?.isScheduleUpdated = true
        }
    }
    
    func indexPathToInsertDatePicker(indexPath: IndexPath) -> IndexPath {
        print("DEBUG: Inserting Date Picker")
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if datePickerIndexPath == indexPath {
            return DatePickerTableViewCell.cellHeight()
        } else {
            return DateTableViewCell.cellHeight()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if datePickerIndexPath == indexPath {
            let datePickerCell = tableView.dequeueReusableCell(withIdentifier: DatePickerTableViewCell.reuseIdentifier()) as! DatePickerTableViewCell
            datePickerCell.updateCell(date: inputDates[indexPath.row - 1], indexPath: indexPath)
            datePickerCell.delegate = self
            return datePickerCell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "compose", for: indexPath)
            // Configure the cell...
            let result = formatter.string(from: date)
            
            var cellLbl : String = ""
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0:
                    cellLbl = "To:"
                    cell.contentView.addSubview(tfRecipient)
//                case 1:
//                    cellLbl = "Cc:"
//                    cell.contentView.addSubview(tfSender)
                case 1:
                    cellLbl = "Message Title:"
                    cell.contentView.addSubview(tfTitle)
                case 2:
                    cellLbl = "Schedule"
                    print("DEBUG: The date today is \(result)")
                    cell.detailTextLabel?.text = result
                default: break
                }
            }
            else if indexPath.section == 1 {
                cell.contentView.addSubview(tfBody)
            }
            cell.textLabel?.text = cellLbl
            return cell
        }
        return UITableViewCell()
    }
    
    @IBAction func setmsgButton(_ sender: UIButton) {
        if checkFlds() {
            var details : String = "DEBUG: Setting message on \(date)"
            details.append("\n\(tfTitle.text)\nTo \(tfRecipient.text)\nCC\(tfSender.text)\nMessage:\n\(tfBody.text)")
            print(details)
            alertAddConfirmation()
        }
        /*  //temporarily disable
        let newMsg : Message = Message(recipient: tfRecipient.text!, cc: tfSender.text!, title: tfTitle.text!, msg: tfBody.text!, msgId: "", schedule: date)
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = configureMailComposer(newMsg: newMsg)
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            print("DEBUG: Cannot send email")
        }
       */
    }
    
    func configureMailComposer(newMsg: Message) -> MFMailComposeViewController{
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject(newMsg.title)
        mail.setCcRecipients([newMsg.cc])
        mail.setToRecipients([newMsg.recipient])
        mail.setMessageBody("\(newMsg.msg)", isHTML: true)
        return mail
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension ComposeTableViewController: DatePickerDelegate {
    
    func didChangeDate(date: Date, indexPath: IndexPath) {
        inputDates[indexPath.row] = date
        self.date = date
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}
