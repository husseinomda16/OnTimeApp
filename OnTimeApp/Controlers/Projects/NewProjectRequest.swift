//
//  NewProjectRequest.swift
//  OnTimeApp
//
//  Created by Husseinomda16 on 5/28/19.
//  Copyright © 2019 Ontime24. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire

class NewProjectRequest: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource , UIDocumentMenuDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate{
var RequestServices : RequestNServicesModelClass!
    var attachment = [UIDocument]()
    var Addons = [AddonsModelClass]()
    var Services = [ServicesModelClass]()
    
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
//    //var arrTypes =
//        [
//        "الموشن جرافيك",
//                    "التصميم",
//                    "البرمجة",
//                    "التنفيذ",
//                    "قواعد البيانات"]
//
    var isimgChecked1 = false
    var isimgChecked2 = false
    var isimgChecked3 = false
    var isimgChecked4 = false
    var department_id = ""
    var service_id = "1"
    var http = HttpHelper()
    var pickerview  = UIPickerView()
    var toolBar = UIToolbar()
    var AlertController: UIAlertController!
    let imgpicker = UIImagePickerController()
    var documentInteractionController = UIDocumentInteractionController()
    
    @IBOutlet weak var txtdesc: UITextView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var imgServices: UIImageView!
    @IBOutlet weak var addOnesCV: UICollectionView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var imgVoice: UIImageView!
    @IBOutlet weak var imgQueikService: UIImageView!
    @IBOutlet weak var imgTranslation: UIImageView!
    @IBOutlet weak var imgScinario: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        http.delegate = self
        
        addOnesCV.delegate = self
        addOnesCV.dataSource = self
        GetServices(ServicesID: service_id)
        SetupActionSheet()
        lblType.text = "الموشن جرافيك"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnNext(_ sender: Any) {
        //AddRequest()
        let storyboard = UIStoryboard(name: "Projects", bundle: nil)
        let cont = storyboard.instantiateViewController(withIdentifier: "VerifyProjectRequest") as! VerifyProjectRequest
        print(lblType.text!)
        let title = lblType.text
        let name = txtName.text
        let Desc = txtdesc.text
        cont.tit = title!
        cont.name = name!
        cont.desc = Desc!
        cont.departmentID = department_id
        cont.serviceID = service_id
        print(title! + name! + Desc!)
        //cont.lblDesc.text = txtdesc.text
        cont.attachment = attachment
        cont.Addons = Addons
        cont.RequestServices = RequestServices
        
        self.present(cont, animated: true, completion: nil)
    }
    @IBAction func btnAttachment(_ sender: Any) {
        imgpicker.delegate = self
        imgpicker.allowsEditing = false
        self.present(AlertController, animated: true, completion: nil)
    }
    @IBAction func btnDropDownType(_ sender: Any) {
        onDoneButtonTapped()
        configurePicker()
    }
    @IBAction func btnSideMenue(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Projects", bundle: nil)
        let cont = storyboard.instantiateViewController(withIdentifier: "RightMenuNavigationController")
        cont.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        cont.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(cont, animated: true, completion: nil)
    }

