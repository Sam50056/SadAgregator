//
//  PointsInSborkaSegmentView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.07.2021.
//

import SwiftUI

struct PointsInSborkaSegmentView: View {
    
    @ObservedObject var pointsInSborkaSegmentViewModel = PointsInSborkaSegmentViewModel()
    @EnvironmentObject var sborkaViewModel : SborkaViewModel
    
    var body: some View {
        
        ZStack{
            
            if pointsInSborkaSegmentViewModel.items.isEmpty , pointsInSborkaSegmentViewModel.screenData != nil {
                
                noItemsView
                
            }else{
                
                mainScreen
                
            }
            
            NavigationLink(destination:
                            ProdsInPointView(statusChangedFromUIVC: { newStatusIndex in
                self.pointsInSborkaSegmentViewModel.menuSortIndex = newStatusIndex
            }, pointName: pointsInSborkaSegmentViewModel.selectedByTapPoint?.capt
                                             , pointId: pointsInSborkaSegmentViewModel.selectedByTapPoint?.pointId
                                             , helperId: pointsInSborkaSegmentViewModel.helperID, status: pointsInSborkaSegmentViewModel.status)
                            .navigationBarTitle(Text(pointsInSborkaSegmentViewModel.selectedByTapPoint?.capt ?? ""))
                            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    Button(action:{
                        pointsInSborkaSegmentViewModel.getHelpers(inSborka: true)
                    }){
                        Image(systemName : "person")
                    }.contextMenu(ContextMenu(menuItems: {
                        Button("Смотреть от себя"){
                            pointsInSborkaSegmentViewModel.smotretOtSebya()
                        }
                    }))
                    
                    Menu {
                        Picker(selection: $pointsInSborkaSegmentViewModel.menuSortIndex, label: Text("Статусы")) {
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
                           , isActive: $pointsInSborkaSegmentViewModel.showProdsInPointView) {
                EmptyView()
            }
            
        }
        .alert(isPresented: $pointsInSborkaSegmentViewModel.showAlert, content: {
            Alert(title: Text(pointsInSborkaSegmentViewModel.alertTitle), message: pointsInSborkaSegmentViewModel.alertMessage != nil ? Text(pointsInSborkaSegmentViewModel.alertMessage!) : nil, primaryButton: .cancel(Text("Отмена")), secondaryButton: .default(Text(pointsInSborkaSegmentViewModel.alertButtonText), action: {
                
                if pointsInSborkaSegmentViewModel.helperID != "" { //Smotrit ne ot sebya
                    
                    pointsInSborkaSegmentViewModel.takePointFrom(pointsInSborkaSegmentViewModel.helperID)
                    
                }else{//Smotrit ot sebya
                    
                    //Getting the list of helpers for user to choose who is he giving the segment to
                    pointsInSborkaSegmentViewModel.getHelpers()
                    
                }
                
            }))
        })
        .sheet(isPresented: $pointsInSborkaSegmentViewModel.showHelperListSheet, content: {
            
            NavigationView{
                
                VStack{
                    
                    List{
                        
                        ForEach(pointsInSborkaSegmentViewModel.helpers, id: \.id){ helper in
                            
                            HStack{
                                
                                Text(helper.capt)
                                
                                Spacer()
                                
                            }
                            .onTapGesture {
                                
                                if let _ = pointsInSborkaSegmentViewModel.selectedByLongPressPoint{
                                    
                                    pointsInSborkaSegmentViewModel.givePointTo(helper.id)
                                    
                                }else{
                                    
                                    pointsInSborkaSegmentViewModel.helperID = helper.id
                                    pointsInSborkaSegmentViewModel.update()
                                    
                                    pointsInSborkaSegmentViewModel.showHelperListSheet = false
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    Divider()
                    
                    HStack{
                        
                        Spacer()
                        
                        Text(!pointsInSborkaSegmentViewModel.shouldShowSmotretOtSebyaInHelperView ? "" : "Смотреть мою сборку")
                            .font(.system(size: 18))
                        
                        Spacer()
                        
                    }
                    .frame(height: 25)
                    .padding(.bottom , 16)
                    .padding(.top , 8)
                    .onTapGesture{
                        
                        guard pointsInSborkaSegmentViewModel.shouldShowSmotretOtSebyaInHelperView else {return}
                        
                        pointsInSborkaSegmentViewModel.showHelperListSheet = false
                        pointsInSborkaSegmentViewModel.smotretOtSebya()
                    }
                    
                }
                
                .navigationBarTitle("Помощники", displayMode: .inline)
                
            }
            .alert(isPresented: $pointsInSborkaSegmentViewModel.showAlertInHelperView , content : {
                
                Alert(title: Text(pointsInSborkaSegmentViewModel.alertInHelperViewTitle), message: pointsInSborkaSegmentViewModel.alertInHelperViewMessage != nil ? Text(pointsInSborkaSegmentViewModel.alertInHelperViewMessage!) : nil, dismissButton: .default(Text(pointsInSborkaSegmentViewModel.alertInHelperViewButtonText), action: {
                    
                    pointsInSborkaSegmentViewModel.showHelperListSheet = false
                    
                }))
                
            })
            
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                Button(action:{
                    pointsInSborkaSegmentViewModel.getHelpers(inSborka: true)
                }){
                    Image(systemName : "person")
                }.contextMenu(ContextMenu(menuItems: {
                    Button("Смотреть от себя"){
                        pointsInSborkaSegmentViewModel.smotretOtSebya()
                    }
                }))
                
                Menu {
                    Picker(selection: $pointsInSborkaSegmentViewModel.menuSortIndex, label: Text("Статусы")) {
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
            
            pointsInSborkaSegmentViewModel.items.removeAll()
            
            pointsInSborkaSegmentViewModel.update()
            
        }
        .onWillDisappear {
            
            if sborkaViewModel.helperID != pointsInSborkaSegmentViewModel.helperID || sborkaViewModel.status != pointsInSborkaSegmentViewModel.status{
                
                sborkaViewModel.helperID = pointsInSborkaSegmentViewModel.helperID
                sborkaViewModel.status = pointsInSborkaSegmentViewModel.status
                sborkaViewModel.menuSortIndex = pointsInSborkaSegmentViewModel.menuSortIndex
                
                sborkaViewModel.updateSegments()
                
            }
            
        }
        .navigationBarTitle(Text(pointsInSborkaSegmentViewModel.thisSegmentName))
        
    }
    
    var mainScreen : some View{
        
        VStack{
            
            List{
                
                ForEach(pointsInSborkaSegmentViewModel.items , id: \.id){ item in
                    
                    VStack{
                        
                        ZStack{
                            
                            HStack{
                                
                                Text(item.capt)
                                
                                Spacer()
                                
                                Text(item.summ + " руб.")
                                    .foregroundColor(Color(.systemGray))
                                
                            }
                            
                            HStack{
                                
                                Spacer()
                                
                                Text(item.count + " шт.")
                                    .foregroundColor(Color(.systemGray))
                                
                                Spacer()
                                
                            }
                            
                        }
                        
                    }
                    .contentShape(Rectangle())
                    .onTapGesture{
                        
                        pointsInSborkaSegmentViewModel.selectedByTapPoint = item
                        
                        pointsInSborkaSegmentViewModel.showProdsInPoint()
                        
                    }
                    .onLongPressGesture {
                        
                        pointsInSborkaSegmentViewModel.selectedByLongPressPoint = item
                        
                        pointsInSborkaSegmentViewModel.alertTitle = pointsInSborkaSegmentViewModel.helperID == "" ? "Передать точку помощнику?" :  "Забрать точку у помощника?"
                        pointsInSborkaSegmentViewModel.alertMessage = nil
                        pointsInSborkaSegmentViewModel.showAlert = true
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    var noItemsView : some View{
        
        VStack{
            
            Text("Нет элементов для отображения")
                .font(.system(size: 19))
                .fontWeight(Font.Weight.semibold)
                .padding(.vertical)
            
            if pointsInSborkaSegmentViewModel.showNoItemsViewButton{
                
                Button(action:{
                    
                    //Change status to "Любой"
                    pointsInSborkaSegmentViewModel.menuSortIndex = 3
                    
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
            
            if pointsInSborkaSegmentViewModel.status != ""{
                pointsInSborkaSegmentViewModel.noItemsViewText = "Нет элементов для отображения"
                pointsInSborkaSegmentViewModel.showNoItemsViewButton = true
            }else{
                pointsInSborkaSegmentViewModel.noItemsViewText = "Нет элементов для отображения"
                pointsInSborkaSegmentViewModel.showNoItemsViewButton = false
            }
            
        }
        
    }
    
}

struct PointsInSborkaSegmentView_Previews: PreviewProvider {
    static var previews: some View {
        PointsInSborkaSegmentView()
    }
}
