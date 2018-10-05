//
//  AddEstimateSettingsVC.swift
//  Construction
//
//  Created by Mirza Ahmer Baig on 05/10/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit

class AddEstimateSettingsVC: UIViewController {

    @IBOutlet var maxPriceSwitch: UISwitch!
    @IBOutlet var discountSwitch: UISwitch!
    
    
    weak var controller: AddEstimateVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.maxPriceSwitch.isOn = controller.isMaxPrice
        self.discountSwitch.isOn = controller.isDiscount
    }
    
    @IBAction func discountSwitchAction(_ sender: Any) {
        controller.isDiscount = !controller.isDiscount
    }
    
    @IBAction func maxPriceAction(_ sender: Any) {
        controller.isMaxPrice = !controller.isMaxPrice
    }
    
    deinit {
        print("AddEstimateSettingsVC deinit")
    }
}
