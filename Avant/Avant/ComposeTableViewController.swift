//
//  ComposeTableViewController.swift
//  Avant
//
//  Created by otet_tud on 11/10/19.
//  Copyright © 2019 otet_tud. All rights reserved.
//

import UIKit

class ComposeTableViewController: UITableViewController {

    var datePickerIndexPath: IndexPath?
    var isPickingDate : Bool = false
    var inputTexts: [String] = ["Start date", "End date", "Another date"]
    var inputDates: [Date] = []
    
    var date = Date()
    let formatter = DateFormatter()
    
    /** This is for the user input text field **/
    let tfBody = UITextField(frame: CGRect(x: 10, y: 12, width: 200, height: 20))
    let tfRecipient = UITextField(frame: CGRect(x: 50, y: 12, width: 300, height: 20))
    let tfTitle = UITextField(frame: CGRect(x: 130, y: 12, width: 300, height: 20))
    let tfSender = UITextField(frame: CGRect(x: 70, y: 12, width: 300, height: 20))

    //@IBOutlet weak var planeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        tfBody.placeholder = "Your email body here..."
        
        tfRecipient.font = UIFont.systemFont(ofSize: 15)
        tfRecipient.placeholder = "recipient@email.com"
        
        tfSender.font = UIFont.systemFont(ofSize: 15)
        tfSender.placeholder = "sender@email.com"
        
        tfTitle.font = UIFont.systemFont(ofSize: 15)
        tfTitle.placeholder = "Some title"
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
        details.append("\n\(tfTitle.text)\nTo \(tfRecipient.text)\nFrom\(tfSender.text)\nMessage:\n\(tfBody.text)")
        print(details)
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
