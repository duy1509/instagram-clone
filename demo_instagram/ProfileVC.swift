//
//  ProfileVC.swift
//  demo_instagram
//
//  Created by DUY on 5/17/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import MobileCoreServices
import Kingfisher

class ProfileVC: UIViewController {
    var arrImage:Array<String> = []
    @IBOutlet weak var txtNameProfile: UILabel!
    @IBOutlet weak var imgHinh: UIImageView!
    @IBOutlet weak var imgBackgroup: UIImageView!
    
    @IBOutlet weak var coProfile: UICollectionView!
    
    let ref = FIRDatabase.database().reference(fromURL: "https://instagram-d9b3c.firebaseio.com/")
    let auth = FIRAuth.auth()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        loadImage()
        coProfile.delegate = self
        coProfile.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        self.imgHinh.layer.cornerRadius = 50
//        self.imgHinh.layer.borderWidth = 1
        self.imgHinh.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.imgHinh.layer.cornerRadius = self.imgHinh.frame.size.height / 2
        self.imgHinh.layer.masksToBounds = true
        self.imgHinh.clipsToBounds = true

        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnInfo(_ sender: Any) {
        let profile = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ThongTinVC
        self.present(profile, animated: true, completion: nil)
    }
    
    
    func loadData(){
        ref.child("User").child((auth?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { [weak self](snapshot) in
            let value = snapshot.value as! Dictionary<String,AnyObject>
            self?.txtNameProfile.text = value["name"] as? String
            let url = URL(string: (value["ImageProfile"] as? String)!)
            self?.imgHinh.kf.setImage(with: url)
        })
    }
    
    func loadImage(){
        ref.child("ImgLoad").child((auth?.currentUser?.uid)!).observeSingleEvent(of: .childAdded, with: { [weak self](snapshot) in
            let value = snapshot.value as! Dictionary<String,AnyObject>
            let imgURL = value["ImageURL"] as? String
            self?.arrImage.append(imgURL!)
            
            DispatchQueue.main.async {
                self?.coProfile.reloadData()
            }
        })
    }
    
    
    
}
extension ProfileVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImage.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCoCell
        let url = URL(string: arrImage[indexPath.row])
        cell.imgHinhLoad.kf.setImage(with: url)
        return cell
    }
}


    
    
    
    

