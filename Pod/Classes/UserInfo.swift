//
//  UserInfo.swift
//  IMSingularity_Swift
//
//  Created by apple on 3/18/16.
//  Copyright © 2016 apple. All rights reserved.
//

import UIKit

public class UserInfo: NSObject {
    public var login_msg:String?
    public var login_result:String?
    public var upload_token:String?
    public var user_id:String?
    public var user_name:String?
    public var user_picture:String?
    
    
    
    func userMethod(Dict dict:Dictionary<String,AnyObject>)->UserInfo{
        
        self.login_result = String(dict["login_result"]!)
        self.user_id =  dict["user_id"] as? String
        self.user_picture = dict["user_picture"] as? String
        self.login_msg = dict["login_msg"] as? String
        self.user_name = dict["user_name"] as? String
        self.upload_token = dict["upload_token"] as? String
        
        return self
    }
}
