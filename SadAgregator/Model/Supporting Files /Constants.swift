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
    
    static let sortTime = "sortTime" //Time parameter for sortirovka/scan //Float param
    static let sortAutoHide = "sortAutoHide" // Bool
    static let notFirstTimeSortOpened = "notFirstTimeOpenSort" // Bool
    
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
        let cellHeight : CGFloat = 35
        
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
        
        if thisTovar.qr != "" , thisTovar.qr != "-1" , !isZamena{
            height += cellHeight
        }
        
        if thisTovar.status != "" , thisTovar.status != "-1" ,!isZamena{
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
        
        if thisTovar.shipmentImage != ""{
            height += cellHeight
        }
        
        if thisTovar.defCheck == "1"{
            height += cellHeight
        }
        
        if thisTovar.withoutRep == "1"{
            height += cellHeight
        }
        
        if isZamena{
            height += 52//This is for the footer button
        }
        
        return height < 235 ? 235 : height
        
    }
    
    static func makeHeightForBrokerCell(broker : JSON) -> CGFloat{
        
        var height : CGFloat = 0
        
        let topPartHeight : CGFloat = 90
        
        if let phone = broker["phone"].string , phone != ""{
            height += 32
        }
        
        height += 32 * CGFloat(broker["rates"].arrayValue.isEmpty ? 0 : broker["rates"].arrayValue.count + 1)
        
        height += 32 * CGFloat(broker["parcels"].arrayValue.isEmpty ? 0 : broker["parcels"].arrayValue.count + 1)
        
        height += topPartHeight
        
        return height
        
    }
    
    static func makeHeightForZakupkaCell(data : JSON) -> CGFloat{
        
        var height : CGFloat = 0
        
        let defaultCellHeight : CGFloat = 38
        
        if data["capt"].stringValue != ""{
            height += 45
        }
        
        if data["cnt_items"].stringValue != ""{
            height += defaultCellHeight
        }
        
        if data["cnt_items"].stringValue != "" , data["cnt_items"].stringValue != "0"{
            height += defaultCellHeight
        }
        
        if !data["money"].arrayValue.isEmpty{
            height += (30 * CGFloat(data["money"].arrayValue.count))
        }
        
        if data["items"]["wait"].intValue > 1{
            height += 30
        }
        
        if let bought = data["items"]["bought"].string , bought != "" , bought != "0"{
            height += 30
        }
        
        if let notAviable = data["items"]["not_aviable"].string , notAviable != "" , notAviable != "0"{
            height += 30
        }
        
        if data["cnt_points"].stringValue != "" , data["cnt_points"].stringValue != "0"{
            height += defaultCellHeight
        }
        
        if data["handler_type"].stringValue != ""{
            height += defaultCellHeight
        }
        
        if data["profit"].stringValue != "" , data["profit"].stringValue != "0"{
            height += defaultCellHeight
        }
        
        if data["postage_cost"].stringValue != "" , data["postage_cost"].stringValue != "0"{
            height += defaultCellHeight
        }
        
        height += 50
        
        height += 8
        
        return height
        
    }
    
}
