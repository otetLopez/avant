//
//  ComposeViewController.swift
//  Avant
//
//  Created by otet_tud on 11/10/19.
//  Copyright © 2019 otet_tud. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var planeButton: UIButton!
    
    @IBOutlet weak var msgFld: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        msgFld.clipsToBounds = true;
        msgFld.layer.cornerRadius = 10.0;
        //msgFld.plac

        // Do any additional setup after loading the view.
    }
    

    @IBAction func setScheduleButton(_ sender: UIButton) {
        
    }
    @IBAction func planeButtonPressed(_ sender: UIButton) {
    
    }
    
    
    func alert() {
        let alertController = UIAlertController(title: "Set Schedule", message: "Enter a name for this folder", preferredStyle: .actionSheet)
            
        var nFolderName : UIDatePicker!
    
//        alertController.add
//        TextField { (nFolderName) in
//            nFolderName.placeholder = "example New Folder"
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let addItemAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
//            let textField = alertController.textFields![0]
//            print("DEBUG: Will be adding folder \(textField.text!)")
//            self.addNewFolder(fname: "\(textField.text!)")
//            self.reloadTableView()
//        }
//        alertController.addAction(cancelAction)
//        alertController.addAction(addItemAction)
//
//        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
