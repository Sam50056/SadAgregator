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
    
    @ObservedObject var sborkaViewModel = SborkaViewModel()
    
    var body: some View{
        
        ScrollView{
            
            LazyVStack{
                
                ForEach(sborkaViewModel.items , id: \.id){ item in
                    
                    HStack{
                        
                        Spacer(minLength: 0)
                            .frame(width: CGFloat((item.parentsCount * 10)))
                        
                        VStack{
                            
                            HStack{
                                
                                Text(item.title)
                                
                                Spacer()
                                
                                Text(item.title2 + " шт.")
                                    .foregroundColor(Color(.systemGray))
                                
                                Spacer()
                                
                                HStack(spacing: 8){
                                    
                                    Text(item.title3 + " руб.")
                                        .foregroundColor(Color(.systemGray))
                                    
                                    if item.title2 != "" , item.title2 != "0"{
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color(.systemBlue))
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            Divider()
                            
                        }
                        .onTapGesture {
                            
                            guard item.title2 != "" , item.title2 != "0" else {return}
                            
                            let itemIndex = sborkaViewModel.items.firstIndex(where: { searchItem in
                                searchItem.segId == item.segId
                            })
                            
                            if item.isOpened{
                                
                                sborkaViewModel.closeTabWithParentIndex(itemIndex!)
                                
                            }else{
                                
                                sborkaViewModel.thisSegIndex = itemIndex
                                
                                sborkaViewModel.updateSegments(parent: item.segId)
                                
                            }
                            
                            sborkaViewModel.items[itemIndex!].isOpened.toggle()
                            
                        }
                        
                    }
                    
                }
                
            }
            .padding(.top , 16)
            .padding(.horizontal)
            
        }
        .navigationTitle("Структура рынка")
        .onAppear{
            sborkaViewModel.updateSegments()
        }
        
    }
    
}
