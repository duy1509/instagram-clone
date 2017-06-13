//
//  ThongTinVC.swift
//  demo_instagram
//
//  Created by DUY on 5/26/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import Firebase
import Kingfisher

class ThongTinVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtAbout: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    let auth = FIRAuth.auth()
    let picker = UIImagePickerController()
    let ref = FIRDatabase.database().reference(fromURL: "https://instagram-d9b3c.firebaseio.com/")
    let storage = FIRStorage.storage().reference(forURL: "gs://instagram-d9b3c.appspot.com/")
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        layData()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        self.imgProfile.layer.cornerRadius = 50
        self.imgProfile.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSelectPhoto(_ sender: Any) {
        let alert = UIAlertController(title: "Messenger", message: "Select Image Please", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { (Photo) in
            self.showPhoto(picker: self.picker, view: self, sourType: .photoLibrary, alowEditing: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func btnSave(_ sender: Any) {
        ProgressHUD.show("Waiting...!")
        uploadData(name: txtName.text!, email: txtEmail.text!, about: txtAbout.text!,image: imgProfile.image!)
    }
    @IBAction func btnLogOut(_ sender: Any) {
        let logout = FIRAuth.auth()
        do{
            try logout?.signOut()
            let comeback = storyboard?.instantiateViewController(withIdentifier: "ComeBack") as! ViewController
            self.present(comeback, animated: true, completion: nil)
        }catch let signerror as NSError{
            print("Error sign out :",signerror)
        }

    }
    
    func showPhoto(picker:UIImagePickerController,view:UIViewController,sourType:UIImagePickerControllerSourceType,alowEditing:Bool){
        picker.sourceType = sourType
        picker.allowsEditing = alowEditing
        view.present(picker, animated: true, completion: nil)
    }
    func changeEmail(){
        auth?.currentUser?.updateEmail(txtEmail.text!, completion: { (error) in
            ProgressHUD.showError(error?.localizedDescription)
            
        })
    }

    
    func layData(){
        ref.child("User").child((auth?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { [weak self](snapshot) in
            let value = snapshot.value as! Dictionary<String,AnyObject>
            self?.txtName.text! = (value["name"] as? String)!
            self?.txtEmail.text! = (value["email"] as? String)!
            let url = URL(string: value["ImageProfile"] as! String)
            self?.imgProfile.kf.setImage(with: url)
        })
    }
    func uploadData(name:String,email:String,about:String,image:UIImage){
        let data = UIImagePNGRepresentation(imgProfile.image!)
        let image = UUID().uuidString
        let stringRef = storage.child("Image\(image).png")
        stringRef.put(data!, metadata: nil) { (metadata, error) in
            if error != nil{
                ProgressHUD.showError(error?.localizedDescription)
        }else{
                let imgString = metadata?.downloadURL()?.absoluteString
                var newvalue = ["name":name,"email":email,"about":about,"ImageProfile":image]
                newvalue.updateValue((imgString as AnyObject) as! String, forKey: "ImageProfile")
                newvalue.updateValue((self.txtName.text as AnyObject) as! String, forKey: "name")
                newvalue.updateValue((self.txtEmail.text as AnyObject) as! String
                    , forKey: "email")
                newvalue.updateValue((self.txtAbout.text as AnyObject) as! String, forKey: "about")
                let userProfile = self.ref.child("User").child((self.auth?.currentUser?.uid)!)
                userProfile.setValue(newvalue, withCompletionBlock: { (error, data) in
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription)
                    }else{
                        self.changeEmail()
                        ProgressHUD.showSuccess("Success")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    
    
    
}
extension ThongTinVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true){
            let img = info[UIImagePickerControllerOriginalImage] as! UIImage
            let newimg = Uilities.ShareIntand.resizeImage(image: img, newWidth: 300)
            self.imgProfile.image = newimg
        }
    }
}
