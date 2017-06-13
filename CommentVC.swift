//
//  CommentVC.swift
//  demo_instagram
//
//  Created by DUY on 6/12/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


class CommentVC: UIViewController {
    var ref = FIRDatabase.database().reference(fromURL: "https://instagram-d9b3c.firebaseio.com/")
    var storage = FIRStorage.storage().reference(forURL: "gs://instagram-d9b3c.appspot.com/")
    var arrComment:[Comment] = []
    var id:String?
    var auth = FIRAuth.auth()
    var user:User?
    
    @IBOutlet weak var txtfComment: UITextField!
    @IBOutlet weak var tbvHienthi: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadData()
        tbvHienthi.dataSource = self
        tbvHienthi.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSend(_ sender: Any) {
        sendComment()
    }
    
    
    func LoadData(){
        ref.child("Comment").child(id!).observe(.childAdded, with: { (snapshot) in
            if let value = snapshot.value as? Dictionary<String,AnyObject>{
                var comment = Comment()
                comment.name = value["name"] as? String
                comment.imgProfile = value["ImgProfile"] as? String
                comment.comment = value["comment"] as? String
                
                self.arrComment.append(comment)
                
                DispatchQueue.main.async {
                    self.tbvHienthi.reloadData()
                }
            }
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
    }
    func sendComment(){
        if txtfComment.text == ""{
            ProgressHUD.show("Please input your comment ")
        }else{
            guard let commentString = txtfComment.text else { return }
            UploadDataToFireBase(commentString: commentString)
        }
    }
    

    
    func UploadDataToFireBase(commentString:String){
        let commentRef = ref.child("Comment").child(id!).childByAutoId()
        var value:Dictionary<String,AnyObject> = Dictionary()
        value.updateValue(commentString as AnyObject, forKey: "comment")
        value.updateValue(user?.name as AnyObject, forKey: "name")
        value.updateValue(user?.image as AnyObject, forKey: "ImgProfile")
        commentRef.setValue(value) { (error, data) in
            if error == nil {
                self.txtfComment.text = ""
                ProgressHUD.dismiss()
            }else {
                ProgressHUD.showError(error?.localizedDescription)
            }
        }
    }
    
    
}
extension CommentVC:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrComment.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!CommentTBVCell
        
        cell.lblName.text = arrComment[indexPath.row].name
        cell.lblComent.text = arrComment[indexPath.row].comment
        let url = URL(string: arrComment[indexPath.row].imgProfile!)
        cell.imgHinhProfile.kf.setImage(with: url)
        
        return cell
    }
}
