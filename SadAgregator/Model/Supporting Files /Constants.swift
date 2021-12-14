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
    
    static func makeHeightForZakupkaCell(data : ZakupkaTableViewCell.Zakupka) -> CGFloat{
        
        var height : CGFloat = 0
        
        let defaultCellHeight : CGFloat = 38
        
        if data.capt != ""{
            height += 45
        }
        
        if data.replaces != "" , data.replaces != "0"{
            height += defaultCellHeight
        }
        
        if data.countClients != "" , data.countClients != "0"{
            height += defaultCellHeight
        }
        
        //        if data.countItems != ""{
        height += defaultCellHeight
        //        }
        
        if !data.money.isEmpty{
            height += defaultCellHeight
        }
        
        if !data.money.isEmpty , data.openMoney{
            height += (30 * CGFloat(data.money.count))
        }
        
        if let wait = Int(data.itemsWait) , wait >= 1 , data.openTovars{
            height += 30
        }
        
        if data.itemsBought != "" , data.itemsBought != "0" , data.itemsBought != "" , data.openTovars{
            height += 30
        }
        
        if data.itemsNotAvailable != "" , data.itemsNotAvailable != "0" , data.itemsNotAvailable != "0" , data.openTovars{
            height += 30
        }
        
        if data.countPoints != "" , data.countPoints != "0" , data.countPoints != ""{
            height += defaultCellHeight
        }
        
        if data.handlerType != ""{
            height += defaultCellHeight
        }
        
        if data.profit != "" , data.profit != "0" , data.profit != ""{
            height += defaultCellHeight
        }
        
        if data.postageCost != "" , data.postageCost != "0" , data.postageCost != ""{
            height += defaultCellHeight
        }
        
        if !data.images.isEmpty{
            height += defaultCellHeight
        }
        
        if !data.images.isEmpty , data.openDocs{
            height += 80
        }
        
        height += 50
        
        height += 8
        
        return height
        
    }
    
    static func makeHeightForZakazCell(data : ZakazTableViewCell.Zakaz , width : CGFloat) -> CGFloat {
        
        var height : CGFloat = 0
        
        let defaultCellHeight : CGFloat = 38
        
        height += 70 //Header
        
        if !data.clientBalance.isEmpty , data.clientBalance != "0" {
            height += defaultCellHeight
        }
        
        if !data.itemsCount.isEmpty , data.itemsCount != "0"{
            height += defaultCellHeight
        }
        
        if !data.deliveryType.isEmpty{
            height += defaultCellHeight
        }
        
        if !data.statusName.isEmpty{
            height += defaultCellHeight
        }
        
        if !data.comment.isEmpty{
            if data.comment.count >= 150{
                height += 135
            }else if data.comment.count >= 100{
                height += 105
            }else{
                height += 85
            }
        }
        
        if !data.comment.isEmpty{
            height += data.comment.heightWithConstrainedWidth(width: width, font: UIFont.systemFont(ofSize: 15))
            //            height += 8
        }
        
        if data.isShownForOneZakaz{
            height += 60
        }
        
        height += 8
        
        return height
        
    }
    
}
