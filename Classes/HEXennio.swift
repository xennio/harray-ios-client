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

@objc public class HEXennioBody: NSObject {

    var pageType: String?
    var type: String?
    var conversionType: String?
    var memberId: String?
    var ownerId: String?
    var ID: String?
    var collection: Array<String>?
    var price: String?
    var page: String?
    var logType: String?

    var mainCategory: Array<String>?
    var category: Array<String>?
    var subCategory: Array<String>?
    var city: Array<String>?
    var county: Array<String>?
    var district: Array<String>?
    var ownerType: Array<String>?

    var searchKeyword: String?
    var sortType: String?
    var sortDirection: String?
    var breadCrumb: String?
    var URL: String?
    var campaignID: String?
    var utm_source: String?
    var utm_medium: String?
    var utm_campaign: String?
    var utm_term: String?
    var utm_content: String?
    var notificationID: String?
    var gclid: String?
    var rf: String?
    var lat: String?
    var lng: String?
    
    var email: String?
    var currency: String?

    @objc public init(pageType: String? = nil, type: String? = nil, conversionType: String? = nil, memberId: String? = nil, ownerId: String? = nil, ID: String? = nil, collection: Array<String>? = nil, price: String? = nil, page: String? = nil, logType: String? = nil, mainCategory: String? = nil, category: Array<String>? = nil, subCategory: Array<String>? = nil, city: String? = nil, county: Array<String>? = nil, district: Array<String>? = nil, ownerType: String? = nil, searchKeyword: String? = nil, sortType: String? = nil, sortDirection: String? = nil, breadCrumb: String? = nil, URL: String? = nil, campaignID: String? = nil, utm_source: String? = nil, utm_medium: String? = nil, utm_campaign: String? = nil, utm_term: String? = nil, utm_content: String? = nil, notificationID: String? = nil, gclid: String? = nil, rf: String? = nil, lat: String? = nil, lng: String? = nil, email: String? = nil, currency: String? = nil) {

        self.pageType = pageType
        self.type = type
        self.conversionType = conversionType
        self.memberId = memberId
        self.ownerId = ownerId
        self.ID = ID
        self.collection = collection
        self.price = price
        self.page = page
        self.logType = logType

        self.mainCategory = (mainCategory == nil ? nil : [mainCategory!])
        self.category = category
        self.subCategory = subCategory
        self.city = (city == nil ? nil : [city!])
        self.county = county
        self.district = district
        self.ownerType = (ownerType == nil ? nil : [ownerType!])

        self.searchKeyword = searchKeyword
        self.sortType = sortType
        self.sortDirection = sortDirection
        self.breadCrumb = breadCrumb
        self.URL = URL
        self.campaignID = campaignID
        self.utm_source = utm_source
        self.utm_medium = utm_medium
        self.utm_campaign = utm_campaign
        self.utm_term = utm_term
        self.utm_content = utm_content
        self.notificationID = notificationID
        self.gclid = gclid
        self.rf = rf
        self.lat = lat
        self.lng = lng
        
        self.email = email
        self.currency = currency
    }

    func getParamsDict() -> Dictionary<String, Any> {
        var dictParams = Dictionary<String, Any>()

        dictParams["pageType"] = self.pageType
        dictParams["type"] = self.type
        dictParams["conversionType"] = self.conversionType
        dictParams["memberId"] = self.memberId
        dictParams["ownerId"] = self.ownerId
        dictParams["id"] = self.ID
        dictParams["collection"] = self.collection
        dictParams["price"] = self.price
        dictParams["page"] = self.page
        dictParams["logType"] = self.logType

        dictParams["filter2"] = self.mainCategory
        dictParams["filter1"] = self.category
        dictParams["filter3"] = self.subCategory
        dictParams["filter4"] = self.city
        dictParams["filter5"] = self.county
        dictParams["filter6"] = self.district
        dictParams["filter7"] = self.ownerType

        dictParams["searchKeyword"] = self.searchKeyword
        dictParams["sortType"] = self.sortType
        dictParams["sortDirection"] = self.sortDirection
        dictParams["breadCrumb"] = self.breadCrumb
        dictParams["url"] = self.URL
        dictParams["campaignID"] = self.campaignID
        dictParams["utm_source"] = self.utm_source
        dictParams["utm_medium"] = self.utm_medium
        dictParams["utm_campaign"] = self.utm_campaign
        dictParams["utm_term"] = self.utm_term
        dictParams["utm_content"] = self.utm_content
        dictParams["notificationID"] = self.notificationID
        dictParams["gclid"] = self.gclid
        dictParams["rf"] = self.rf
        dictParams["lat"] = self.lat
        dictParams["lng"] = self.lng
        
        dictParams["email"] = self.email
        dictParams["currency"] = self.currency

        dictParams = dictParams.filter { (($0.value != nil) && (($0.value as? String) != "" ) && (($0.value as? Array<String>)?.count != 0)) }

        return dictParams
    }
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

    private static var serverUrl: String!
    private static var appId: String!
    private static var sessionId: String!

    @objc public static func heartBeat() {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "HB")
        let b = Dictionary<String, Any>()
        params["b"] = b
        makeRequest(params: params)
    }

    @objc public static func config(serverUrl: String, appId: String) {
        self.serverUrl = serverUrl
        self.appId = appId
        sessionId = UUID.init().uuidString
        let lifeTimeId = UserDefaults.standard.string(forKey: UserDefaultsKey.LifeTimeId.rawValue) ?? ""
        if lifeTimeId.isEmpty {
            UserDefaults.standard.set(UUID.init().uuidString, forKey: UserDefaultsKey.LifeTimeId.rawValue)
        }
    }

    @objc public static func sessionStart(hexennioBody: HEXennioBody) {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "SS")
        var b = Dictionary<String, Any>()
        b["os"] = "iOS \(UIDevice.current.systemVersion)"
        b["id"] = UIDevice.current.identifierForVendor?.uuidString
        params["b"] = b
        print("##HEXennio params: \(params)")
        makeRequest(params: params)
    }

    @objc public static func pageView(hexennioBody: HEXennioBody) {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "PV")
        params["b"] = hexennioBody.getParamsDict()
        print("##HEXennio params: \(params)")
        makeRequest(params: params)
    }

    @objc public static func impression(hexennioBody: HEXennioBody) {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "IM")
        params["b"] = hexennioBody.getParamsDict()
        print("##HEXennio params: \(params)")
        makeRequest(params: params)
    }

    @objc public static func actionResult(hexennioBody: HEXennioBody) {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "AR")
        params["b"] = hexennioBody.getParamsDict()
        print("##HEXennio params: \(params)")
        makeRequest(params: params)
    }

    @objc public static func savePushToken(deviceToken: String, hexennioBody: HEXennioBody) {
        var params = Dictionary<String, Dictionary<String, Any>>()
        params["h"] = h(action: "Collection")
        var b = Dictionary<String, Any>()
        for (key, value) in hexennioBody.getParamsDict() {
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

    private static func h(action: String) -> Dictionary<String, String> {
        let lifeTimeId = UserDefaults.standard.string(forKey: UserDefaultsKey.LifeTimeId.rawValue) ?? ""
        var dict = Dictionary<String, String>()
        dict["n"] = action
        dict["p"] = lifeTimeId
        dict["s"] = sessionId
        return dict
    }

    private static func makeRequest(params: Dictionary<String, Dictionary<String, Any>>) {
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
        let d = "e=\(base64)".data(using: String.Encoding.ascii, allowLossyConversion: false)
        r.httpBody = d
        let task = URLSession.shared.dataTask(with: r) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }

    // tools


}
