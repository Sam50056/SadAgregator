//
//  HelpView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.01.2021.
//

import SwiftUI
import SwiftyJSON

struct HelpView: View {
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
    @State var help = [HelpViewItem]()
    
    var body: some View {
        
        ScrollView{
            
            VStack{
                
                VStack{
                    
                    ForEach(help , id: \.id){ helpItem in
                        
                        
                        Button(action: {
                            
                            if helpItem.text != "" {
                                
                                
                                
                            }
                            
                        }){
                            
                            VStack(alignment: .leading){
                                
                                Spacer().frame(height: 16)
                                
                                HStack{
                                    
                                    Text(helpItem.capt)
                                        .lineLimit(5)
                                    
                                    Spacer()
                                    
                                    if helpItem.text != "" {
                                        
                                        if helpItem.isDroppedDown{
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(Color(.systemBlue))
                                        }else{
                                            Image(systemName: "chevron.up")
                                                .foregroundColor(Color(.systemBlue))
                                        }
                                        
                                    }
                                    
                                }
                                
                                Spacer().frame(height: 16)
                                
                                Divider()
                                
                            }
                            
                        }
                        
                    }
                    
                }
                .padding(.horizontal)
                
            }
            .frame(maxWidth : .infinity)
        }
        .onAppear{
            
            guard let key = menuViewModel.getUserDataObject()?.key else {return}
            
            HelpPageDataManager(delegate: self).getHelpPageData(key: key)
        }
        
    }
    
}

//MARK: - HelpPageDataManagerDelegate

extension HelpView : HelpPageDataManagerDelegate{
    
    func didGetHelpPageData(data: JSON) {
        
        DispatchQueue.main.async {
            
            let helpJsonArray = data["help"].arrayValue
            
            var newHelpArray = [HelpViewItem]()
            
            helpJsonArray.forEach { (helpItemJson) in
                
                newHelpArray.append(HelpViewItem(id: helpItemJson["id"].stringValue, capt: helpItemJson["capt"].stringValue, text: helpItemJson["text"].stringValue, url: helpItemJson["url"].stringValue))
                
            }
            
            withAnimation{
                
                self.help = newHelpArray
                
            }
            
        }
        
    }
    
    func didFailGettingHelpPageData(error: String) {
        print("Error with  HelpPageDataManager : \(error)")
    }
    
}

//MARK: - HelpViewItem

struct HelpViewItem  : Identifiable{
    
    let id : String
    let capt : String
    let text : String
    let url : String
    var isDroppedDown : Bool = false
    
}
