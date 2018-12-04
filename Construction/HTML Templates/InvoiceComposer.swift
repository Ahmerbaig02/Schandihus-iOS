//
//  InvoiceComposer.swift
//  Print2PDF
//
//  Created by Gabriel Theodoropoulos on 23/06/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class InvoiceComposer: NSObject {

    let pathToInvoiceHTMLTemplate = Bundle.main.path(forResource: "invoice", ofType: "html")
    let pathToEstimateInvoiceHTMLTemplate = Bundle.main.path(forResource: "invoice_estimate", ofType: "html")
    
    let pathToSingleItemHTMLTemplate = Bundle.main.path(forResource: "single_item", ofType: "html")
    let pathToEstimateSingleItemHTMLTemplate = Bundle.main.path(forResource: "estimate_single_item", ofType: "html")
    
    let pathToLastItemHTMLTemplate = Bundle.main.path(forResource: "last_item", ofType: "html")
    
    let senderInfo = "\(LookupData.shared?.companyInfo?.COMPANY_BANK_NAME ?? "")<br>\(LookupData.shared?.companyInfo?.COMPANY_ADDRESS?.replacingOccurrences(of: ",", with: "<br>") ?? "")"
    
    let dueDate = ""
    
    var invoiceNumber: String!
    
    var pdfFilename: String!
    
    
    override init() {
        super.init()
    }
    
    
    func renderInvoiceEstimate(invoiceDate: String, estimate: EstimateData, products: [ProductData], prospect: ProspectData) -> String! {
        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToEstimateInvoiceHTMLTemplate!)
            
            
            // Invoice date.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INVOICE_DATE#", with: invoiceDate)
            
            // Receiver info.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#BILL To#", with: prospect.prospectName ?? "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#BILL Address#", with: prospect.homeAddress ?? "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Estimate ID#", with: "\(estimate.estimateId ?? 0)")
            
            var productsHTML = ""
            for product in products {
                var itemHTMLContent = try String(contentsOfFile: pathToEstimateSingleItemHTMLTemplate!)
                
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#Name#", with: product.name ?? "")
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#Quantity#", with: "\(product.quantity ?? 0)")
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#Price#", with: "€ \(product.minimumRetailPrice ?? 0)")
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#Amount#", with: "€ \((product.quantity ?? 0) * (product.minimumRetailPrice ?? 0))")
                productsHTML += itemHTMLContent
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Products data#", with: productsHTML)
            
            let subTotalAmount = products.reduce(0) { (res, product) -> Int in
                return res + ((product.quantity ?? 0) * (product.minimumRetailPrice ?? 0))
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VAT#", with: "€ ")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Sub Total#", with: "€ \(subTotalAmount)")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Grand Total#", with: "€ \(subTotalAmount)")
            
            // The HTML code is ready.
            return HTMLContent
            
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        
        return nil
    }
    
    func renderInvoice(invoiceDate: String, estimateTitles: [String], estimateDescripts: [String], prospectTitles: [String], prospectDescripts: [String], items: [[String: String]], isEstimate: Bool = false) -> String! {
        // Store the invoice number for future use.
//        self.invoiceNumber = invoiceNumber
        
        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToInvoiceHTMLTemplate!)
            
            // Replace all the placeholders with real values except for the items.
            // The logo image.
            
            // Invoice number.
//            HTMLContent = HTMLContent.replacingOccurrences(of: "#INVOICE_NUMBER#", with: invoiceNumber)
            
            // Invoice date.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INVOICE_DATE#", with: invoiceDate)
            
            // Due date (we leave it blank by default).
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DUE_DATE#", with: dueDate)
            
            // Sender info.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SENDER_INFO#", with: senderInfo)
            
            // Recipient info.
//            HTMLContent = HTMLContent.replacingOccurrences(of: "#RECIPIENT_INFO#", with: recipientInfo.replacingOccurrences(of: "\n", with: "<br>"))
            
            // Payment method.
            
            // Total amount.
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Prospect Info#", with: isEstimate ? "Prospect Info" : "Bank Info")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Estimate Info#", with: isEstimate ? "Estimate Info" : "Vendor Info")
            
            let totalAmount = items.reduce(0.0) { (res, dict) -> Double in
                return res + (dict.values.first as NSString?)!.doubleValue
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTAL_AMOUNT#", with:  totalAmount.getRounded(uptoPlaces: 2))
            
            var estimateInfo = ""
            for i in 0..<estimateTitles.count {
                var itemHTMLContent: String!
                
                // Determine the proper template file.
                if i != estimateTitles.count - 1 {
                    itemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
                }
                else {
                    itemHTMLContent = try String(contentsOfFile: pathToLastItemHTMLTemplate!)
                }
                let color = (i % 2 == 0) ? "background:#EFEFF4;" : "background:#FFFFFF;"
                // Replace the description and price placeholders with the actual values.
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with: estimateTitles[i]).replacingOccurrences(of: "background:", with: color)
                
                // Format each item's price as a currency value.
                let formattedPrice = estimateDescripts[i]
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#PRICE#", with: formattedPrice)
                
                // Add the item's HTML code to the general items string.
                estimateInfo += itemHTMLContent
            }
            let eItemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
            estimateInfo+=eItemHTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with: "").replacingOccurrences(of: "#PRICE#", with: "").replacingOccurrences(of: "background:", with: "background:#FFFFFF;")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Estimate#", with: estimateInfo)
            
            var prospectInfo = ""
            
            for i in 0..<prospectTitles.count {
                var itemHTMLContent: String!
                
                // Determine the proper template file.
                if i != prospectTitles.count - 1 {
                    itemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
                }
                else {
                    itemHTMLContent = try String(contentsOfFile: pathToLastItemHTMLTemplate!)
                }
                let color = (i % 2 == 0) ? "background:#EFEFF4;" : "background:#FFFFFF;"
                // Replace the description and price placeholders with the actual values.
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with: prospectTitles[i]).replacingOccurrences(of: "background:", with: color)
                
                // Format each item's price as a currency value.
                let formattedPrice = prospectDescripts[i]
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#PRICE#", with: formattedPrice)
                
                // Add the item's HTML code to the general items string.
                prospectInfo += itemHTMLContent
            }
            let pItemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
            prospectInfo+=pItemHTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with: "").replacingOccurrences(of: "#PRICE#", with: "").replacingOccurrences(of: "background:", with: "background:#FFFFFF;")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Prospect#", with: prospectInfo)
            
            // The invoice items will be added by using a loop.
            var allItems = ""
            
            // For all the items except for the last one we'll use the "single_item.html" template.
            // For the last one we'll use the "last_item.html" template.
            for i in 0..<items.count {
                var itemHTMLContent: String!
                
                // Determine the proper template file.
                if i != items.count - 1 {
                    itemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
                }
                else {
                    itemHTMLContent = try String(contentsOfFile: pathToLastItemHTMLTemplate!)
                }
                let color = (i % 2 == 0) ? "background:#EFEFF4;" : "background:#FFFFFF;"
                // Replace the description and price placeholders with the actual values.
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with: items[i].keys.first!).replacingOccurrences(of: "background:", with: color)
                
                // Format each item's price as a currency value.
                let formattedPrice = items[i].values.first!
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#PRICE#", with: formattedPrice)
                
                // Add the item's HTML code to the general items string.
                allItems += itemHTMLContent
            }
            let aItemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
            allItems+=aItemHTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with: "").replacingOccurrences(of: "#PRICE#", with: "").replacingOccurrences(of: "background:", with: "background:#FFFFFF;")
            // Set the items.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: allItems)
            
            // The HTML code is ready.
            return HTMLContent
            
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        
        return nil
    }
    
    func exportHTMLContentToPDF(HTMLContent: String, filename: String) {
        let printPageRenderer = CustomPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
        pdfFilename = "\(AppDelegate.getAppDelegate().getDocDir())/\(filename).pdf"
        pdfData?.write(toFile: pdfFilename, atomically: true)
        
        print(pdfFilename)
    }
    
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return data
    }
    
}
