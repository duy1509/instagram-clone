//
//  HomeUserLike.swift
//  demo_instagram
//
//  Created by DUY on 6/9/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class HomeUserLike: UIViewController {

    @IBOutlet weak var tbvHienthi: UITableView!
        let ref = FIRDatabase.database().reference(fromURL: "https://instagram-d9b3c.firebaseio.com/")
    let auth = FIRAuth.auth()
    var userlike:String?
    var arrUserLike:[HomeItem] = []
    var home:HomeItem?
    var id:String?
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
    @IBAction func btnBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func LoadData(){
        ref.child("TableUserLike").child(id!).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if let value = snapshot.value as? Dictionary<String,AnyObject>{
                var userlike = HomeItem()
                userlike.id = snapshot.key
                userlike.imgURL = value["imgProfile"] as? String
                userlike.name = value["name"] as? String
                
                self.arrUserLike.append(userlike)
                
                DispatchQueue.main.async {
                    self.tbvHienthi.reloadData()
                }
            }
            
        })
    
    }


}
extension HomeUserLike:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserLike.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserLike
        cell.lblName.text = arrUserLike[indexPath.row].name
        let url = URL(string: arrUserLike[indexPath.row].imgURL!)
        cell.imgHinh.kf.setImage(with: url)
        
        return cell
    }
    
}
