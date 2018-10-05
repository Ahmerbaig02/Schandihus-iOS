//
//  Extensions.swift
//  EIPinter
//
//  Created by Mirza Ahmer Baig on 02/08/2018.
//  Copyright © 2018 Mirza Ahmer Baig. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftValidator
import NotificationBannerSwift
import SKActivityIndicatorView


extension UITableViewCell {
    static func setupTableViewCell() {
        self.appearance().textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        self.appearance().textLabel?.numberOfLines = 0
        self.appearance().detailTextLabel?.numberOfLines = 0
        self.appearance().detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0)
        self.appearance().selectionStyle = .none
    }
    
    func animate3DScaleTableViewCell() {
        self.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
        UIView.animate(withDuration: 0.3, animations: {
            self.layer.transform = CATransform3DIdentity
        }) { (success) in
            
        }
    }
}

extension UITableViewHeaderFooterView {
    static func setupTableHeaderFooterView() {
        self.appearance().textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        self.appearance().contentView.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.8)
        self.appearance().detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0)
    }
}

extension UITableView {
    
    static func setupTableView() {
        self.appearance().separatorStyle = .none
    }
    
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }
            
            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)
            
            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
                
                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }
            
            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }
            
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        return (indexPath.row > 0) && (indexPath.section > 0)
    }
}

extension UICollectionView {
    
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }
            
            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfItems(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)
            
            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfItems(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
                
                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }
            
            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }
            
            self.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        return (indexPath.row > 0) && (indexPath.section > 0)
    }
}

extension Notification.Name {
    static let NotificationFireName = Notification.Name(rawValue: "SmartTourNotifications")
}

extension UINavigationController {
    func goBackViewControllers(n: Int) {
        if n <= self.viewControllers.count && n > 0 {
            let index = self.viewControllers.count - n - 1
            _ = self.popToViewController(self.viewControllers[index], animated: true)
        }
    }
}

extension UIViewController {
    
    static var banner: StatusBarNotificationBanner?
    
    func showBanner(title: String, style: BannerStyle) {
        UIViewController.banner?.dismiss()
        UIViewController.banner = StatusBarNotificationBanner(title: title, style: style, colors: nil)
        UIViewController.banner?.show()
    }
    
    func showAlert(title: String, message:String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    class func showLoader(text: String) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        SKActivityIndicator.show(text)
    }
    
    class func hideLoader() {
        UIApplication.shared.endIgnoringInteractionEvents()
        SKActivityIndicator.dismiss()
    }
    
    func validateFieldInput(validator: Validator, textField: UITextField) {
        let textField = textField as! ConstructionTextField
        validator.validateField(textField) { (error) in
            if let err = error {
                textField.errorMessage = err.errorMessage
            } else {
                textField.errorMessage = nil
            }
        }
    }
    
    func validateFields(validator: Validator, completionHandler: @escaping (Bool) -> ()) {
        validator.validate { (errors) in
            var fields: [ConstructionTextField] = []
            for (field, error) in errors {
                if let field = field as? ConstructionTextField {
                    field.errorMessage = error.errorMessage
                    fields.append(field)
                }
            }
            for (_, rule) in validator.validations {
                if let field = rule.field as? ConstructionTextField {
                    if !fields.contains(field) {
                        field.errorMessage = nil
                    }
                }
            }
            completionHandler(fields.count == 0)
        }
    }
}



extension UIView {
    
    func getAspectedSize(Width:CGFloat, aspectRatio:CGFloat, padding:CGFloat) -> CGSize {
        
        let cellWidth = (Width ) - padding
        let cellHeight = cellWidth / aspectRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func validateFields(validator: Validator, completionHandler: @escaping (Bool) -> ()) {
        validator.validate { (errors) in
            var fields: [ConstructionTextField] = []
            for (field, error) in errors {
                if let field = field as? ConstructionTextField {
                    field.errorMessage = error.errorMessage
                    fields.append(field)
                }
            }
            for (_, rule) in validator.validations {
                if let field = rule.field as? ConstructionTextField {
                    if !fields.contains(field) {
                        field.errorMessage = nil
                    }
                }
            }
            completionHandler(fields.count == 0)
        }
    }
    
    func validateFieldInput(validator: Validator, textField: UITextField) {
        let textField = textField as! ConstructionTextField
        validator.validateField(textField) { (error) in
            if let err = error {
                textField.errorMessage = err.errorMessage
            } else {
                textField.errorMessage = nil
            }
        }
    }
    
    func setBorder( width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func underline(_ color:UIColor){
        let border = CALayer()
        let borderWidth = CGFloat(0.5)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 5.0, y: self.frame.size.height - borderWidth, width: self.frame.size.width - 10.0, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
    }
    
    func getRounded(cornerRaius:CGFloat) {
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = cornerRaius
        self.clipsToBounds = true
        
    }
    
    func giveShadow(cornerRaius:CGFloat) {
        
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRaius).cgPath
        self.layer.shadowOpacity = 0.4
    }
    
    public func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        
        _ = anchorWithReturnAnchors(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant, widthConstant: widthConstant, heightConstant: heightConstant)
    }
    
