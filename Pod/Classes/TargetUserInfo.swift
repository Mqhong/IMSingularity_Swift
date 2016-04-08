//
//  TargetUserInfo.swift
//  IMSingularity_Swift
//
//  Created by apple on 3/18/16.
//  Copyright © 2016 apple. All rights reserved.
//

import UIKit

public class TargetUserInfo: NSObject {
    public var chat_session_id:String?
    public var target_id:String?
    public var target_name:String?
    public var target_picture:String?
    
    func targetUserMethod(Dict dict:Dictionary<String,AnyObject>)->TargetUserInfo{

        self.chat_session_id = dict["chat_session_id"] as? String
        self.target_id = dict["target_id"] as? String
        self.target_name = dict["target_name"] as? String
        
        let target_picture = dict["target_picture"]!
        self.target_picture = String(target_picture)
        
        return self
        
    }
}
