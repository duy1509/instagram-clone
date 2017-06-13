//
//  Uitilities.swift
//  demo_instagram
//
//  Created by DUY on 5/19/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import Foundation
import UIKit

struct Uilities {
    static let ShareIntand = Uilities()
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func ShowAlert(title:String,Messenges:String,Viewcontroller:UIViewController){
        let alert:UIAlertController = UIAlertController(title: title, message: Messenges, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        Viewcontroller.present(alert, animated: true, completion: nil)
    }
    
    
}
