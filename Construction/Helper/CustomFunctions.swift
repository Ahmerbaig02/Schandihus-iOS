//
//  Custom Functions.swift
//  FriendlyLimo
//
//  Crea=ted by Ahmer Baig on 28/12/2017.
//  Copyright © 2017 Ahmer Baig. All rights reserved.
//


import UIKit

func decodeObject <T: Codable>(data: Data) -> T? {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    guard let obj = try? decoder.decode(T.self, from: data) else {
        return nil
    }
    return obj
}

func encodeObject <T: Codable>(param: T) -> Data? {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    guard let obj = try? encoder.encode(param) else {
        return nil
    }
    return obj
}

func setupLocalNotification(userInfo: [String:Any]) {
    let notification = UILocalNotification()
    notification.alertBody = userInfo["subject"] as? String // text that will be displayed in the notification
    notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
    notification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date // todo item due date (when notification will be fired). immediately here
    notification.soundName = UILocalNotificationDefaultSoundName // play default sound
    UIApplication.shared.scheduleLocalNotification(notification)
}

func convertJSONToString(json: [String:Any]) -> String? {
    guard let dataFromJson = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else { return nil }
    let dataStr = String(data: dataFromJson, encoding: .utf8)
    return dataStr
}

func makeShortReadableTime(str: String) -> String {
    let timeComps = str.components(separatedBy: ":")
    if timeComps[0] > "12" {
        let convertedTime = (timeComps[0] as NSString).integerValue%12
        return "\((convertedTime == 0) ? 0 : convertedTime) :\(timeComps[1]) PM"
    } else {
        return "\(timeComps[0]):\(timeComps[1]) AM"
    }
}

func timeDifference(t1: String, t2: String) -> String {
    let time1Comps = t1.components(separatedBy: ":")
    let time2Comps = t2.components(separatedBy: ":")
    let hours = (time1Comps[0] as NSString).integerValue - (time2Comps[0] as NSString).integerValue
    let mins = (time1Comps[1] as NSString).integerValue - (time2Comps[1] as NSString).integerValue
    
    return ((hours > 0) ? "\(hours) hr(s) " : "") + ((mins > 0) ? "\(mins) min(s) " : "")
}

func convertStringToJSON(jsonString: String) -> Any? {
    guard let dataFromJsonString = jsonString.data(using: .utf8) else { return nil }
    guard let json = try? JSONSerialization.jsonObject(with: dataFromJsonString, options: .mutableContainers) else { return nil }
    return json
}


func getBase64DataFromImage(image:UIImage) -> String {
    let data = NSData(data: UIImageJPEGRepresentation(image,0.7)!)
    let imgPNG = UIImage(data: data as Data)
    let dataPNGImg = NSData(data: UIImagePNGRepresentation(imgPNG!)!)
    let base64String = dataPNGImg.base64EncodedString(options: .lineLength64Characters)
    let container = "data:image/png;base64,\(base64String)"
    //print(container)
    return container
}
/*
func clearImageFromCache(image_url: URL) {
    let cacheKey = PINRemoteImageManager.shared().cacheKey(for: image_url, processorKey: nil)
    PINRemoteImageManager.shared().cache.removeObject(forKey: cacheKey, block: nil)
}*/


func getAttributedText(Titles:[String], Font:[UIFont],Colors:[UIColor], seperator:[String], Spacing:CGFloat,atIndex:Int, alignment: NSTextAlignment? = nil) -> NSAttributedString {
    
    var attr_text:NSMutableAttributedString!
    var location:Int = 0
    
    for (index,currentTitle) in Titles.enumerated() {
        
        if index > 0 {
            location = attr_text.string.count
            
            let text = NSMutableAttributedString(attributedString: NSAttributedString(string: currentTitle, attributes: [NSAttributedStringKey.foregroundColor :Colors[index], kCTFontAttributeName as NSAttributedStringKey:Font[index]]))
            
            attr_text.append(text)
        } else {
            
            attr_text = NSMutableAttributedString(attributedString: NSAttributedString(string: currentTitle, attributes: [NSAttributedStringKey.foregroundColor :Colors[index], NSAttributedStringKey.font :Font[index]]))
            
        }
        
        if Spacing > 0.0 && atIndex == index {
            let spacing = NSMutableParagraphStyle()
            spacing.lineSpacing = Spacing
            attr_text.addAttribute(kCTParagraphStyleAttributeName as NSAttributedStringKey, value: spacing, range: NSRange(location: location, length: attr_text.string.count - 1))
        }
        
        if let alignment = alignment {
            let spacing = NSMutableParagraphStyle()
            spacing.alignment = alignment
            if Spacing > 0 {
                spacing.lineSpacing = Spacing
            }
            attr_text.addAttribute(kCTParagraphStyleAttributeName as NSAttributedStringKey, value: spacing, range: NSRange(location: 0, length: attr_text.string.count - 1))
        }
        
        attr_text.append(NSAttributedString(string: seperator[index]))
    }
    
    return attr_text
    
}

func getCellHeaderSize(Width:CGFloat, aspectRatio:CGFloat, padding:CGFloat) -> CGSize {
    
    let cellWidth = (Width ) - padding
    let cellHeight = cellWidth / aspectRatio
    
    return CGSize(width: cellWidth, height: cellHeight)
    
}