    @IBAction func btnQueckService(_ sender: Any) {
        if isimgChecked1 == false {
            imgQueikService.image = UIImage(named: "check")
            isimgChecked1 = true
        }else{
            imgQueikService.image = UIImage(named: "check (1)")
            isimgChecked1 = false
        }
    }
    @IBAction func btnVoice(_ sender: Any) {
        if isimgChecked2 == false {
            imgVoice.image = UIImage(named: "check")
            isimgChecked2 = true
        }else{
            imgVoice.image = UIImage(named: "check (1)")
            isimgChecked2 = false
        }
    }
    @IBAction func btnTranslation(_ sender: Any) {
        if isimgChecked3 == false {
            imgTranslation.image = UIImage(named: "check")
            isimgChecked3 = true
        }else{
            imgTranslation.image = UIImage(named: "check (1)")
            isimgChecked3 = false
        }
    }
    @IBAction func btnScinario(_ sender: Any) {
        if isimgChecked4 == false {
            imgScinario.image = UIImage(named: "check")
            isimgChecked4 = true
        }else{
            imgScinario.image = UIImage(named: "check (1)")
            isimgChecked4 = false
        }
    }
    @IBAction func DismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func SetupActionSheet()
    {
        AlertController = UIAlertController(title:"" , message:AppCommon.sharedInstance.localization("المرفقات") , preferredStyle: UIAlertController.Style.actionSheet)
        
        let Cam = UIAlertAction(title: "الكاميرا", style: UIAlertAction.Style.default, handler: { (action) in
            self.openCame()
        })
        let Gerall = UIAlertAction(title: "المعرض", style: UIAlertAction.Style.default, handler: { (action) in
            self.openGalleryImagePicker()
        })
        
        let Docs = UIAlertAction(title: "الملفات", style: UIAlertAction.Style.default, handler: { (action) in
            self.openDcumentPicker()
        })
        let Map = UIAlertAction(title: "الموقع", style: UIAlertAction.Style.default, handler: { (action) in
            self.openGalleryImagePicker()
        })
        
        let Cancel = UIAlertAction(title: AppCommon.sharedInstance.localization("cancel"), style: UIAlertAction.Style.cancel, handler: { (action) in
            //
        })
        
        self.AlertController.addAction(Cam)
        self.AlertController.addAction(Gerall)
        self.AlertController.addAction(Docs)
        self.AlertController.addAction(Map)
        self.AlertController.addAction(Cancel)
    }
    
