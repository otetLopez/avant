//
//  Message.swift
//  Avant
//
//  Created by otet_tud on 11/10/19.
//  Copyright © 2019 otet_tud. All rights reserved.
//

import Foundation

struct Message : CustomStringConvertible {
    var recipient : Recipient
    var msg : String
    var schedule : Date
    
    var description: String {
        let formattedStr = "To:\t\(self.recipient.email)\nSchedule:\t\(self.schedule)\nMessage:\n\t\t\(self.msg)"
        return formattedStr
    }
}
