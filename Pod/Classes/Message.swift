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
        
        let chat_session_type = dict["chat_session_type"]!
        self.chat_session_type         = String(chat_session_type)
        
        
        let message = dict["message"]!
        self.message =  String(message)
        
        let message_id = dict["message_id"]!
        self.message_id         = String(message_id)
        
        let message_time = dict["message_time"]!
        self.message_time         = String(message_time)
        
        let message_token = dict["message_token"]!
        self.message_token = String(message_token)
        
        let message_type = dict["message_type"]!
        self.message_type         = String(message_type)
        
        
        let sender_id = dict["sender_id"]!
        self.sender_id         = String(sender_id)
        
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
