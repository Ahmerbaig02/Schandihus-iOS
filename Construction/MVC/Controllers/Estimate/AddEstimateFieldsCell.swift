//
//  AddEstimateFieldsCell.swift
//  Construction
//
//  Created by Mahnoor Fatima on 04/10/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import SwiftValidator

protocol EstimateDelegate: class {
    func EstimateDetails(cell: AddEstimateFieldsCell)
}

class AddEstimateFieldsCell: UITableViewCell {

    weak var delegate: EstimateDelegate?
    @IBOutlet weak var estimateNameTF: ConstructionTextField!
    @IBOutlet weak var estimateDateTF: ConstructionTextField!
    @IBOutlet weak var closingDateTF: ConstructionTextField!
    @IBOutlet weak var priceGuaranteeDateTF: ConstructionTextField!
    
    var validator: Validator!
    var estimateName: String = ""
    var estimateDate: String = ""
    var closingDate: String = ""
    var priceGuaranteeDate: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupPickers()
        estimateDateTF.text = Date().humanReadableDate
        self.estimateDate = Date().serverSideDate
        closingDateTF.text = Date().humanReadableDate
        self.closingDate = Date().serverSideDate
        priceGuaranteeDateTF.text = Date().humanReadableDate
        self.priceGuaranteeDate = Date().serverSideDate
    }
    
    fileprivate func setupPickers() {
        
        self.estimateNameTF.delegate = self
        
        let estimateDatePicker = UIDatePicker()
        estimateDatePicker.minimumDate = Date()
        estimateDatePicker.addTarget(self, action: #selector(estimateDatePickerAction(_:)), for: .valueChanged)
        self.estimateDateTF.delegate = self
        self.estimateDateTF.inputView = estimateDatePicker
        
        let closingDatePicker = UIDatePicker()
        closingDatePicker.minimumDate = Date()
        closingDatePicker.addTarget(self, action: #selector(closingDatePickerAction(_:)), for: .valueChanged)
        self.closingDateTF.delegate = self
        self.closingDateTF.inputView = closingDatePicker
        
        let priceDatePicker = UIDatePicker()
        priceDatePicker.minimumDate = Date()
        priceDatePicker.addTarget(self, action: #selector(priceGuaranteedDatePickerAction(_:)), for: .valueChanged)
        self.priceGuaranteeDateTF.delegate = self
        self.priceGuaranteeDateTF.inputView = priceDatePicker
    }
    
    @objc func estimateDatePickerAction(_ sender: UIDatePicker) {
        self.estimateDateTF.text = sender.date.humanReadableDate
        self.estimateDate = sender.date.serverSideDate
        delegate?.EstimateDetails(cell: self)
    }
    
    @objc func closingDatePickerAction(_ sender: UIDatePicker) {
        self.closingDateTF.text = sender.date.humanReadableDate
        self.closingDate = sender.date.serverSideDate
        delegate?.EstimateDetails(cell: self)
    }
    
    @objc func priceGuaranteedDatePickerAction(_ sender: UIDatePicker) {
        self.priceGuaranteeDateTF.text = sender.date.humanReadableDate
        self.priceGuaranteeDate = sender.date.serverSideDate
        delegate?.EstimateDetails(cell: self)
    }
    
    deinit {
        print("deinit AddEstimateFieldsCell")
    }
}

extension AddEstimateFieldsCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.validateFieldInput(validator: validator, textField: textField)
        delegate?.EstimateDetails(cell: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validateFieldInput(validator: validator, textField: textField)
        delegate?.EstimateDetails(cell: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == estimateNameTF {
            estimateName = textField.text!
            estimateDateTF.becomeFirstResponder()
        } else if textField == estimateDateTF {
            estimateDate = textField.text!
            closingDateTF.becomeFirstResponder()
        } else if textField == closingDateTF {
            closingDate = textField.text!
            priceGuaranteeDateTF.becomeFirstResponder()
        } else {
            priceGuaranteeDate = textField.text!
            textField.resignFirstResponder()
        }
        self.validateFieldInput(validator: validator, textField: textField)
        delegate?.EstimateDetails(cell: self)
        return true
    }
}
