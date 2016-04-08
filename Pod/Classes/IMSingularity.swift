//
//  IMSingularity.swift
//  IMSingularity_Swift
//
//  Created by apple on 3/18/16.
//  Copyright © 2016 apple. All rights reserved.
//

import UIKit
import SwiftR

public enum State {
    case Starting
    case Connected
    case Reconnected
    case Disconnected
}

@objc public protocol IMSingularityDelegate: NSObjectProtocol{
    //MARK: 服务器回调 - 连接状态
    /**！
    @brief 连接状态
    @param state 状态信息
    @return nil
    */
    optional func connectionState(state:Int)
    
    
    //MARK: 服务器回调 - 用户登录回调
    /**!
    @brief 用户登录回调
    @param  loginModel 用户登录Model:
    {
        target_id               //目标id
        chat_session_type       //聊天会话类型
        chat_session_id         //聊天会话 id
    }
    @return nil
    */
    optional func loginCallback(request:UserInfo)
    
    
    //MARK: 服务器回调 - 获取目标信息回调
    /**!
    @brief 获取目标信息回调
    @param targetModel 目标信息Model:
    {
        chat_session_id         //聊天会话 id
        target_id               //目标ID
        target_name             //目标名称
        target_picture          //目标图片
    }
    @return nil
    */
    optional func receiveTargetInfo(request:TargetUserInfo)
    
    
    //MARK: 服务器回调 - 获取用户会话列表回调
    /**!
    @brief 获取用户会话列表回调
    @param chatListMArray 会话列表Model:
    sessionList:[
        {
        chat_session_id         //聊天会话 id
        chat_session_type       //聊天会话类型 0:用户 1:群
        message_count           //会话未读消息条数
        last_sender_id          //最后发送者 id
        last_message            //最后条消息
        last_message_time       //最后条消息发送时间
        last_message_type       //最后条消息类型
        target_id               //会话目标 id ,会话类型为 0 是用户 id为1是群id
        target_name             //目标名称
        target_picture          //目标头像
        target_online_status    //目标在线状态(仅用于 chat_session_type 为0:用户时)
        }
    ]
    @return nil
    */
    optional func receiveChatSessionList(request:IMSessionList)
    
    //MARK: 服务器回调 - 获取未读消息回调
    /**!
    @brief 获取未读消息回调
    @param unreadMArray 未读信息Model:
    unread_messages:[
    {
        chat_session_id         //聊天会话 id
        chat_session_type       //聊天会话类型 0:用户 1:群
        sender_id               //最后发送者 id
        message_id              //消息 id
        message                 //消息内容
        message_time            //消息发送时间
        message_type            //消息类型
    }
    ]
    @return nil
    */
    optional func receiveUnreadMessages(request:UnreadMessages)
    
    
    //MARK: 服务器回调 - 获取历史消息回调
    /**!
    @brief 获取历史消息回调
    @param historyMArray 历史信息Model:
    chat_session_id
    history_messages:[
        chat_session_id //聊天会话 id
        history_messages:{
        chat_session_id         //聊天会话 id
        chat_session_type       //聊天会话类型 0:用户 1:群
        sender_id               //发送者 id
        message_id              //消息id
        message                 //消息内容
        message_time            //消息发送时间
        message_type            //消息类型
    }
    unread_messages:{
    ...... //同上
    }
    ]
    @return nil
    */
    optional func receiveHistoryMessages(request:HistoryMessages)
    
    
    //MARK: 服务器回调 - 发送消息回调
    /**!
    @brief 发送消息回调
    @param sendMsgModel 发送信息Model
    {
        chat_session_id         //聊天会话 id
        chat_session_type       //聊天会话类型 0:用户 1:群
        sender_id               //最后发送者 id
        message_id              //消息 id
        message                 //消息内容
        message_time            //消息发送时间
        message_token           //token 由调用者随机生成
        message_type            //消息类型
    }
    @return nil
    */
    optional func messageCallback(request:Message)
    
    
    
    //MARK: 服务器回调 - 接收消息回调
    /*!
    @brief 接收消息回调
    @param receiveMsgModel 接受信息Model:
    {
        chat_session_id         //聊天会话 id
        chat_session_type       //聊天会话类型 0:用户 1:群
        sender_id               //发送者 id
        message_id              //消息 id
        message                 //消息内容
        message_time            //消息发送时间
        message_type            //消息类型
    }
    @return nil
    */
    optional func receiveMessage(request:Message)
    
    
    //MARK: 服务器回调 - 聊天用户(对方)在线状态改变回调
    /*!
    @brief 聊天用户(对方)在线状态改变回调
    @param userStatusModel 用户状态Model
    {
        user_id                 //用户 id
        user_name               //用户名称
        user_picture            //用户图片
        user_online_status      //在线状态 0:离线 1:在
    }
    @return nil
    */
    optional func chatUserStatusChanged(request:UserState)
    

}

