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
            
            if sborkaViewModel.items.isEmpty , sborkaViewModel.screenData != nil {
                
                noItemsView
                
            }else{
                
                mainScreen
                
            }
            
            NavigationLink(destination: sborkaViewModel.pointsInSegmentsView
                            .environmentObject(sborkaViewModel)
                           , isActive: $sborkaViewModel.showPointsView) {
                EmptyView()
            }
            
        }
        .alert(isPresented: $sborkaViewModel.showAlert, content: {
            
            if sborkaViewModel.showSimpleAlert {
                
                return Alert(title: Text(sborkaViewModel.alertTitle), message: sborkaViewModel.alertMessage != nil ? Text(sborkaViewModel.alertMessage!) : nil, dismissButton: .default(Text(sborkaViewModel.alertButtonText), action: {
                    
                    sborkaViewModel.updateSegments()
                    
                    sborkaViewModel.selectedByLongPressSegment = nil
                    
                    sborkaViewModel.showAlert = false
                    
                }))
                
            }else{
                
                return Alert(title: Text(sborkaViewModel.alertTitle), message: sborkaViewModel.alertMessage != nil ? Text(sborkaViewModel.alertMessage!) : nil, primaryButton: .cancel(Text("Отмена")), secondaryButton: .default(Text(sborkaViewModel.alertButtonText), action: {
                    
                    if sborkaViewModel.helperID != "" { //Smotrit ne ot sebya
                        
                        sborkaViewModel.takeSegmentFrom(sborkaViewModel.helperID)
                        
                    }else{//Smotrit ot sebya
                        
                        //Getting the list of helpers for user to choose who is he giving the segment to
                        sborkaViewModel.getHelpers()
                        
                    }
                    
                }))
                
            }
            
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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                
                                if let _ = sborkaViewModel.selectedByLongPressSegment{
                                    
                                    sborkaViewModel.giveSegmentTo(helper.id)
                                    
                                }else{
                                    
                                    sborkaViewModel.navBarTitle = "Помощник"
                                    sborkaViewModel.helperID = helper.id
                                    sborkaViewModel.updateSegments()
                                    
                                    sborkaViewModel.showHelperListSheet = false
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    Divider()
                    
                    HStack{
                        
                        Spacer()
                        
                        Text(!sborkaViewModel.shouldShowSmotretOtSebyaInHelperView ? "" : "Смотреть мою сборку")
                            .font(.system(size: 18))
                        
                        Spacer()
                        
                    }
                    .frame(height: 25)
                    .padding(.bottom , 16)
                    .padding(.top , 8)
                    .onTapGesture{
                        
                        guard sborkaViewModel.shouldShowSmotretOtSebyaInHelperView else {return}
                        
                        sborkaViewModel.showHelperListSheet = false
                        sborkaViewModel.smotretOtSebya()
                    }
                    
                }
                
                .navigationBarTitle("Помощники", displayMode: .inline)
                
            }
            .alert(isPresented: $sborkaViewModel.showAlertInHelperView , content : {
                
                if sborkaViewModel.showSimpleAlertInHelperView{
                    
                    return Alert(title: Text(sborkaViewModel.alertInHelperViewTitle), message: sborkaViewModel.alertInHelperViewMessage != nil ? Text(sborkaViewModel.alertInHelperViewMessage!) : nil, dismissButton: .default(Text(sborkaViewModel.alertInHelperViewButtonText), action: {
                        
                        sborkaViewModel.showHelperListSheet = false
                        
                    }))
                    
                }else{
                    
                    return Alert(title: Text(sborkaViewModel.alertInHelperViewTitle), message: sborkaViewModel.alertInHelperViewMessage != nil ? Text(sborkaViewModel.alertInHelperViewMessage!) : nil, primaryButton: .default(Text("Отмена"), action: {
                        
                        //Canceling the done action and doing the oposite
                        
                        guard let _ = sborkaViewModel.givenHelperId else {return}
                        
                        sborkaViewModel.takeSegmentFrom(sborkaViewModel.givenHelperId!, isInHelperView : true)
                        
                        sborkaViewModel.givenHelperId = nil
                        
                    }), secondaryButton: .default(Text(sborkaViewModel.alertInHelperViewButtonText), action: {
                        
                        //Updating the ui and set stuff to nil
                        
                        sborkaViewModel.showSimpleAlertInHelperView = true
                        sborkaViewModel.showHelperListSheet = false
                        sborkaViewModel.updateSegments()
                        
                        sborkaViewModel.selectedByLongPressSegment = nil
                        sborkaViewModel.givenHelperId = nil
                        
                    }))
                    
                }
                
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
                        sborkaViewModel.smotretOtSebya()
                    }
                }))
                
                Menu {
                    Picker(selection: $sborkaViewModel.menuSortIndex, label: Text("Статусы")) {
                        Text("Не обработаны")
                            .tag(0)
                        Text("Нет в наличии")
                            .tag(1)
                        Text("Куплены")
                            .tag(2)
                        Text("Любой")
                            .tag(3)
                    }
                    
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
        .navigationBarTitle(Text(sborkaViewModel.navBarTitle))
        
    }
    
    var mainScreen : some View{
        
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
                        .contentShape(Rectangle())
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
                                
                                sborkaViewModel.pointsInSegmentsView.pointsInSborkaSegmentViewModel.helperID = sborkaViewModel.helperID
                                
                                sborkaViewModel.pointsInSegmentsView.pointsInSborkaSegmentViewModel.key = sborkaViewModel.key
                                
                                sborkaViewModel.pointsInSegmentsView.pointsInSborkaSegmentViewModel.status = sborkaViewModel.status
                                sborkaViewModel.pointsInSegmentsView.pointsInSborkaSegmentViewModel.menuSortIndex = sborkaViewModel.menuSortIndex
                                
                                sborkaViewModel.showPointsView = true
                                
                            }
                            
                        }
                        .onLongPressGesture {
                            
                            sborkaViewModel.selectedByLongPressSegment = item
                            
                            sborkaViewModel.alertTitle = sborkaViewModel.helperID == "" ? "Передать сегмент помощнику?" :  "Забрать сегмент у помощника?"
                            sborkaViewModel.alertMessage = nil
                            sborkaViewModel.showSimpleAlert = false
                            sborkaViewModel.showAlert = true
                            
                        }
                        
                    }
                    
                }
                
            }
            .padding(.top , 16)
            .padding(.horizontal)
            
        }
        
    }
    
    var noItemsView : some View{
        
        VStack{
            
            Text("Нет элементов для отображения")
                .font(.system(size: 19))
                .fontWeight(Font.Weight.semibold)
                .padding(.vertical)
            
            if sborkaViewModel.showNoItemsViewButton{
                
                Button(action:{
                    
                    //Change status to "Любой"
                    sborkaViewModel.menuSortIndex = 3
                    
                }){
                    
                    Text("Отобразить все товары")
                        .bold()
                        .padding(12)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                }
                
            }
            
        }
        .onAppear {
            
            if sborkaViewModel.status != ""{
                sborkaViewModel.noItemsViewText = "Нет элементов для отображения"
                sborkaViewModel.showNoItemsViewButton = true
            }else{
                
                sborkaViewModel.noItemsViewText = "Нет элементов для отображения"
                sborkaViewModel.showNoItemsViewButton = false
                
            }
            
        }
        
    }
    
}
