//
//  Message.swift
//  Avant
//
//  Created by otet_tud on 11/10/19.
//  Copyright © 2019 otet_tud. All rights reserved.
//

import Foundation

struct Message : CustomStringConvertible {
    //var recipient : Recipient
    var recipient : String
    var cc : String
    var title : String
    var msg : String
    var msgId : String
    var schedule : Date
    
    var description: String {
        let format = DateFormatter()
        format.dateFormat = "dd-MM-yy HH:mm:SS"
        let sched : String = format.string(from: self.schedule)
        let formattedStr = //"To:\t\(self.recipient)\nSchedule:\t\(self.schedule)\nMessage:\n\t\t\(self.msg)"
        "Your message: \(self.title)\nTo: \(self.recipient)\nScheduled: \(sched)\nContains:\n\(self.msg)"
        return formattedStr
    }
}
