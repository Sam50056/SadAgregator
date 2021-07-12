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
                                    sborkaViewModel.pointsInSegmentsView.pointsInSborkaSegmentViewModel.thisSegmentName = item.title
                                    
                                    sborkaViewModel.pointsInSegmentsView.pointsInSborkaSegmentViewModel.key = sborkaViewModel.key
                                    
                                    sborkaViewModel.showPointsView = true
                                    
                                }
                                
                            }
                            .onLongPressGesture {
                                
                                sborkaViewModel.selectedByLongPressSegment = item
                                
                                sborkaViewModel.alertTitle = sborkaViewModel.helperID == "" ? "Передать сегмент помощнику?" :  "Забрать сегмент у помощника?"
                                sborkaViewModel.alertMessage = nil
                                sborkaViewModel.showAlert = true
                                
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
        .alert(isPresented: $sborkaViewModel.showAlert, content: {
            Alert(title: Text(sborkaViewModel.alertTitle), message: sborkaViewModel.alertMessage != nil ? Text(sborkaViewModel.alertMessage!) : nil, primaryButton: .cancel(Text("Отмена")), secondaryButton: .default(Text(sborkaViewModel.alertButtonText), action: {
                
                if sborkaViewModel.helperID != "" { //Smotrit ne ot sebya
                    
                    sborkaViewModel.takeSegmentFrom(sborkaViewModel.helperID)
                    
                }else{//Smotrit ot sebya
                    
                    //Getting the list of helpers for user to choose who is he giving the segment to
                    sborkaViewModel.getHelpers()
                    
                }
                
            }))
        })
        .sheet(isPresented: $sborkaViewModel.showHelperListSheet, content: {
            
            NavigationView{
                
                VStack{
                    
                    List{
                        
                        ForEach(sborkaViewModel.helpers, id: \.id){ helper in
                            
                            HStack{
                                
                                Text(helper.capt)
                                
                                Spacer()
                                
                            }
                            .onTapGesture {
                                
                                if let _ = sborkaViewModel.selectedByLongPressSegment{
                                    
                                    sborkaViewModel.giveSegmentTo(helper.id)
                                    
                                }else{
                                    
                                    sborkaViewModel.helperID = helper.id
                                    sborkaViewModel.updateSegments()
                                    
                                    sborkaViewModel.showHelperListSheet = false
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                .navigationBarTitle("Помощники", displayMode: .inline)
                
            }
            .alert(isPresented: $sborkaViewModel.showAlertInHelperView , content : {
                
                Alert(title: Text(sborkaViewModel.alertInHelperViewTitle), message: sborkaViewModel.alertInHelperViewMessage != nil ? Text(sborkaViewModel.alertInHelperViewMessage!) : nil, dismissButton: .default(Text(sborkaViewModel.alertInHelperViewButtonText), action: {
                    
                    sborkaViewModel.showHelperListSheet = false
                    
                }))
                
            })
            
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                Button(action:{
                    sborkaViewModel.getHelpers(inSborka: true)
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
        .navigationBarTitle(Text("Сборка"))
        
    }
    
}
