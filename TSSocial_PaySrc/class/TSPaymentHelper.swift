//
//  TSPaymentHelper.swift
//  MJSports
//
//  Created by 彩球 on 2017/12/6.
//  Copyright © 2017年 caiqr. All rights reserved.
//


/*
    启动PayPal支付
    1.需Pod PayPal-iOS-SDK
    2.registerPayPalProductId()  在AppDelegate中注册productionId

 */
import UIKit

struct TSPaymentThirdResultCode: OptionSet  {
    let rawValue: Int
    
    static let success = TSPaymentThirdResultCode(rawValue: 1 << 0)
    static let finish = TSPaymentThirdResultCode(rawValue: 1 << 1)
    static let `false` = TSPaymentThirdResultCode(rawValue: 1 << 2)
    static let cancel = TSPaymentThirdResultCode(rawValue: 1 << 3)
    static let error = TSPaymentThirdResultCode(rawValue: 1 << 4)
}

struct TSPaymentThirdResult {
    var code: TSPaymentThirdResultCode
    var paymentDesc: String
}

protocol TSPaymentThirdHelperDelegate {
    func paymentCallBack(result: TSPaymentThirdResult)
}

class TSPaymentHelper: NSObject {

    private var isRunningPayment: Bool = false
    private var AlipayUrlSchemeKey: String?
    
    /// 三方支付代理
    var delegate: TSPaymentThirdHelperDelegate?
    
    
    static let `default` = TSPaymentHelper.init()
    private override init(){ }

    //支持Paypal参数
    private var paypalHandler: TSPaypalInterface?
    private var weakViewController: UIViewController?
    private var orderId: String?
    
    
    /// 注册微信支付app_id
    class func registerWeChatAppID(wx_app_id: String) {
        WXApi.registerApp(wx_app_id)
    }
    
    /// 注册支付宝urlScheme
    class func registerAlipayScheme(urlScheme: String) {
        TSPaymentHelper.default.AlipayUrlSchemeKey = urlScheme
    }
    
    
    /// 调用微信支付
    func sendWechatPayment(appid: String?, partnerId: String, prepayId: String, package: String, nonceStr: String, timeStamp: UInt32, sign: String) {
        TSPaymentHelper.default.addObserverBecomeActive()
        WXApi.registerApp(appid)
        let payModel = PayReq()
        payModel.partnerId = partnerId
        payModel.prepayId = prepayId
        payModel.package = package
        payModel.nonceStr = nonceStr
        payModel.timeStamp = timeStamp
        payModel.sign = sign
        WXApi.send(payModel)
        TSPaymentHelper.default.isRunningPayment = true
    }
    
    ///调用支付宝支付
    func sendAliPayment(alipayPayOrder: String) {
        
        guard AlipayUrlSchemeKey != nil else {
            debugPrint("Alipay scheme is nil, please enter alipay scheme")
            return
        }
        
        TSPaymentHelper.default.addObserverBecomeActive()
        AlipaySDK.defaultService().payOrder(alipayPayOrder, fromScheme: AlipayUrlSchemeKey) { (result) in
            TSPaymentHelper.default.isRunningPayment = false
            TSPaymentHelper.default.delegate?.paymentCallBack(result: TSPaymentThirdResult(code: .finish, paymentDesc: "operation finish"))
        }
        TSPaymentHelper.default.isRunningPayment = true
    }
    
    ///调用PayPal支付
    func sendPayPalPayment(orderID: String, money_type: String, amount: String, description: String, launchVC: UIViewController) {
        orderId = orderID
        weakViewController = launchVC
        
        if let cls = NSClassFromString(Bundle.main.tsPaymentNameSpace + "." + "TSPayPal") {
            if cls is TSPaypalInterface.Type {
                paypalHandler = (cls as! TSPaypalInterface.Type).persionalInit()
                paypalHandler?.paypalPaymentSuccess = { [weak self] in
                    if let ws = self {
                        ws.delegate?.paymentCallBack(result: TSPaymentThirdResult(code: .finish, paymentDesc: "operation finish"))
                    }
                }
                
                paypalHandler?.paypalPaymentFail = { [weak self] (msg) in
                    if let ws = self {
                        ws.delegate?.paymentCallBack(result: TSPaymentThirdResult(code: .false, paymentDesc: "operation fail"))
                    }
                }
                
                paypalHandler?.sendPayPalPayment(money_type: money_type, amount: amount, description: description, launchVC: weakViewController!)
            }
        }
    }
    
    
    class func handle(url: URL!) -> Bool {
        if let alipayScheme = TSPaymentHelper.default.AlipayUrlSchemeKey,let scheme = url.scheme, scheme.hasPrefix(alipayScheme) {
            AlipaySDK.defaultService().processAuthResult(url, standbyCallback: { (result) in
                TSPaymentHelper.default.delegate?.paymentCallBack(result: TSPaymentThirdResult(code: .finish, paymentDesc: "operation finish"))
            })
            return true
        } else {
            return WXApi.handleOpen(url, delegate: TSPaymentHelper.default)
        }
    }
    
    
    @objc private func appWillBecomeActive() {
        if isRunningPayment {
            isRunningPayment = false
            delegate?.paymentCallBack(result: TSPaymentThirdResult(code: .finish, paymentDesc: "operation finish"))
        }
    }
    
    private func addObserverBecomeActive() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


// MARK: - 微信支付回调
extension TSPaymentHelper: WXApiDelegate {

    func onReq(_ req: BaseReq!) {

    }

    func onResp(_ resp: BaseResp!) {
        if resp is PayResp {
            self.isRunningPayment = false
            let response = resp as! PayResp
            var result: TSPaymentThirdResult?
            switch (response.errCode) {
                case 0:
                    result = TSPaymentThirdResult(code: .success, paymentDesc: response.errStr ?? "")
                case -1:
                    result = TSPaymentThirdResult(code: .false, paymentDesc: response.errStr ?? "")
                case -2:
                    result = TSPaymentThirdResult(code: .cancel, paymentDesc: "operation cancel")
                default:
                    result = TSPaymentThirdResult(code: .false, paymentDesc: "operation fail")
            }
            delegate?.paymentCallBack(result: result!)
        }
    }
}



extension Bundle {
    var tsPaymentNameSpace: String {
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
}

