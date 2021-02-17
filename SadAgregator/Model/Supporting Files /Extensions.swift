//
//  Extensions.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.12.2020.
//

import UIKit
import RealmSwift
import SwiftyJSON
import MobileCoreServices

//MARK: - String

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
}

//MARK: - URL

extension URL {
    func mimeType() -> String {
        
        let pathExtension = self.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
        
    }
    
}

//MARK: - UIImageView

extension  UIImageView{
    func load(url: URL){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

//MARK: - UIViewController (DB)

extension UIViewController {
    
    func getUserDataObject () -> UserData?{
        
        let realm = try! Realm()
        
        let userData = realm.objects(UserData.self)
        
        if let userDataObject = userData.first{
            return userDataObject
        }
        
        return nil
    }
    
    func getKey() -> String?{
        
        return getUserDataObject()?.key
        
    }
    
}

//MARK: - UIViewController (Alerts)

extension UIViewController{
    
    func showSimpleAlertWithOkButton(title : String? , message : String? , dismissButtonText : String = "Ок"){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: dismissButtonText, style: .cancel) { (_) in
            
            alertController.dismiss(animated: true, completion: nil)
            
        }
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showActionsSheet(actionsArray : [JSON] , _ selectionCallBack : @escaping (_ action : JSON) -> Void){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionsArray.forEach { (action) in
            
            let alertAction = UIAlertAction(title: action["capt"].stringValue, style: .default) { (_) in
                
                selectionCallBack(action)
                
            }
            
            alertController.addAction(alertAction)
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

//MARK: - UIViewController(animations)

extension UIViewController {
    
    func showSimpleCircleAnimation(activityController : UIActivityIndicatorView){
        
        activityController.center = self.view.center
        
        activityController.style = .large
        
        activityController.startAnimating()
        
        self.view.addSubview(activityController)
        
    }
    
    func stopSimpleCircleAnimation(activityController : UIActivityIndicatorView){
        
        activityController.removeFromSuperview()
        
        activityController.stopAnimating()
        
    }
    
}

//MARK: - UIView

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
}

//MARK: - RoundedCornerView

class RoundedCornerView: UIView {

    // if cornerRadius variable is set/changed, change the corner radius of the UIView
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
}


