//
//  DangKyVC.swift
//  demo_instagram
//
//  Created by DUY on 5/17/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import Firebase
import Sharaku
import Pastel

class DangKyVC: UIViewController {

    @IBOutlet weak var imgHinh: UIImageView!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtName: UITextField!
    var ref:FIRDatabaseReference!
    var storage = FIRStorage.storage()
    let picker:UIImagePickerController = UIImagePickerController()
    let auth = FIRAuth.auth()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        backGroundColor()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        self.imgHinh.layer.cornerRadius = 50
        self.imgHinh.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnClickDangKy(_ sender: Any) {
        
        ProgressHUD.show("Waiting...!")
        dangKyUser(name: txtName.text!, email: txtMail.text!, pass: txtPass.text!, image: imgHinh.image!)
    }
    @IBAction func btnClickDangNhap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func GestureChonImage(_ sender: Any) {
        let alert = UIAlertController(title: "Messenges", message: "Select Image please", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { (Photo) in
            self.showCameraAndLibrary(picker: self.picker, view: self, sourType: .photoLibrary, alowEditing: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func backGroundColor(){
        let pastelView = PastelView(frame: view.bounds)
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        // Custom Duration
        pastelView.animationDuration = 3.0
        
        // Custom Color
        pastelView.setColors([UIColor(red: 138/255, green: 58/255, blue: 185/255, alpha: 1.0),
                              UIColor(red: 76/255, green: 104/255, blue: 215/255, alpha: 1.0),
                              UIColor(red: 205/255, green: 72/255, blue: 107/255, alpha: 1.0),
                              UIColor(red: 251/255, green: 173/255, blue: 80/255, alpha: 1.0),
                              UIColor(red: 252/255, green: 204/255, blue: 99/255, alpha: 1.0),
                              UIColor(red: 188/255, green: 42/255, blue: 141/255, alpha: 1.0),
                              UIColor(red: 233/255, green: 89/255, blue: 80/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        self.view.insertSubview(pastelView, at: 0)

    }
    
    func dangKyUser(name:String,email:String , pass:String,image:UIImage){
        if let name:String = name , let email:String = email ,let pass:String = pass{
            FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user, error) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                }else{
                    let value = ["name":name,"email":email,"pass":pass]
                    self.upLoadDataAndImage(uid: (user?.uid)!, value: value as [String : AnyObject], image: image)
                }
            })
        }
    }
    func upLoadDataAndImage(uid:String,value:[String:AnyObject],image:UIImage){
        let storageRef = storage.reference(forURL: "gs://instagram-d9b3c.appspot.com/")
        let data = UIImagePNGRepresentation(imgHinh.image!)
        let newimage = UUID().uuidString
        let ImageString = storageRef.child("Image\(newimage).png")
        ImageString.put(data!, metadata: nil) { [weak self](data, error) in
            if error != nil{
                ProgressHUD.showError()
        }else{
                let img = data?.downloadURL()?.absoluteString
                var newvalue = value
                newvalue.updateValue(img as AnyObject, forKey: "ImageProfile")
                let ref = FIRDatabase.database().reference(fromURL: "https://instagram-d9b3c.firebaseio.com/")
                let user = ref.child("User").child(uid)
                user.setValue(newvalue, withCompletionBlock: { (error, database) in
                    if error != nil{
                        ProgressHUD.showError(error?.localizedDescription)
                    }else{
                        ProgressHUD.showSuccess()
                        self?.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
        
                
    }
    
    
    func showCameraAndLibrary(picker:UIImagePickerController,view:UIViewController,sourType:UIImagePickerControllerSourceType,alowEditing:Bool){
        picker.sourceType = sourType
        picker.allowsEditing = alowEditing
        view.present(picker, animated: true, completion: nil)
    }
    
    
}
extension DangKyVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true){
            let img = info[UIImagePickerControllerOriginalImage] as! UIImage
            let newimg = Uilities.ShareIntand.resizeImage(image: img, newWidth: 300)
            self.imgHinh.image = newimg
        }
    }
}
