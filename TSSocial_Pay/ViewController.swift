//
//  ViewController.swift
//  TSSocial_Pay
//
//  Created by 彩球 on 2018/6/18.
//  Copyright © 2018年 caiqr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TSPaymentHelper.default.delegate = self

        
        // 微信
        TSPaymentHelper.registerWeChatAppID(wx_app_id: "000000")
//        TSPaymentHelper.default.sendWechatPayment(appid: <#T##String?#>, partnerId: <#T##String#>, prepayId: <#T##String#>, package: <#T##String#>, nonceStr: <#T##String#>, timeStamp: <#T##UInt32#>, sign: <#T##String#>)
        
        
        
        // Alipay
        TSPaymentHelper.registerAlipayScheme(urlScheme: "xxxx")
//        TSPaymentHelper.default.sendAliPayment(alipayPayOrder: <#T##String#>)
        
        
        // PayPal
        TSPayPal.registerPayPalProductId(environmentProduction: "xx", environmentSandbox: "xx")
        TSPayPal.default.paypalEnvironment = .product
        TSPayPal.default.checkPaypalPayment = { (recept) -> Bool in
            //调用API 并返回凭证校验状态
            return true
        }
//        TSPaymentHelper.default.sendPayPalPayment(orderID: _, money_type: _, amount: _, description: _, launchVC: _)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
//支付状态回调
extension ViewController: TSPaymentThirdHelperDelegate {
    
    func paymentCallBack(result: TSPaymentThirdResult) {
        //operation
    }
}


