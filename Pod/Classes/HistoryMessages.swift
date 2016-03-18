//
//  HistoryMessages.swift
//  IMSingularity_Swift
//
//  Created by apple on 3/18/16.
//  Copyright © 2016 apple. All rights reserved.
//

import UIKit

public class HistoryMessages: NSObject {
    public  var chat_session_id:String?
    public var history_messages:Array<Message> = Array()
    public var unread_messages:Array<Message> = Array()
}
