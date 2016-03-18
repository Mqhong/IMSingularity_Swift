//
//  Message.swift
//  IMSingularity_Swift
//
//  Created by apple on 3/18/16.
//  Copyright © 2016 apple. All rights reserved.
//

import UIKit

public class Message: NSObject {
    public var chat_session_id:String?
    public var chat_session_type:String?
    public var sender_id:String?
    public var message_id:String?
    public var message:String?
    public var message_time:String?
    public var message_type:String?
    public var message_token:String?
    
    func messageMethodWithDict(Dict dict:Dictionary<String,AnyObject>)->Message{

        self.chat_session_id = dict["chat_session_id"] as? String
        self.chat_session_type = String(dict["chat_session_type"]!)
        
        let message = dict["message"]!
        self.message =  String(message)
        self.message_id = dict["message_id"] as? String
        self.message_time = String(dict["message_time"]!)
        
        let message_token = dict["message_token"]!
        self.message_token = String(message_token)
        self.message_type = String(dict["message_type"]!)
        self.sender_id = dict["sender_id"] as? String
        return self
    }
    
    
    func messageMethodWithArrDict(ArrDict arrdict:Array<AnyObject>)->Array<Message>{
        
        var arr:Array<Message> = Array()
        
        for dic in arrdict{
            
            var model:Message = Message()
            
            model = model.messageMethodWithDict(Dict: dic as! Dictionary<String, AnyObject>)
            
            arr.append(model)
        }
        return arr
    }
}
