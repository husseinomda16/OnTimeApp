//
//  VerificationCodeVC.swift
//  OnTimeApp
//
//  Created by Husseinomda16 on 5/12/19.
//  Copyright © 2019 Ontime24. All rights reserved.
//

import UIKit
import SwiftyJSON
import KKPinCodeTextField
class VerificationCodeVC: UIViewController {

    var count = 60
    var isLogin = false
    var isRegister = false
    var http = HttpHelper()
    var vereficationCode = ""
    var Email = ""
    var Token = ""
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet var popupVerefy: UIView!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtCode: KKPinCodeTextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnResend: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        if (isRegister == true) || (isLogin == true) {
            SendCode()
            btnSend.setTitle(AppCommon.sharedInstance.localization("CONFIRM"), for: .normal)
        }else{
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
        http.delegate = self
        print(vereficationCode,Email)

        popupVerefy.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(popupVerefy)
        popupVerefy.isHidden = true
       // btnSend.backgroundColor = .clear
        btnSend.layer.cornerRadius = 25
        //btnSend.layer.borderWidth = 1
        //btnSend.layer.borderColor = UIColor.white.cgColor
    
        btnSend.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        btnSend.layer.shadowOffset = CGSize(width: 0, height: 4)
        btnSend.layer.shadowOpacity = 1.0
        btnSend.layer.shadowRadius = 3.0
        btnSend.layer.masksToBounds = false
   

        
        // Do any additional setup after loading the view.
    }
    
    func Emailvalidation () -> Bool {
        var isValid = true
        
        if txtEmail.text! == "" {
            Loader.showError(message: AppCommon.sharedInstance.localization("Phone field cannot be left blank"))
            isValid = false
        }
        
        
        return isValid
    }

    @IBAction func btnResendCode(_ sender: Any) {
        if Emailvalidation(){
            ResendCode()
        }
    }
        @IBAction func btnResend(_ sender: Any) {
        
        if isRegister == true {
         SendCode()
        }else{
//            popupVerefy.isHidden = false
//            popupVerefy.backgroundColor = UIColor.hexColorWithAlpha(string: "#000000", alpha: 0.75)
            ResendCode()
        }
    }
    func ResendCode(){
        
        print(Email)
        let params = ["email":Email] as [String: Any]
        //AppCommon.sharedInstance.ShowLoader(self.view,color: UIColor.hexColorWithAlpha(string: "#000000", alpha: 0.35))
        http.requestWithBody(url: APIConstants.ForgetPassword, method: .post, parameters: params, tag: 4, header: nil)
    }

    @IBAction func btnSend(_ sender: Any) {
        
        if validation(){
            if (isRegister == true) || (isLogin == true){
                isRegister = false
                isLogin = false
                confirm()
            }else{
                 ResetCode()
            }
            
        }
        
    }
    
    func validation () -> Bool {
        var isValid = true
        if txtCode.text! == "" {
            Loader.showError(message: AppCommon.sharedInstance.localization("Email field cannot be left blank"))
            isValid = false
        }
        if txtCode.text! != vereficationCode {
            Loader.showError(message: AppCommon.sharedInstance.localization("please enter code you received"))
            isValid = false
        }
        
        return isValid
    }
    
    
    @objc func update() {
        btnResend.isEnabled = false
        if(count > 0) {
            count -= 1
            lblTimer.text = String(count)
        }else{
            btnResend.isEnabled = true
        }
    }
    
    func SendCode(){
        print(Token)
    let params = ["token": Token] as [String: Any]
        let headers = [
            "Authorization": Token]
        AppCommon.sharedInstance.ShowLoader(self.view,color: UIColor.hexColorWithAlpha(string: "#000000", alpha: 0.35))
        http.requestWithBody(url: APIConstants.SendCode, method: .post, parameters: params, tag: 3, header: headers)
    }
    
    func confirm(){
        //let AccessToken = AppCommon.sharedInstance.getJSON("Profiledata")["token"].stringValue
        print(Token)
        let params = [
            "token": Token ,
            "code": txtCode.text!] as [String: Any]
        let headers = [
            "Authorization": Token]
        AppCommon.sharedInstance.ShowLoader(self.view,color: UIColor.hexColorWithAlpha(string: "#000000", alpha: 0.35))
        http.requestWithBody(url: APIConstants.CheckVCode, method: .post, parameters: params, tag: 2, header: headers)
    }
    
    func ResetCode(){
      //  let AccessToken = AppCommon.sharedInstance.getJSON("Profiledata")["token"].stringValue
        let params = [
            "token": Token ,
            "code": txtCode.text!] as [String: Any]
        let headers = [
            "Authorization": Token]
        AppCommon.sharedInstance.ShowLoader(self.view,color: UIColor.hexColorWithAlpha(string: "#000000", alpha: 0.35))
        http.requestWithBody(url: APIConstants.CheckPCode, method: .post, parameters: params, tag: 1, header: headers)
    }
    
