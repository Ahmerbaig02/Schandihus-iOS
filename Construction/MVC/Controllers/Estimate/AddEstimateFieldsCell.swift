//
//  AddEstimateFieldsCell.swift
//  Construction
//
//  Created by Mahnoor Fatima on 04/10/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit

class AddEstimateFieldsCell: UITableViewCell {

    @IBOutlet weak var estimateNameTF: ConstructionTextField!
    @IBOutlet weak var estimateDateTF: ConstructionTextField!
    @IBOutlet weak var closingDateTF: ConstructionTextField!
    @IBOutlet weak var priceGuaranteeDateTF: ConstructionTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupPickers()
    }
    
    func setupPickers() {
        let estimateDatePicker = UIDatePicker()
        estimateDatePicker.addTarget(self, action: #selector(estimateDatePickerAction(_:)), for: .valueChanged)
        self.estimateDateTF.inputView = estimateDatePicker
        
        let closingDatePicker = UIDatePicker()
        closingDatePicker.addTarget(self, action: #selector(closingDatePickerAction(_:)), for: .valueChanged)
        self.closingDateTF.inputView = closingDatePicker
        
        let priceDatePicker = UIDatePicker()
        priceDatePicker.addTarget(self, action: #selector(priceDatePickerAction(_:)), for: .valueChanged)
        self.priceGuaranteeDateTF.inputView = priceDatePicker
    }
    
    @objc func estimateDatePickerAction(_ sender: UIDatePicker) {
        self.estimateDateTF.text = sender.date.serverSideDate
    }
    
    @objc func closingDatePickerAction(_ sender: UIDatePicker) {
        self.closingDateTF.text = sender.date.serverSideDate
    }
    
    @objc func priceDatePickerAction(_ sender: UIDatePicker) {
        self.priceGuaranteeDateTF.text = sender.date.serverSideDate
    }
    
    deinit {
        print("deinit AddEstimateFieldsCell")
    }
}
