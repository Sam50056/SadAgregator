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
