//
//  Xperio.swift
//  Xperio
//
//  Created by Ozan Uysal on 17.07.2018.
//  Copyright © 2018 Appcent. All rights reserved.
//

import UIKit

enum UserDefaultsKey: String {
    case SessionId = "xSessionId"
    case LifeTimeId = "xLifeTimeId"
    case PushToken = "xPushToken"
}

class Xperio: NSObject {
    
    private static var serverUrl : String!
    private static var appId : String!
    private static var sessionId : String!
    
    static func config(serverUrl : String, appId : String) {
        self.serverUrl = serverUrl
        self.appId = appId
        sessionId = UUID.init().uuidString
        let lifeTimeId = UserDefaults.standard.string(forKey: UserDefaultsKey.LifeTimeId.rawValue) ?? ""
        if lifeTimeId.isEmpty {
            UserDefaults.standard.set(UUID.init().uuidString, forKey: UserDefaultsKey.LifeTimeId.rawValue)
        }
    }
    
    static func setPushToken(deviceToken : Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        UserDefaults.standard.set(token, forKey: UserDefaultsKey.PushToken.rawValue)
    }
    
    static func sessionStart(activity : String, lastActivity : String, userId : String = "") {
        var params = Dictionary<String, Dictionary<String, String>>()
        params["h"] = h(action: "SS")
        var b = Dictionary<String, String>()
        b["activity"] = activity
        b["rf"] = lastActivity
        b["userId"] = userId
        b["os"] = "iOS \(UIDevice.current.systemVersion)"
        b["id"] = UIDevice.current.identifierForVendor?.uuidString
        b["token"] = UserDefaults.standard.string(forKey: UserDefaultsKey.PushToken.rawValue) ?? ""
        params["b"] = b
        makeRequest(params: params)
    }
    
    static func pageView(activity : String, lastActivity : String, events : Dictionary<String, Any> = Dictionary<String, Any>(), userId : String = "") {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "PV")
        var b = Dictionary<String, Any>()
        for (key,value) in events {
            b[key] = value
        }
        b["activity"] = activity
        b["rf"] = lastActivity
        if userId.isEmpty == false {
            b["userId"] = userId
        }
        params["b"] = b
        makeRequest(params: params)
    }
    
    static func customEvent(eventName : String, events : Dictionary<String, Any> = Dictionary<String, Any>(), userId : String = "") {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: eventName)
        var b = Dictionary<String, Any>()
        for (key,value) in events {
            b[key] = value
        }
        if userId.isEmpty == false {
            b["userId"] = userId
        }
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
            print("Xperio : Url misconfig")
            return
        }
        print(url)
        print(params)
        var r  = URLRequest(url: url)
        r.httpMethod = "POST"
        r.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            print("Xperio : Json parse error")
            return
        }
        let jsonString = String(data: jsonData, encoding: .utf8)
        guard let escapedString = jsonString?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            print("Xperio : Url encoding error")
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
