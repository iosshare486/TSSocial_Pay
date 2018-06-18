//
//  TSPayPal.swift
//  TSSocial_Pay
//
//  Created by 彩球 on 2018/6/18.
//  Copyright © 2018年 caiqr. All rights reserved.
//

import UIKit

enum TSPayPalEnvironment {
    case product, sandbox
}

class TSPayPal: NSObject,TSPaypalInterface {
    
    
    static let `default`: TSPayPal = TSPayPal()
    private override init() {
        super.init()
    }
    
    /// 使用者不需要调用
    static func persionalInit() -> TSPaypalInterface {
        return TSPayPal.default
    }
    
    /// 不需要使用者实现
    var paypalPaymentSuccess: (()-> Void)?
    /// 不需要使用者实现
    var paypalPaymentFail: ((String) -> Void)?
    
    
    /// 配置PayPal成功后检验凭证
    var checkPaypalPayment: ((String) -> Bool)?
    
    /// 配置PayPal支付环境
    var paypalEnvironment: TSPayPalEnvironment = .product
    
    /// 注册PayPal信息
    class func registerPayPalProductId(environmentProduction: String, environmentSandbox: String) {
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: environmentProduction,
         PayPalEnvironmentSandbox: environmentSandbox])
    }
    
    func sendPayPalPayment(money_type: String, amount: String, description: String, launchVC: UIViewController) {
        
        if checkPaypalPayment == nil {
            debugPrint("paypal payment check method not found")
            return
        }
        
        PayPalMobile.preconnect(withEnvironment: (paypalEnvironment == .product) ? PayPalEnvironmentProduction : PayPalEnvironmentSandbox)
        let payPalConfig = PayPalConfiguration()
        let payment = PayPalPayment(amount: NSDecimalNumber(string: amount), currencyCode: money_type, shortDescription: description, intent: .sale)
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            launchVC.present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
            debugPrint("Payment not processalbe: \(payment)")
        }
    }
    
}

extension TSPayPal: PayPalPaymentDelegate {
    
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        
        paypalPaymentFail?("cancel")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        debugPrint("PayPal Payment Success !")
        
        
        if let confirmation = completedPayment.confirmation as? [String: Any] , let response = confirmation["response"] as? [String:String] ,let receipt = response["id"] {
            
            print(confirmation)
            
            let state = checkPaypalPayment?(receipt) ?? false
            if state {
                paypalPaymentSuccess?()
            } else {
                paypalPaymentFail?("fail")
            }
            paymentViewController.dismiss(animated: true, completion: nil)
            return
        }
        
        paypalPaymentFail?("fail")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
}
