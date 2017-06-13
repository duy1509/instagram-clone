//
//  CameraVC.swift
//  demo_instagram
//
//  Created by DUY on 5/17/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Firebase
import AVFoundation

class CameraVC: UIViewController {

    @IBOutlet weak var txtfHIenthi: UITextView!
    @IBOutlet weak var imgHInh: UIImageView!
    let picker = UIImagePickerController()
    var auth = FIRAuth.auth()
    var userName:String?
    var urlProfile:String?
    var email:String?
    let ref = FIRDatabase.database().reference(fromURL: "https://instagram-d9b3c.firebaseio.com/")
    let storage = FIRStorage.storage().reference(forURL: "gs://instagram-d9b3c.appspot.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        picker.delegate = self
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GestureChonImage(_ sender: Any) {
        let alert = UIAlertController(title: "Messenges", message: "Mời Bạn Chọn", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { (Photo) in
            self.showCameraAndLibrary(picker: self.picker, view: self, sourType: .photoLibrary, alowEditing: false)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (Camera) in
            self.showCameraAndLibrary(picker: self.picker, view: self, sourType: .camera, alowEditing: false)
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { (Video) in
            self.showCameraAndLibrary(picker: self.picker, view: self, sourType: .camera, alowEditing: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnShare(_ sender: Any) {
        ProgressHUD.show("Waiting...")
        uploadDataAndImage()
    }
    
    
    
    
    
    
    
    func loadData(){
        ref.child("User").child((auth?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            var value = snapshot.value as! Dictionary<String,AnyObject>
            self.userName = value["name"] as? String
            self.email = value["email"] as? String
            self.urlProfile = value["ImageProfile"] as? String
        })
    }
    
    func uploadDataAndImage(){
        let table = ref.child("Table")
        let img = ref.child("ImgLoad")
        var tablevalue:Dictionary<String,AnyObject> = Dictionary()
        var newvalue:Dictionary<String,AnyObject> = Dictionary()
        let data = UIImagePNGRepresentation(imgHInh.image!)
        let image = UUID().uuidString
        let refString = storage.child("Image\(image).png")
        refString.put(data!, metadata: nil) { (metadata, error) in
            if error != nil{
                ProgressHUD.showError(error?.localizedDescription)
        }else{
                let newimage = metadata?.downloadURL()?.absoluteString
                tablevalue.updateValue(self.userName as AnyObject, forKey: "name")
                tablevalue.updateValue(self.email as AnyObject, forKey: "email")
                tablevalue.updateValue(self.urlProfile as AnyObject, forKey: "ImageProfile")
                tablevalue.updateValue(self.txtfHIenthi.text as AnyObject, forKey: "Status")
                tablevalue.updateValue(newimage as AnyObject, forKey: "ImgageLoad")
                newvalue.updateValue(newimage as AnyObject, forKey: "ImageURL")
                let tableUser = table.child(image)
                tableUser.setValue(tablevalue, withCompletionBlock: { (error, data) in
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription)
                    }else{
                        let newimg = img.child((self.auth?.currentUser?.uid)!)
                        let imgname = newimg.child(image)
                        imgname.setValue(newvalue, withCompletionBlock: { (error, data) in
                            if error != nil {
                                ProgressHUD.showError()
                            }
                        })
                        ProgressHUD.showSuccess("Success")
                        self.tabBarController?.selectedIndex = 0
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
extension CameraVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true){
            let img = info[UIImagePickerControllerOriginalImage] as! UIImage
            let newimg = Uilities.ShareIntand.resizeImage(image: img, newWidth: 300)
            self.imgHInh.image = newimg
        }
    }
}