    @IBAction func DismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
extension VerificationCodeVC : HttpHelperDelegate {
    func receivedResponse(dictResponse: Any, Tag: Int) {
        print(dictResponse)
        AppCommon.sharedInstance.dismissLoader(self.view)
        let json = JSON(dictResponse)
        if Tag == 1 {
            let status =  json["status"]
            let token = json["token"]
            let message = json["message"]
            print(status)
            print(token)
            
            //print(json["status"])
            if status.stringValue == "0" {
                // let storyboard = UIStoryboard(name: "StoryBord", bundle: nil)
                let sb = UIStoryboard(name: "Profile", bundle: nil)
               let controller = sb.instantiateViewController(withIdentifier: "ResetPassword") as! ResetPassword
               controller.Token = Token
             controller.Email = Email
               self.show(controller, sender: true)
                
                
            }else if status.stringValue == "500"{
                Loader.showError(message: AppCommon.sharedInstance.localization("Wrong request type"))
            }else if status.stringValue == "1"{
                Loader.showError(message: AppCommon.sharedInstance.localization("some missing data"))
            }else if status.stringValue == "204"{
                Loader.showError(message: AppCommon.sharedInstance.localization("un authorized"))
            }else if status.stringValue == "207"{
                Loader.showError(message: AppCommon.sharedInstance.localization("wrong code"))
            }else {
                Loader.showError(message: message.stringValue )
            }
        }else if  Tag == 2 {
            let status =  json["status"]
            let message = json["msg"]
            
            if status.stringValue == "0" {
                Loader.showSuccess(message: AppCommon.sharedInstance.localization("success"))
               // if isRegister == true {
                let sb = UIStoryboard(name: "Profile", bundle: nil)
                let controller = sb.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.show(controller, sender: true)
//                }
//                if isLogin == true {
//                    let delegate = UIApplication.shared.delegate as! AppDelegate
//                    // let storyboard = UIStoryboard(name: "StoryBord", bundle: nil)
//                    let storyboard = UIStoryboard.init(name: "Projects", bundle: nil); delegate.window?.rootViewController = storyboard.instantiateInitialViewController()
//                }
                
            }else if status.stringValue == "500"{
                Loader.showError(message: AppCommon.sharedInstance.localization("Wrong request type"))
            }else if status.stringValue == "1"{
                Loader.showError(message: AppCommon.sharedInstance.localization("some missing data"))
            }else if status.stringValue == "204"{
                Loader.showError(message: AppCommon.sharedInstance.localization("un authorized"))
            }else if status.stringValue == "206"{
                Loader.showError(message: AppCommon.sharedInstance.localization("wrong code"))
            } else {
                Loader.showError(message: message.stringValue )
            }
        }else if Tag == 3 {

            let status =  json["status"]
            let message = json["msg"]
            let code = json["vcode"]
            let NewToken = json["token"]
            print(code)
            if status.stringValue == "0" {
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)

                Loader.showSuccess(message: AppCommon.sharedInstance.localization("success"))
                self.Token = NewToken.stringValue
                self.vereficationCode = code.stringValue
            } else if status.stringValue == "500"{
                Loader.showError(message: AppCommon.sharedInstance.localization("Wrong request type"))
            }else if status.stringValue == "1"{
                Loader.showError(message: AppCommon.sharedInstance.localization("some missing data"))
            }else if status.stringValue == "204"{
                Loader.showError(message: AppCommon.sharedInstance.localization("un authorized"))
            }else if status.stringValue == "205"{
                Loader.showError(message: AppCommon.sharedInstance.localization("user already verified"))
            }else if status.stringValue == "206"{
                Loader.showError(message: AppCommon.sharedInstance.localization("Send failed"))
            }else {
                Loader.showError(message: message.stringValue )
            }
        }else if Tag == 4 {
                
                let status =  json["status"]
                let Message =  json["msg"]
                let Token =  json["token"]
                let code = json["pcode"]
                if status.stringValue  == "0" {
                    count = 60
                    lblTimer.text = "60"
                    Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                     self.vereficationCode = code.stringValue
                    self.Token = Token.stringValue
                   
                }else if status.stringValue == "500"{
                    Loader.showError(message: AppCommon.sharedInstance.localization("Wrong request type"))
                }else if status.stringValue == "1"{
                    Loader.showError(message: AppCommon.sharedInstance.localization("some missing data"))
                }else if status.stringValue == "204"{
                    Loader.showError(message: AppCommon.sharedInstance.localization("un authorized"))
                }else if status.stringValue == "206"{
                    Loader.showError(message: AppCommon.sharedInstance.localization("Send failed"))
                }else{
                    
                    Loader.showError(message: Message.stringValue )
                }
            }
    }
    
    func receivedErrorWithStatusCode(statusCode: Int) {
        print(statusCode)
        AppCommon.sharedInstance.alert(title: "Error", message: "\(statusCode)", controller: self, actionTitle: AppCommon.sharedInstance.localization("ok"), actionStyle: .default)
        
        AppCommon.sharedInstance.dismissLoader(self.view)
    }
    func retryResponse(numberOfrequest: Int) {
        
    }
    
}

