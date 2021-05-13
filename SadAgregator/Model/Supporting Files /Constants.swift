//
//  Constants.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.12.2020.
//

import UIKit
import SwiftyJSON

struct K {
    
    //MARK: - Device Info
    
    static var appVersion : String {
        
        guard let safeAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { fatalError("Can't get app's version") }
        
        // print("APP VERSION: \(safeAppVersion)")
        
        return safeAppVersion
        
    }
    
    //MARK: - UserDefaults keys
    
    static let UNToken = "UNtoken" //User Notifications Token
    
    //MARK: - Design vars
    
    static let postHeight : CGFloat = 600
    
    static let simpleCellHeight : CGFloat = 60
    
    static let simpleHeaderCellHeight : CGFloat = 50
    
    //MARK: - Design funcs
    
    static func makeHeightForVendCell(vend : JSON) -> CGFloat {
        
        var height = 80
        
        let phone = vend["ph"].stringValue
        //let pop = vend["pop"].intValue
        let rating = vend["rate"].stringValue
        
        if rating != "0" {
            height += 15
        }
        
        if phone != "" {
            height += 15
        }
        
        height += 10 // We do + 10 because anyways if pop is o or something else , we show that on screen
        
        return CGFloat(height)
    }
    
    static func makeHeightForVendRatingCell(vendRatingCell : JSON) -> CGFloat{
        
        var height = 125
        
        let prices = vendRatingCell["prices"].stringValue
        
        let rating = vendRatingCell["avg_rate"].stringValue
        
        if rating != "0" {
            height += 10
        }
        
        if prices != "" {
            height += 10
        }
        
        height += 10 // We do + 10 because anyways if pop is o or something else , we show that on screen
        
        return CGFloat(height)
        
    }
    
    static func makeHeightForTovarCell(thisTovar : TovarCellItem , isZamena : Bool) -> CGFloat{
        
        var height : CGFloat = 0
        let cellHeight : CGFloat = 38
        
        if thisTovar.capt != "" {
            height += cellHeight
        }
        
        if thisTovar.size != "" {
            height += cellHeight
        }
        
        if thisTovar.payed != "" , thisTovar.payed != "0"{
            height += cellHeight
        }
        
        if thisTovar.purCost != ""{
            height += cellHeight
        }
        
        if thisTovar.sellCost != "" {
            height += cellHeight
        }
        
        if thisTovar.clientName != "" {
            height += cellHeight
        }
        
        if thisTovar.qr != "" , !isZamena{
            height += cellHeight
        }
        
        if thisTovar.status != "" , !isZamena{
            height += cellHeight
        }
        
        if thisTovar.isReplace != "" , thisTovar.isReplace != "0" {
            height += cellHeight
        }
        
        if thisTovar.status != "" {
            height += cellHeight
        }
        
        if thisTovar.replaces != "" , thisTovar.replaces != "0"{
            height += cellHeight
        }
        
        height += 62//This is for the footer button
        
        return height
        
    }
    
}