    // Delegate Method for UIDocumentMenuDelegate.
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    // Delegate Method for UIDocumentPickerDelegate.
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url: \(url)")
        let fileName = url.lastPathComponent
        print("fileName: \(fileName)")
        if (url.absoluteString.hasSuffix("pdf")) {
            print("pdf")
            
        }
        else if (url.absoluteString.hasSuffix("doc")) {
            print("doc")
            
        }
        else if (url.absoluteString.hasSuffix("docx")) {
            print("docx")
            
        }
        else if (url.absoluteString.hasSuffix("xlsx")) {
            print("xlsx")
            
        }
        else if (url.absoluteString.hasSuffix("xls")) {
            print("xls")
            
        }
        else if (url.absoluteString.hasSuffix("txt")) {
            print("txt")
            
        }
        else if (url.absoluteString.hasSuffix("pptx")) {
            print("pptx")
            
        }
        else if (url.absoluteString.hasSuffix("PPT")) {
            print("ppt")
            
        }
        else {
            print("Unknown")
        }
        
    }
    // Method to handle cancel action.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        //        dismiss(animated: true, completion: nil)
    }

    func openDcumentPicker() {
        
        let pdf = String("kUTTypePDF")
        //        let zip = String(kUTTypeZipArchive)
        let docs = String("kUTTypeCompositeContent")
        //        let archive = String(kUTTypeArchive)
        let number = String("kUTTypeLog")
        let spreadsheet = String("kUTTypeSpreadsheet")
        //        let movie = String(kUTTypeMovie)
        //        let aviMovie = String(kUTTypeAVIMovie)
        let importMenu = UIDocumentMenuViewController(documentTypes: [pdf, docs, number, spreadsheet], in: UIDocumentPickerMode.import)
        importMenu.delegate = self
        
//        if Helper.isDeviceiPad() {
//
//            if let popoverController = importMenu.popoverPresentationController {
//                popoverController.sourceView = sender
//            }
//        }
        
        
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func openGalleryImagePicker() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true)
    }
    
    func openCame(){
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openCameraImagePicker() {
       
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        //        imageProfile.contentMode = .scaleAspectFit
        print("image: \(image)")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //        let assetPath = info[UIImagePickerControllerReferenceURL] as! URL
        //        let imgName = assetPath.lastPathComponent
        
        if #available(iOS 11.0, *) {
            if let assetPath = info["UIImagePickerControllerImageURL"] as? URL{
                let imgName = assetPath.lastPathComponent
                print(imgName)
                if (assetPath.absoluteString.hasSuffix("jpg")) {
                    print("jpg")
                    if let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                        print("image: \(pickedImage)")
                        
                    }
                }else if (assetPath.absoluteString.hasSuffix("jpeg")) {
                    print("jpeg")
                    
                }
                else if (assetPath.absoluteString.hasSuffix("png")) {
                    print("png")
                   
                }
                else if (assetPath.absoluteString.hasSuffix("gif")) {
                    print("gif")
                    
                }
                else {
                    print("Unknown")
                }
                
            }else {
                if let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                  //  sendImg.image = pickedImage
                    let imagePath = URL(fileURLWithPath: "")
                    
                }
            }
        } else {
            // Fallback on earlier versions
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func GetServices(ServicesID : String){
        Addons.removeAll()
        Services.removeAll()

    let AccessToken = AppCommon.sharedInstance.getJSON("Profiledata")["token"].stringValue
    print(AccessToken)
    let params = ["token": AccessToken,
                  "department_id":department_id,
                  "service_id":ServicesID] as [String: Any]
    let headers = [
    "Authorization": AccessToken]
    AppCommon.sharedInstance.ShowLoader(self.view,color: UIColor.hexColorWithAlpha(string: "#000000", alpha: 0.35))
    http.requestWithBody(url: APIConstants.GetServices, method: .post, parameters: params, tag: 1, header: headers)
    }
    
    
    
    func configurePicker (){
        pickerview = UIPickerView.init()
        pickerview.delegate = self
        pickerview.backgroundColor = UIColor.white
        pickerview.setValue(UIColor.black, forKey: "textColor")
        pickerview.autoresizingMask = .flexibleWidth
        pickerview.contentMode = .center
        pickerview.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 255)
        self.view.addSubview(pickerview)
        
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(onDoneButtonTapped))]
        
        
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        pickerview.removeFromSuperview()
        self.view.endEditing(true)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Services.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(Services[row]._name)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        toolBar.removeFromSuperview()
        pickerview.removeFromSuperview()
        self.view.endEditing(true)
        lblType.text = Services[row]._name
        imgServices.image = UIImage(named: Services[row]._img)
        service_id = Services[row]._id
        GetServices(ServicesID: Services[row]._id)
        
    }
}
extension NewProjectRequest : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Addons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addOnesCVC", for: indexPath) as! addOnesCVC
        cell.lblName.text = Addons[indexPath.row]._name
        cell.Id = Addons[indexPath.row]._id
        cell.price = Addons[indexPath.row]._price
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 35)
    }
}
extension NewProjectRequest : HttpHelperDelegate {
    func receivedResponse(dictResponse: Any, Tag: Int) {
        print(dictResponse)
        AppCommon.sharedInstance.dismissLoader(self.view)
        let json = JSON(dictResponse)
        if Tag == 1 {
            let status =  json["status"]
            let data = json["data"]
            let message = json["msg"]
            let Jaddons = data["addons"].arrayValue
            let Jservices = json["services"].arrayValue
            if status.stringValue == "0" {

                for json in Jservices{
                    let obj = ServicesModelClass(
                        id: json["id"].stringValue,
                        name: json["name"].stringValue,
                        img: json["img"].stringValue
                        )
                    Services.append(obj)
                }
                for json in Jaddons{
                    let obj = AddonsModelClass(
                        id: json["id"].stringValue,
                        name: json["name"].stringValue,
                        price: json["price"].stringValue
                        
                    )
                    //print(obj)
                    Addons.append(obj)
                }
                    RequestServices = RequestNServicesModelClass(
                        id: data["id"].stringValue,
                        name: data["name"].stringValue,
                        img: data["img"].stringValue,
                        has_price: data["has_price"].stringValue,
                        price: data["price"].stringValue,
                        has_contract: data["has_contract"].stringValue,
                        has_time: data["has_time"].stringValue,
                        average_time: data["average_time"].stringValue,
                        tax_percentage: data["tax_percentage"].stringValue,
                        addons: Addons
                    )
                self.addOnesCV.reloadData()
                print(RequestServices._average_time)
                print(RequestServices._has_contract)
                print(RequestServices._has_price)
                print(RequestServices._has_time)
                print(RequestServices._tax_percentage)
                AppCommon.sharedInstance.dismissLoader(self.view)


            } else {
                Loader.showError(message: message.stringValue )
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

