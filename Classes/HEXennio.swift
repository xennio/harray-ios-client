//
//  HEXennio.swift
//  HEXennio
//
//  Created by Hurriyet Emlak on 15.04.2019.
//  Copyright © 2019 Hurriyet Emlak. All rights reserved.
//

import UIKit

enum UserDefaultsKey: String {
    case SessionId = "xSessionId"
    case LifeTimeId = "xLifeTimeId"
    case PushToken = "xPushToken"
}

@objc public class HEXennioBeater: NSObject {
    
    private static var timer: Timer?
    
    @objc public static func enable() {
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeTimer), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        initTimer()
    }
    
    @objc private static func initTimer() {
        HEXennioBeater.timer = Timer.scheduledTimer(timeInterval: 55, target: self, selector: #selector(HEXennioBeater.beat), userInfo: nil, repeats: true)
    }
    
    @objc private static func beat() {
        HEXennio.heartBeat()
    }
    
    @objc private static func pauseTimer() {
        HEXennioBeater.timer?.invalidate()
    }
    
    @objc private static func resumeTimer() {
        HEXennioBeater.initTimer()
    }
}

@objc public class HEXennio: NSObject {
    
    private static var serverUrl : String!
    private static var appId : String!
    private static var sessionId : String!
    
    @objc public static func heartBeat() {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "HB")
        let b = Dictionary<String, Any>()
        params["b"] = b
        makeRequest(params: params)
    }
    
    @objc public static func config(serverUrl : String, appId : String) {
        self.serverUrl = serverUrl
        self.appId = appId
        sessionId = UUID.init().uuidString
        let lifeTimeId = UserDefaults.standard.string(forKey: UserDefaultsKey.LifeTimeId.rawValue) ?? ""
        if lifeTimeId.isEmpty {
            UserDefaults.standard.set(UUID.init().uuidString, forKey: UserDefaultsKey.LifeTimeId.rawValue)
        }
    }
    
    @objc public static func sessionStart(activity : String = "", lastActivity : String = "", customParams : Dictionary<String, Any> = Dictionary<String, Any>()) {
        print("#### HEXennio SS")
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "SS")
        var b = Dictionary<String, Any>()
        for (key,value) in customParams {
            b[key] = value
        }
        b["activity"] = activity
        b["rf"] = lastActivity
        b["os"] = "iOS \(UIDevice.current.systemVersion)"
        b["id"] = UIDevice.current.identifierForVendor?.uuidString
        params["b"] = b
        makeRequest(params: params)
    }
    
    @objc public static func pageView(pageType : String, lastActivity : String = "", customParams : Dictionary<String, Any> = Dictionary<String, Any>()) {
        print("#### HEXennio PV # pageType: \(pageType), customParams: \(customParams)")
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "PV")
        var b = Dictionary<String, Any>()
        for (key,value) in customParams {
            b[key] = value
        }
        b["pageType"] = pageType
        b["rf"] = lastActivity
        params["b"] = b
        makeRequest(params: params)
    }
    
    @objc public static func impression(pageType : String, lastActivity : String = "", customParams : Dictionary<String, Any> = Dictionary<String, Any>()) {
        print("#### HEXennio IM # pageType: \(pageType), customParams: \(customParams)")
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "IM")
        var b = Dictionary<String, Any>()
        for (key,value) in customParams {
            b[key] = value
        }
        b["pageType"] = pageType
        b["rf"] = lastActivity
        params["b"] = b
        makeRequest(params: params)
    }
    
    @objc public static func actionResult(pageType : String, type: String, conversationType: String? = nil, customParams : Dictionary<String, Any> = Dictionary<String, Any>()) {
        if let conversationType = conversationType {
            print("#### HEXennio AR # pageType: \(pageType), type: \(type), conversationType: \(conversationType), customParams: \(customParams)")
        } else {
            print("#### HEXennio AR # pageType: \(pageType), type: \(type), customParams: \(customParams)")
        }
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "AR")
        var b = Dictionary<String, Any>()
        for (key,value) in customParams {
            b[key] = value
        }
        b["pageType"] = pageType
        b["type"] = type
        b["conversationType"] = conversationType
        params["b"] = b
        makeRequest(params: params)
    }
    
    @objc public static func savePushToken(deviceToken : String, customParams : Dictionary<String, Any> = Dictionary<String, Any>()) {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "Collection")
        var b = Dictionary<String, Any>()
        for (key,value) in customParams {
            b[key] = value
        }
        b["name"] = "pushToken"
        b["type"] = "iosToken"
        b["appType"] = "iosAppPush"
        b["name"] = "pushToken"
        b["deviceToken"] = deviceToken
        
        params["b"] = b
        makeRequest(params: params)
    }
    
    // private functions
    private static func isConfigured() -> Bool {
        return serverUrl != nil && appId != nil
    }
    
    private static func h(action : String) -> Dictionary<String, String> {
        let lifeTimeId = UserDefaults.standard.string(forKey: UserDefaultsKey.LifeTimeId.rawValue) ?? ""
        var dict = Dictionary<String, String>()
        dict["n"] = action
        dict["p"] = lifeTimeId
        dict["s"] = sessionId
        return dict
    }
    
    private static func makeRequest(params : Dictionary<String, Dictionary<String, Any>>) {
        if isConfigured() == false {
            fatalError("Please call config() first")
        }
        guard let url = URL(string: "\(serverUrl!)/\(appId!)") else {
            print("HEXennio : Url misconfig")
            return
        }
        print(url)
        print(params)
        var r  = URLRequest(url: url)
        r.httpMethod = "POST"
        r.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            print("HEXennio : Json parse error")
            return
        }
        let jsonString = String(data: jsonData, encoding: .utf8)
        guard let escapedString = jsonString?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            print("HEXennio : Url encoding error")
            return
        }
        let base64 = Data(escapedString.utf8).base64EncodedString()
        print("e=\(base64)")
        let d = "e=\(base64)".data(using:String.Encoding.ascii, allowLossyConversion: false)
        r.httpBody = d
        let task = URLSession.shared.dataTask(with: r) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    // tools
    
    
}
