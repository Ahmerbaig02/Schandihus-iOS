////
//  PDFViewVCViewController.swift
//  Construction
//
//  Created by CodeX on 20/10/2018
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit
import WebKit

class PDFViewVC: UIViewController {
    
    @IBOutlet var webKitView: WKWebView!
    
    var vendor: VendorData!
    var estimate: EstimateData!
    
    var docController: UIDocumentInteractionController!
    
    var invoiceComposer: InvoiceComposer!
    var HTMLContent: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PDF Preview"
        self.setupRightBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.webKitView?.loadHTMLString(HTMLContent, baseURL: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.webKitView.stopLoading()
    }
    
    fileprivate func setupRightBarButton() {
        let barItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_share"), style: .done, target: self, action: #selector(shareAction(_:)))
        barItem.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItems = [barItem]
    }
    
    @objc fileprivate func shareAction(_ sender: Any) {
        if self.estimate == nil {
            invoiceComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent, filename: "vendor_\(self.vendor.vendorId ?? 0)")
        } else {
            invoiceComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent, filename: "estimate_\(self.estimate.estimateId ?? 0)")
        }
        showOptionsAlert()
    }
    
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Yeah!", message: "Your invoice has been successfully printed to a PDF file.\n\nWhat do you want to do now?", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionPreview = UIAlertAction(title: "Preview", style: UIAlertActionStyle.default) { (action) in
            if let filename = self.invoiceComposer.pdfFilename {
                let url = URL(fileURLWithPath: filename)
                self.docController = UIDocumentInteractionController(url: url)
                self.docController.delegate = self
                self.docController.presentPreview(animated: true)
            }
        }
        
        let actionNothing = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        alertController.addAction(actionPreview)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        print("PDFViewVC deinit")
    }
}

extension PDFViewVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        
        self.docController = nil
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
}
