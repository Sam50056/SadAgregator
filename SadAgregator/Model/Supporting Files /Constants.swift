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
    
    static let postTitle = "postTitle"
    static let shouldShowButtonsViewInGallery = "showButtonsViewInGallery"
    static let notFirstTimeGalleryOpened = "notFirstTimeGalleryOpened"
    
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
    
    static func makeHeightForTovarCell(thisTovar : TovarCellItem , contentType : TovarTableViewCell.ContentType , width : CGFloat) -> CGFloat{
        
        var height : CGFloat = 0
        let cellHeight : CGFloat = 35 //35
        
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
        
        if thisTovar.sellCost != "" , thisTovar.sellCost != "0"{
            height += cellHeight
        }
        
        if thisTovar.clientName != "" {
            height += cellHeight
        }
        
        if thisTovar.qr != "" , thisTovar.qr != "-1" , contentType != .zamena{
            height += cellHeight
        }
        
        if thisTovar.status != "" , thisTovar.status != "-1" , contentType != .zamena{
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
        
        if contentType == .zamena{
            height += 52//This is for the footer button
        }
        
        if contentType == .order , thisTovar.shouldShowBottomStackView{
            height += 48
        }
        
        if contentType == .order , !thisTovar.comExt.isEmpty{
            
            let comment = thisTovar.comExt.replacingOccurrences(of: "<br>", with: "\n")
            
            height += 30 //25
            
            let oneLineSymbolCount = width / 7
            
            //            print("One line symbol count: \(oneLineSymbolCount)")
            
            var linesCount = (CGFloat(comment.count) / oneLineSymbolCount).rounded(.awayFromZero)
            
            if comment.contains("\n"){
                
                for s in comment {
                    
                    if s == "\n"{
                        linesCount += 1
                    }
                    
                }
               
            }
            
            //            print("Lines count : \(linesCount)")
            
            height += linesCount * 28
            
        }
        
//        height += 8
        
        if contentType == .order{
            if thisTovar.shouldShowBottomStackView , !thisTovar.comExt.isEmpty{
                
                var commentHeight : CGFloat = 0
                
                commentHeight += 10 //comment view without textView
                
                let comment = thisTovar.comExt.replacingOccurrences(of: "<br>", with: "\n")
                
                let oneLineSymbolCount = width / 7
                
                var linesCount = (CGFloat(comment.count) / oneLineSymbolCount).rounded(.awayFromZero)
                
                if comment.contains("\n"){
                    linesCount += 1
                }
                
                commentHeight += linesCount * 28
                
                return height < (224 + commentHeight) ? (224 + commentHeight) : height
                
            }else if thisTovar.shouldShowBottomStackView{
                return height < 224 ? 224 : height
            }else if !thisTovar.comExt.isEmpty{
                
                var commentHeight : CGFloat = 0
                
                commentHeight += 16
                
                let comment = thisTovar.comExt.replacingOccurrences(of: "<br>", with: "\n")
                
                let oneLineSymbolCount = width / 7
                
                var linesCount = (CGFloat(comment.count) / oneLineSymbolCount).rounded(.awayFromZero)
                
                if comment.contains("\n"){
                    linesCount += 1
                }
                
                commentHeight += linesCount * 28
                
                return height < (174 + commentHeight) ? (174 + commentHeight) : height
                
            }else{
                return height < 174 ? 174 : height
            }
        }else{
            
            if thisTovar.commentMessage != ""{

                var commentHeight : CGFloat = 0

                commentHeight += 16

                let comment = thisTovar.commentMessage.replacingOccurrences(of: "<br>", with: "\n")

                let oneLineSymbolCount = width / 7

                var linesCount = (CGFloat(comment.count) / oneLineSymbolCount).rounded(.awayFromZero)

                if comment.contains("\n"){
                    linesCount += 1
                }

                commentHeight += linesCount * 28

                if thisTovar.commentTitle != ""{
                    commentHeight += 25 + 8
                }
                
                height += commentHeight

                return height < (160 + commentHeight) ? (160 + commentHeight) : height
                
            }
            
        }
        
        return height < 160 ? 160 : height //235
        
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
        
        if !data.replaces.isEmpty , data.replaces != "0"{
            height += defaultCellHeight
        }
        
        if !data.deliveryType.isEmpty{
            height += defaultCellHeight
        }
        
        if !data.statusName.isEmpty{
            height += defaultCellHeight
        }
        
        if !data.comment.isEmpty{
        
            height += 60
            
            let comment = data.comment.replacingOccurrences(of: "<br>", with: "\n")
            
            let oneLineSymbolCount = width / 7
            
            //            print("One line symbol count: \(oneLineSymbolCount)")
            
            var linesCount = (CGFloat(comment.count) / oneLineSymbolCount).rounded(.awayFromZero)
            
            if comment.contains("\n"){
                
                for s in comment {
                    
                    if s == "\n"{
                        linesCount += 1
                    }
                    
                }
               
            }
            
            //            print("Lines count : \(linesCount)")
            
            height += linesCount * 24
            
            if linesCount == 1{
                height += 6
            }
            
        }
        
        if data.isShownForOneZakaz{
            height += 60
        }
        
        height += 8
        
        return height
        
    }
    
}