public class IMSingularity: NSObject {
    public var chatHub:Hub!
    public var hubConnection: SignalR!
    public var delegate:IMSingularityDelegate?
    public var connectionState: State = .Disconnected
    
    
    //MARK
    /**!
    @brief 创建连接
    @param url 服务器连接地址!
    @param hubProxy 服务器标示
    @return nil
    */
    public func initWithConnectionUrl(url:String){
        hubConnection = SwiftR.connect(url) { [weak self] connection in
            
            self?.chatHub = connection.createHubProxy("chatHub")
            
            connection.starting = {
                self?.delegate?.connectionState!(0)
            }
            
            connection.connected = {
                print("NSLOG:连接id: \(connection.connectionID!)")
                self?.delegate?.connectionState!(1)
            }
            
            connection.reconnected = {
                print("NSLOG:重新连接id: \(connection.connectionID!)")
                self?.delegate?.connectionState!(2)
            }
            
            connection.disconnected = {
                self?.delegate?.connectionState!(3)
            }
            
            
            //监听服务器的回调 - chat.client.loginCallback - 用户登录
            self?.chatHub.on("loginCallback", callback: { (args) -> () in
                
                var user:UserInfo = UserInfo()
                var dict:Dictionary<String,AnyObject>! = ["":""]
                
                if let argsDic:Dictionary<String,AnyObject> = args! as? Dictionary<String,AnyObject> {
                    
                    dict = argsDic["0"] as? Dictionary<String,AnyObject>
                
                }else if let argsArray:[AnyObject]? = args as? [AnyObject]? {
                    
                    dict = argsArray![0] as? Dictionary
                }

                user = user.userMethod(Dict: dict)
                self?.delegate?.loginCallback!(user)
                
            })
            
            //监听服务器的回调 - chat.client.receiveTargetInfo - 获取目标信息
            self?.chatHub.on("receiveTargetInfo", callback: { (args) -> () in
                
                var target:TargetUserInfo = TargetUserInfo()
                
                var dict:Dictionary<String,AnyObject>! = ["":""]
                

                if let argsDic:Dictionary<String,AnyObject> = args! as? Dictionary<String,AnyObject>{
                    
                    dict = argsDic["0"] as? Dictionary<String,AnyObject>
                    
                }else if let argsArray:[AnyObject]? = args as? [AnyObject]? {
                    
                    dict = argsArray![0] as? Dictionary
                }
                
                target =  target.targetUserMethod(Dict: dict)
                
                self?.delegate?.receiveTargetInfo!(target)
            })
            
            
            
            //监听服务器的回调 - chat.client.receiveChatSessionList - 获取会话列表
            self?.chatHub.on("receiveChatSessionList", callback: { (args) -> () in
                
                var array:Array<AnyObject>! = []
                
                if let argsDic:Dictionary<String,AnyObject> = args! as? Dictionary<String,AnyObject> {
                    
                        array = argsDic["0"] as? Array
                    
                }else if let argsArray:[AnyObject]? = args as? [AnyObject]? {
                    
                        array = argsArray![0] as? Array
                }
                
                let sessionlist = IMSessionList()
                
                let session = IMSession()
                
                sessionlist.sessionList = session.sessionListMethod(ArrDict: array)
                
                self?.delegate?.receiveChatSessionList!(sessionlist)
                
            })
            
            
            
            //监听服务器的回调 - chat.client.receiveUnreadMessages - 获取未读消息
            self?.chatHub.on("receiveUnreadMessages", callback: { (args) -> () in
                
                var array:Array<AnyObject>! = []
                
                if let argsDic:Dictionary<String,AnyObject> = args! as? Dictionary<String,AnyObject> {
                    
                    array = argsDic["0"] as? Array
                    
                }else if let argsArray:[AnyObject]? = args as? [AnyObject]? {
                    
                    array = argsArray![0] as? Array
                }
                
                let message = Message()
                
                let arr:Array<Message> = message.messageMethodWithArrDict(ArrDict: array)
                
                let unreadMessages:UnreadMessages = UnreadMessages()
                
                unreadMessages.unread_messages = arr;
                
                self?.delegate?.receiveUnreadMessages!(unreadMessages)
            })
            
            //监听服务器的回调 - chat.client.receiveHistoryMessages - 获取历史消息
            self?.chatHub.on("receiveHistoryMessages", callback: { (args) -> () in
                
                
                var dict:Dictionary<String,AnyObject>! = ["":""]
                
                if let argsDic:Dictionary<String,AnyObject> = args! as? Dictionary<String,AnyObject> {
                    
                    dict = argsDic["0"] as? Dictionary<String,AnyObject>!
                    
                }else if let argsArray:[AnyObject]? = args as? [AnyObject]? {
                    
                    dict = argsArray![0] as? Dictionary
                }
                
                
                let unread_messages:Array<AnyObject> = (dict["unread_messages"] as? Array<AnyObject>)!
                
                let history_messages:Array<AnyObject> = (dict["history_messages"] as? Array<AnyObject>)!
                
                let historyMessageses:HistoryMessages = HistoryMessages()
                
                let message = Message()
                
                historyMessageses.chat_session_id = dict["chat_session_id"] as? String
                
                historyMessageses.unread_messages = message.messageMethodWithArrDict(ArrDict: unread_messages)
                
                historyMessageses.history_messages = message.messageMethodWithArrDict(ArrDict: history_messages)
                
                self?.delegate?.receiveHistoryMessages!(historyMessageses)
            })
            
            
            self?.chatHub.on("messageCallback", callback: { (args) -> () in
                
                var dict:Dictionary<String,AnyObject>! = ["":""]
                

                if let argsDic:Dictionary<String,AnyObject> = args! as? Dictionary<String,AnyObject> {
                    
                    dict = argsDic["0"] as? Dictionary<String,AnyObject>!
                    
                }else if let argsArray:[AnyObject]? = args as? [AnyObject]? {
                    
                    dict = argsArray![0] as? Dictionary
                }
                
                var message = Message()
                
                message = message.messageMethodWithDict(Dict: dict)
                
                self?.delegate?.messageCallback!(message)
            })
            
            
            //MARK:监听接收消息
            self?.chatHub.on("receiveMessage", callback: { (args) -> () in
                
                var dict:Dictionary<String,AnyObject>! = ["":""]
                
                if let argsDic:Dictionary<String,AnyObject> = args! as? Dictionary<String,AnyObject> {
                    
                    dict = argsDic["0"] as? Dictionary<String,AnyObject>!
                    
                }else if let argsArray:[AnyObject]? = args as? [AnyObject]? {
                    
                    dict = argsArray![0] as? Dictionary
                }
                
                var message = Message()
                
                message = message.messageMethodWithDict(Dict: dict)
                
                self?.delegate?.receiveMessage!(message)
                
            })
            
            //MARK:监听聊天用户(对方)在线状态
            self?.chatHub.on("chatUserStatusChanged", callback: { (args) -> () in
                
                var userstate = UserState()
                
                var dict:Dictionary<String,AnyObject>! = ["":""]
                

                if let argsDic:Dictionary<String,AnyObject> = args! as? Dictionary<String,AnyObject> {
                    
                    dict = argsDic["0"] as? Dictionary<String,AnyObject>!
                    
                }else if let argsArray:[AnyObject]? = args as? [AnyObject]? {
                    
                    dict = argsArray![0] as? Dictionary
                }
                
                userstate = userstate.userStateMethodWithDict(Dict: dict)
                
                
                self?.delegate?.chatUserStatusChanged!(userstate)
                
            })
            
            connection.connectionSlow = { print("Connection slow...") }
            
            connection.error = {
                error in print("Error: \(error)")
                
                if let source = error?["source"] as? String where source == "TimeoutException" {
                    print("Connection timed out. Restarting...")
                    connection.start()
                }
            }
        }
    }
    
    
    //MARK: 调用服务器根方法
    /**!
    @brief 调用服务器的方法
    @param methodName 服务器方法名
    @param args 服务器方法参数
    @return nil
    */
    public func invokeServiceMethod(methodName:String,args:[AnyObject]?){
        self.chatHub.invoke(methodName, arguments: args)
    }
    
