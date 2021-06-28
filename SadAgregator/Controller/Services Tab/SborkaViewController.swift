//
//  SborkaViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.06.2021.
//

import UIKit
import SwiftUI
import SwiftyJSON

struct SborkaView : View {
    
    @State var items = [Item]()
    
    var key = ""
    
    var body: some View{
        
        VStack{
            
            GeometryReader{ geometry in
                
                List{
                    
                    OutlineGroup(items, children: \.children) { item in
                        
                        Text(item.title)
                            .font(.system(size: 15))
                        
                        let title1Width = item.title.width(withConstrainedHeight : 25 , font: UIFont.systemFont(ofSize: 15))
                        let title2Width = item.title2.width(withConstrainedHeight : 25 , font: UIFont.systemFont(ofSize: 15))
                        let title3Width = item.title3.width(withConstrainedHeight : 25 , font: UIFont.systemFont(ofSize: 15))
                        
                        Spacer()
                            .frame(width: (geometry.size.width / 2) - title1Width - 32)
                        
                        Text(item.title2 + " шт.")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.systemGray))
                        
                        Spacer()
                            .frame(width: (geometry.size.width / 2) - title3Width - title2Width - 76)
                        
                        Text(item.title3 + " руб.")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.systemGray))
                        
                    }
                    
                }
                //                .listStyle(ListStyle)
                
            }
            
        }
        .navigationTitle("Структура рынка")
        .onAppear{
            AssemblySegmentsInAssemblyDataManager(delegate: self).getAssemblySegmentsInAssemblyData(key: key, parentSegment: "", status: "", helperId: "")
        }
        
    }
    
}


struct Item: Identifiable {
    let id = UUID()
    let segId : String
    let title: String
    let title2 : String
    let title3 : String
    let children: [Item]?
}

//MARK: - AssemblySegmentsInAssemblyDataManager

extension SborkaView : AssemblySegmentsInAssemblyDataManagerDelegate{
    
    func didGetAssemblySegmentsInAssemblyData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let jsonItems = data["segments"].arrayValue
                
                var newItems = [Item]()
                
                jsonItems.forEach { jsonItem in
                    newItems.append(Item(segId: jsonItem["seg_id"].stringValue, title: jsonItem["seg_name"].stringValue, title2: jsonItem["cnt"].stringValue , title3: jsonItem["summ"].stringValue , children: nil))
                }
                
                items = newItems
                
            }
            
        }
        
    }
    
    func didFailGettingAssemblySegmentsInAssemblyDataWithError(error: String) {
        print("Error with AssemblySegmentsInAssemblyDataManager : \(error)")
    }
    
}
//
//extension Item {
//
//    static var stubs: [Item] {
//        [
//            Item(title: "Computers", children: [
//                Item(title: "Desktops", children: [
//                    Item(title: "iMac", children: nil),
//                    Item(title: "Mac Mini", children: nil),
//                    Item(title: "Mac Pro", children: nil)
//                ]),
//                Item(title: "Laptops", children: [
//                    Item(title: "MacBook Pro", children: nil),
//                    Item(title: "MacBook Air", children: nil),
//                ])
//            ]),
//            Item(title: "Smartphones", children: [
//                Item(title: "iPhone 11", children: nil),
//                Item(title: "iPhone XR", children: nil),
//                Item(title: "iPhone XS Max", children: nil),
//                Item(title: "iPhone X", children: nil)
//            ]),
//            Item(title: "Tablets", children: [
//                    Item(title: "iPad Pro", children: nil),
//                    Item(title: "iPad Air", children: nil),
//                    Item(title: "iPad Mini", children: nil),
//                    Item(title: "Accessories", children: [
//                        Item(title: "Magic Keyboard", children: nil),
//                        Item(title: "Smart Keyboard", children: nil)
//                    ])]),
//            Item(title: "Wearables", children: [
//                Item(title: "Apple Watch Series 5", children: nil),
//                Item(title: "Apple Watch Series 3", children: nil),
//                Item(title: "Bands", children: [
//                    Item(title: "Sport Band", children: nil),
//                    Item(title: "Leather Band", children: nil),
//                    Item(title: "Milanese Band", children: nil)
//                ])
//            ])
//        ]
//    }
//}
