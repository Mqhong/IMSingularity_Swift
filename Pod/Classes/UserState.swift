//
//  UserState.swift
//  IMSingularity_Swift
//
//  Created by apple on 3/18/16.
//  Copyright © 2016 apple. All rights reserved.
//

import UIKit

public class UserState: NSObject {
    public var user_id:String?
    public var user_name:String?
    public var user_online_status:String?
    public var user_picture:String?
    
    func userStateMethodWithDict(Dict dict:Dictionary<String,AnyObject>)->UserState{
        
        let user_id = dict["user_id"]!
        self.user_id =  String(user_id)
        
        let user_name = dict["user_name"]!
        self.user_name = String(user_name)
        
        let user_online_status = dict["user_online_status"]!
        self.user_online_status = String(user_online_status)
        
        let user_picture = dict["user_picture"]!
        self.user_picture = String(user_picture)
        
        return self
    }
}
