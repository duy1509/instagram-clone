//
//  HomeCell.swift
//  demo_instagram
//
//  Created by DUY on 5/23/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import FirebaseDatabase

class HomeCell: UITableViewCell {


    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnUserLike: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblName2: UILabel!
    @IBOutlet weak var imgHinh: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    var acctionbuttonLike:(()->(Void))? = nil
    var acctionbuttonUserLike:(()->(Void))? = nil
    var acctionbuttonComment:(()->(Void))? = nil
    let ref = FIRDatabase.database().reference(fromURL: "https://instagram-d9b3c.firebaseio.com/")
    let storage = FIRStorage.storage().reference(forURL: "gs://instagram-d9b3c.appspot.com/")
//    var postReference = FIRDatabaseReference()
    var home:HomeItem?
    var auth = FIRAuth.auth()
    var username:String?
    var imgURL:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        self.imgProfile.layer.cornerRadius = 25
        self.imgProfile.layer.masksToBounds = true
        layData()
        // Initialization code
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnComment(_ sender: UIButton) {
        guard let actionComment = self.acctionbuttonComment else{return}
        actionComment()
    }
    @IBAction func btnShare(_ sender: UIButton) {
    }

    @IBAction func btnLike(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let actionLike = self.acctionbuttonLike else {return}
        actionLike()
        handleLikeTap()
    }
    
    @IBAction func btnUserLike(_ sender: UIButton) {
        guard let acctionUserLike = self.acctionbuttonUserLike else {return}
        acctionUserLike()
    }
    
    func handleLikeTap() {
        let postReference = ref.child("Table").child((home!.id!))
        showLike(forReference: postReference)
    }

    
    func showLike(forReference refLike: FIRDatabaseReference){
        refLike.runTransactionBlock({ (currentData:FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = self.auth?.currentUser?.uid{
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    // Unlike the post and remove self from stars
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    // Like the post and add self to stars
                    likeCount += 1
                    likes[uid] = true
                    
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let value = snapshot?.value as? Dictionary<String,AnyObject> {
                var post = HomeItem()
                post.id = snapshot?.key
                post.name = value["name"] as? String
                post.status = value["status"] as? String
                post.imgLoadHinh = value["imgLoad"] as? String
                post.imgURL = value["imgProfile"] as? String
                post.likeCount = value["likeCount"] as? Int
                post.likes = value["likes"] as? Dictionary<String,Any>
                if let currentUserID = self.auth?.currentUser?.uid{
                    if post.likes != nil {
                        post.isLiked = post.likes![currentUserID] != nil
                    }
                }
                self.upDataLike(post: post)
            }
        }
            
    }
    
    
    func upDataLike(post: HomeItem){
        let btnname = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        if post.isLiked == nil {
            self.btnLike.setImage(UIImage(named:"like"), for: .normal)
        } else {
            if post.isLiked! {
                self.btnLike.setImage(UIImage(named:btnname), for: .normal)
                self.loadDataUserLike()
            } else{
                self.btnLike.setImage(UIImage(named:btnname), for: .selected)
                
            }
        }
        guard let count = post.likeCount else {
            return
        }
        if count != 0 {
            btnUserLike.setTitle("\(count) Likes", for: .normal)
        } else if post.likeCount == 0 {
            btnUserLike.setTitle("Be the first to Like this", for: .normal)
        }
    }
    
    
    func layData(){
        ref.child("User").child((auth?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Dictionary<String,AnyObject> {
                
                self.username = value["name"] as? String
                self.imgURL = value["ImageProfile"] as? String
                
            }
        })
    }
    
    
    func loadDataUserLike(){
        let table = ref.child("TableUserLike")
        var tableUserLike:Dictionary<String,AnyObject> = Dictionary()
        tableUserLike.updateValue(self.imgURL as AnyObject, forKey: "imgProfile")
        tableUserLike.updateValue(self.username as AnyObject, forKey: "name")
        
        let newtable = table.child((home?.id)!).child((auth?.currentUser?.uid)!)
        newtable.setValue(tableUserLike) { (error, data) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }else{
                ProgressHUD.showSuccess()
            }
        }
    }
    
    
}
    
    
    
    


