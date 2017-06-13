//
//  SearchTBV.swift
//  demo_instagram
//
//  Created by DUY on 6/8/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class SearchTBV: UITableViewController,UISearchResultsUpdating {
    var arrUser:[User] = []
    let ref = FIRDatabase.database().reference(fromURL: "https://instagram-d9b3c.firebaseio.com/")
    let auth = FIRAuth.auth()
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    var filtereArray = [User]()

    @IBOutlet var tbvHienthi: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadata()
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        
        
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource  = self
        
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.definesPresentationContext = false
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadata(){
        ref.child("User").observe(.childAdded, with: { (snapshot) in
            if let value = snapshot.value as? Dictionary<String,AnyObject>{
                var user = User()
                user.name = value["name"] as? String
                user.image = value["ImageProfile"] as? String
                
                self.arrUser.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }) { (error) in
            ProgressHUD.showError()
        }
        
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filtereArray = arrUser.filter({ (arr:User) -> Bool in
            if (arr.name?.lowercased().contains(searchController.searchBar.text!.lowercased()))!{
                return true
            }else{
                return false
            }
        })

        resultsController.tableView.reloadData()
    }


    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultsController.tableView {
            return filtereArray.count
        }else {
            return arrUser.count
        }

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if tableView == resultsController.tableView {
            cell.textLabel?.text = filtereArray[indexPath.row].name
        }else {
            cell.textLabel?.text = arrUser[indexPath.row].name
        }

        return cell
    }
 

}
