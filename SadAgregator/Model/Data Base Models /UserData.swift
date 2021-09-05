//
//  UserData.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.12.2020.
//

import Foundation
import RealmSwift

class UserData : Object{
    
    @objc dynamic var key : String = ""
    
    @objc dynamic var isLogged : Bool = false
    
    @objc dynamic var code : String = ""
    @objc dynamic var name : String = ""
    @objc dynamic var lkVends : String = ""
    @objc dynamic var lkBrokers : String = ""
    @objc dynamic var lkPosts : String = ""
    
    @objc dynamic var isVendor : String = ""
    
    @objc dynamic var imageHashSearch : String = ""
    @objc dynamic var imageHashServer : String = ""
    
    @objc dynamic var settings : String = ""
    
    @objc dynamic var exportType : String = ""
    @objc dynamic var exportFast : String = ""
    
}
