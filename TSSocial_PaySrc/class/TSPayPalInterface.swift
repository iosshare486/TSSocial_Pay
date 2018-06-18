//
//  TSPayPalInterface.swift
//  TSSocial_Pay
//
//  Created by 彩球 on 2018/6/18.
//  Copyright © 2018年 caiqr. All rights reserved.
//

import Foundation

protocol TSPaypalInterface {
    
    var paypalPaymentSuccess: (()-> Void)? {get set}
    var paypalPaymentFail: ((String) -> Void)? {get set}
    var checkPaypalPayment: ((String) -> (Bool))? {get set}
    
    static func persionalInit() -> TSPaypalInterface
    func sendPayPalPayment(money_type: String, amount: String, description: String, launchVC: UIViewController)
    
    
    
}