    //MARK: 断开连接
    /**!
    @brief 断开连接
    @param  nil
    @return nil
    */
    public func disconnect(){
        switch hubConnection.state {
        case .Disconnected:
            connectionState = .Connected
            hubConnection.start()
        case .Connected:
            connectionState = .Disconnected
            hubConnection.stop()
        default:
            break
        }
    }
    
    
    //MARK: 调用服务器方法 - 调用用户登录
    /**!
    @brief 调用用户登录
    @param  token:用户token值
    @return nil
    */
    public func externalLogin(token:String){
        self.invokeServiceMethod("externalLogin", args: [token])
    }
    
    
    //MARK: 调用服务器方法 - 获取会话列表
    /**!
    @brief 获取会话列表
    @param  nil
    @return nil
    */
    public func getChatSessionList(){
        self.invokeServiceMethod("getChatSessionList", args: nil)
    }
    
    
    //MARK: 调用服务器方法 - 获取目标信息
    /**!
    @brief 获取目标信息
    @param  需要上传参数格式:
    {
        target_id           //目标ID
        chat_session_type   //聊天会话类型 0:用户 1:群
        chat_session_id     //聊天会话ID
    }
    @return nil
    */
    public func getTargetInfo(targetID:String,chatSessionType:String,chatSessionID:String){
        var dic:Dictionary<String,String> = Dictionary<String,String>()
        dic["target_id"] = targetID
        dic["chat_session_type"] = chatSessionType
        dic["chatSessionID"] = chatSessionID
        self.invokeServiceMethod("getTargetInfo", args: [dic])
    }
    
