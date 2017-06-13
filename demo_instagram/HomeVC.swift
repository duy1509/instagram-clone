//
//  HomeVC.swift
//  demo_instagram
//
//  Created by DUY on 5/17/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation
import MobileCoreServices
import Kingfisher

class HomeVC: UIViewController {

    @IBOutlet weak var tbvHienthi: UITableView!
    var arrHomeItem:[HomeItem] = []
    let ref = FIRDatabase.database().reference(fromURL: "https://instagram-d9b3c.firebaseio.com/")
    var aut = FIRAuth.auth()
    var user:User?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HomeVC"
        ProgressHUD.show("Waiting...!")
        layData()
        loadData()
        tbvHienthi.delegate = self
        tbvHienthi.dataSource  = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layData(){
        ref.child("User").child((aut?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { [weak self](snapshot) in
            if let value = snapshot.value as? Dictionary<String,AnyObject>{
                var userParse = User()
                userParse.name = value["name"] as? String
                userParse.image = value["ImageProfile"] as? String
                self?.user = userParse
                
                }
            }
        )
    }
    
    
    func loadData(){
        ref.child("Table").observe(.childAdded, with: { [weak self](snapshot) in
            let value = snapshot.value as! Dictionary<String,AnyObject>
            var home = HomeItem()
            home.id = snapshot.key
            home.name = value["name"] as? String
            home.imgURL = value["ImageProfile"] as? String
            home.status = value["Status"] as? String
            home.imgLoadHinh = value["ImgageLoad"] as? String
            home.likes = value["likes"] as? Dictionary<String,AnyObject>
            home.likeCount = value["likeCount"] as? Int
            if let currentUserID = FIRAuth.auth()?.currentUser?.uid {
                if home.likes != nil {
                    home.isLiked = home.likes![currentUserID] != nil
                }
            }
            
            
            self?.arrHomeItem.append(home)
            
            DispatchQueue.main.async {
                ProgressHUD.showSuccess()
                self?.tbvHienthi.reloadData()
            }

        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
    }
}
extension HomeVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHomeItem.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeCell
        let home = arrHomeItem[indexPath.row]
        cell.home = home
        cell.lblName.text = arrHomeItem[indexPath.row].name
        cell.lblName2.text = "\(arrHomeItem[indexPath.row].name!):"
        cell.lblStatus.text = arrHomeItem[indexPath.row].status
        let url = URL(string: arrHomeItem[indexPath.row].imgURL!)
        cell.imgProfile.kf.setImage(with: url)
        let urlString = URL(string: arrHomeItem[indexPath.row].imgLoadHinh!)
        cell.imgHinh.kf.setImage(with: urlString)
        let imageName = arrHomeItem[indexPath.row].likes == nil || !arrHomeItem[indexPath.row].isLiked! ? "like" : "likeSelected"
        cell.btnLike.setImage(UIImage(named:imageName), for: .normal)
        if let count = arrHomeItem[indexPath.row].likeCount {
            if count != 0 {
                cell.btnUserLike.setTitle("\(count) Likes", for: .normal)
            } else if arrHomeItem[indexPath.row].likeCount == 0 {
                cell.btnUserLike.setTitle("Be the first to Like this", for: .normal)
            }
        }
        
        
        
        cell.acctionbuttonLike = { [weak self] sender in
            guard let strongSelf = self else { return }
        }
        cell.acctionbuttonUserLike = { [weak self] in
            guard let strongSelf = self else { return }
            
            let tableUser = strongSelf.storyboard?.instantiateViewController(withIdentifier: "UserLike") as! HomeUserLike
            tableUser.id = strongSelf.arrHomeItem[indexPath.row].id
            strongSelf.navigationController?.pushViewController(tableUser, animated: true)
        }
        cell.acctionbuttonComment = { [weak self] sender in
            guard let strongSelf = self else { return }
            let comment = self?.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            comment.user = strongSelf.user
            comment.id = strongSelf.arrHomeItem[indexPath.row].id
            strongSelf.navigationController?.pushViewController(comment, animated: true)

        }
        cell.selectionStyle = .none
        return cell
    }
}
