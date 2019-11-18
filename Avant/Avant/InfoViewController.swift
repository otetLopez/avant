//
//  InfoViewController.swift
//  Avant
//
//  Created by otet_tud on 11/17/19.
//  Copyright © 2019 otet_tud. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var details: UILabel!
    weak var delegateinfo: ListTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //details.text! = ("\(String(describing: self.delegateinfo?.msgs[self.delegateinfo!.msgIdx]))")
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