    //MARK: 调用服务器方法 - 获取未读信息
    /**!
    @brief 获取未读信息
    @param  需要上传参数格式:
    {
        chat_session_id     //聊天会话ID
    }
    @return nil
    */
    public func getUnreadMessages(chatSessionID:String){
        var dic:Dictionary<String,String> = Dictionary<String,String>()
        dic["chatSessionID"] = chatSessionID
        self.invokeServiceMethod("getUnreadMessages", args: [dic])
    }
    
    //MARK: 调用服务器方法 - 获取历史信息
    /**!
     @brief 获取历史信息
     @param  需要上传参数格式:
     {
     chat_session_id     //聊天会话ID
     size                //消息条数
     }
     @return nil
     */
    
    public func getHistoryMessages(chatSessionID:String,size:String){
        var dic:Dictionary<String,String> = Dictionary<String,String>()
        dic["chat_session_id"] = chatSessionID
        dic["size"] = size
        self.invokeServiceMethod("getHistoryMessages", args: [dic])
    }
    
    //MARK: 调用服务器方法 - 获取历史信息
    /**!
     @brief 获取历史信息
     @param  需要上传参数格式:
     {
     chat_session_id     //聊天会话ID
     size                //消息条数
     before_message_id   //在哪条消息之前
     }
     @return nil
     */
    
    public func getHistoryMessagesBeforeMessageID(chatSessionID:String,size:String,beforeMessageID:String){
        var dic:Dictionary<String,String> = Dictionary<String,String>()
        dic["chat_session_id"] = chatSessionID
        dic["size"] = size
        dic["before_message_id"] = beforeMessageID
        self.invokeServiceMethod("getHistoryMessages", args: [dic])
    }
    
    
    //MARK: 调用服务器方法 - 发送信息
    /**!
    @brief 发送信息
    @param  需要上传参数格式:
    {
        target_id           //发送目标的ID
        content             //发送内容
        message_token       //token,调用者随机生成
        message_type        //消息类型
    }
    @return nil
    */
    public func messageToUser(targetID:String,content:String,messageToken:String,messageType:String){
        var dic:Dictionary<String,String> = Dictionary<String,String>()
        dic["target_id"] = targetID
        dic["content"] = content
        dic["message_token"] = messageToken
        dic["messageType"] = messageType
        self.invokeServiceMethod("messageToUser", args: [dic])
    }
    
    
    //MARK: 调用服务器方法 - 确认消息
    /**!
    @brief 确认信息
    @param  需要上传参数格式:
    {
        message_id          //消息ID
        chat_session_id     //聊天会话ID
    }
    @return nil
    */
    public func confirmMessage(messageID:String,chatSessionID:String){
        var dic:Dictionary<String,String> = Dictionary<String,String>()
        dic["message_id"] = messageID
        dic["chat_session_id"] = chatSessionID
        self.invokeServiceMethod("confirmMessage", args: [dic])
    }
    
    
    //MARK: 调用服务器方法 - 心跳
    /**!
    @brief 心跳
    @param  nil
    @return nil
    */
    public func heart(){
        self.invokeServiceMethod("heart", args: nil)
    }
    
    
    
}