    public func anchorWithReturnAnchors(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
}





//Image View Package
extension UIImage {
    
    func getURLFor(filename: String) -> URL? {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        if let imagePath = documentsPath?.appendingPathComponent("\(filename).jpg") {
            let data = UIImageJPEGRepresentation(self, 0.5)!
            try! data.write(to: imagePath)
            return imagePath
        }
        return nil
        
//        // get the documents directory url
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        // choose a name for your image
//        let fileName = "image.jpg"
//        // create the destination file url to save your image
//        let fileURL = documentsDirectory.appendingPathComponent(fileName)
//        // get your UIImage jpeg data representation and check if the destination file url already exists
//        if let data = UIImageJPEGRepresentation(self, 0.8),
//            !FileManager.default.fileExists(atPath: fileURL.path) {
//            do {
//                // writes the image data to disk
//                try data.write(to: fileURL)
//                print("file saved")
//                return fileURL
//            } catch {
//                print("error saving file:", error)
//                return nil
//            }
//        }
//        return fileURL
    }
    
}

//Image View Package
extension UITextField{
    
}

extension UIButton {
    
    func alignTextUnderImage(spacing:CGFloat) {
        let imageSize = self.imageView!.frame.size
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -(imageSize.height + spacing), 0)
        let titleSize = self.titleLabel!.frame.size
        self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0, 0, -titleSize.width)
    }
    
    func adjustImageRightOfTitle(padding:CGFloat) {
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.frame.width - self.imageView!.frame.width, bottom: -(self.titleLabel!.frame.height - self.imageView!.frame.height + padding) , right: 0)
    }
    
    
}

// uiimage extension (package)
extension UIImage{
    
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension String {
    
    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    func age() -> Int {
        return Calendar.current.dateComponents([.year], from: Formatter.humanReadableDatewoTime.date(from: self)!, to: Date()).year!
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: 1000)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingBox.size
    }
    
    var dateFromISO8601: Date? {
        var dateStr =  self
        if !dateStr.contains(".") {
            dateStr.append(".000")
        }
        return Formatter.iso8601.date(from: dateStr)   // "Mar 22, 2017, 10:22 AM"
    }
    
}


extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone.local
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()
    
    
    static let humanReadableDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    static let humanReadableTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    static let humanReadableDatewoTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyyyy"
        formatter.timeStyle = .none
        formatter.dateStyle = .full
        return formatter
    }()
    
    static let serverDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}

extension Data {
    var format: String {
        let array = [UInt8](self)
        let ext: String
        switch (array[0]) {
        case 0xFF:
            ext = "jpg"
        case 0x89:
            ext = "png"
        case 0x47:
            ext = "gif"
        case 0x49, 0x4D :
            ext = "tiff"
        default:
            ext = "unknown"
        }
        return ext
    }
}

extension Double {
    func getRounded(uptoPlaces: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfUp
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension Date {
    
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
    var humanReadableDate: String {
        return Formatter.humanReadableDate.string(from: self)
    }
    
    var humanReadableDatewoTime: String {
        return Formatter.humanReadableDatewoTime.string(from: self)
    }
    
    var humanReadableTime: String {
        return Formatter.humanReadableTime.string(from: self)
    }
    
    
    var serverSideDate: String {
        return Formatter.serverDateFormatter.string(from: self)
    }
}

extension UILabel {
    func from(html: String) {
        if let htmlData = html.data(using: String.Encoding.unicode) {
            do {
                self.attributedText = try NSAttributedString(data: htmlData,
                                                             options: [.documentType :NSAttributedString.DocumentType.html],
                                                             documentAttributes: nil)
            } catch let e as NSError {
                print("Couldn't parse \(html): \(e.localizedDescription)")
            }
        }
    }
}

