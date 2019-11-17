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
    let tfSender = UITextField(frame: CGRect(x: 70, y: 12, width: 300, height: 20))

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
        //tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: "compose")
        //planeButton.tintColor = UIColor.darkGray

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return  section == 0 ? (datePickerIndexPath != nil ? 5 : 4) : 1
    
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row == 3{
            tableView.beginUpdates()
            if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
                tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                self.datePickerIndexPath = nil
            } else {
                print("DEBUG: Setting DatePicker")
                if let datePickerIndexPath = datePickerIndexPath {
                    tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                }
                datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
                tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
                tableView.deselectRow(at: indexPath, animated: true)
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
        tfRecipient.autocorrectionType = .no
        tfSender.autocorrectionType = .no
        tfTitle.autocorrectionType = .no
        tfBody.autocorrectionType = .no
        
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
                case 1:
                    cellLbl = "From:"
                    cell.contentView.addSubview(tfSender)
                case 2:
                    cellLbl = "Message Title:"
                    cell.contentView.addSubview(tfTitle)
                case 3:
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
        var details : String = "Setting message on \(date)"
        details.append("\n\(tfTitle.text)\nTo \(tfRecipient.text)\nCC\(tfSender.text)\nMessage:\n\(tfBody.text)")
        print(details)
        
        let newMsg : Message = Message(recipient: tfRecipient.text!, cc: tfSender.text!, title: tfTitle.text!, msg: tfBody.text!, schedule: date)
        
        if msgIdx >= 0 {
            self.delegateMsgList?.deleteMsg(idx: msgIdx)
            self.delegateMsgList?.addMsg(newMsg: newMsg, idx: msgIdx)
        } else {
            self.delegateMsgList?.addMsg(newMsg: newMsg) }
        
        clearFlds()
        
       
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = configureMailComposer(newMsg: newMsg)
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            print("DEBUG: Cannot send email")
        }
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
    
    // extension ComposeTableViewController: DatePickerDelegate {
        
//        func didChangeDate(date: Date, indexPath: IndexPath) {
//            inputDates[indexPath.row] = date
//            tableView.reloadRows(at: [indexPath], with: .none)
//        }
        
  // }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ComposeTableViewController: DatePickerDelegate {
    
    func didChangeDate(date: Date, indexPath: IndexPath) {
        inputDates[indexPath.row] = date
        self.date = date
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}
