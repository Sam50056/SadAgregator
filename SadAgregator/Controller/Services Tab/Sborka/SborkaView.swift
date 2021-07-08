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
        
        ZStack{
            
            ScrollView{
                
                LazyVStack{
                    
                    ForEach(sborkaViewModel.items , id: \.id){ item in
                        
                        HStack{
                            
                            Spacer(minLength: 0)
                                .frame(width: CGFloat((item.parentsCount * 10)))
                            
                            VStack{
                                
                                ZStack{
                                    
                                    HStack{
                                        
                                        Text(item.title)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8){
                                            
                                            Text(item.title3 + " руб.")
                                                .foregroundColor(Color(.systemGray))
                                            
                                            Image(systemName: !item.isOpened ? "chevron.right" : "chevron.down")
                                                .foregroundColor(Color(.systemBlue))
                                            //                                            .animation(.default)
                                            
                                        }
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    Text(item.title2 + " шт.")
                                        .foregroundColor(Color(.systemGray))
                                    
                                    Spacer()
                                    
                                }
                                
                                Divider()
                                
                            }
                            .onTapGesture {
                                
                                if !item.canGoForDot {
                                    
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
                                    
                                }else{
                                    
                                    sborkaViewModel.pointsInSegmentsView.pointsInSborkaSegmentViewModel.thisSegmentId = item.segId
                                    
                                    sborkaViewModel.pointsInSegmentsView.pointsInSborkaSegmentViewModel.key = sborkaViewModel.key
                                    
                                    sborkaViewModel.showPointsView = true
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                .padding(.top , 16)
                .padding(.horizontal)
                
            }
            
            NavigationLink(destination: sborkaViewModel.pointsInSegmentsView, isActive: $sborkaViewModel.showPointsView) {
                EmptyView()
            }
            
        }
        .sheet(isPresented: $sborkaViewModel.showHelperListSheet, content: {
            
            VStack{
                
                List{
                    
                    ForEach(sborkaViewModel.helpers, id: \.id){ helper in
                        
                        HStack{
                            
                            Text(helper.capt)
                            
                            Spacer()
                            
                        }
                        .onTapGesture {
                            sborkaViewModel.helperID = helper.id
                            sborkaViewModel.updateSegments()
                        }
                        
                    }
                    
                }
                
            }
            
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                Button(action:{
                    sborkaViewModel.getHelpers()
                }){
                    Image(systemName : "person")
                }.contextMenu(ContextMenu(menuItems: {
                    Button("Смотреть от себя"){
                        sborkaViewModel.helperID = ""
                        sborkaViewModel.updateSegments()
                    }
                }))
                
                Menu {
                    Button("Не обработаны", action: {
                        sborkaViewModel.changeStatus(to: "0")
                    })
                    Button("Нет в наличии", action: {
                        sborkaViewModel.changeStatus(to: "1")
                    })
                    Button("Куплены", action: {
                        sborkaViewModel.changeStatus(to: "2")
                    })
                    Button("Любой", action: {
                        sborkaViewModel.changeStatus(to: "")
                    })
                } label: {
                    Image(systemName : "slider.vertical.3")
                        .imageScale(.large)
                }
            }
        }
        .onAppear{
            
            guard sborkaViewModel.items.isEmpty else {return}
            
            sborkaViewModel.updateSegments()
        }
        
    }
    
}
