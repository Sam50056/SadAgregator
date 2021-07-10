//
//  PointsInSborkaSegmentView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.07.2021.
//

import SwiftUI

struct PointsInSborkaSegmentView: View {
    
    @ObservedObject var pointsInSborkaSegmentViewModel = PointsInSborkaSegmentViewModel()
    
    var body: some View {
        
        ZStack{
            
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
                        
                    }
                    
                    .navigationBarTitle("Помощники", displayMode: .inline)
                    
                }
                
            })
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    Button(action:{
                        pointsInSborkaSegmentViewModel.getHelpers(inSborka: true)
                    }){
                        Image(systemName : "person")
                    }.contextMenu(ContextMenu(menuItems: {
                        Button("Смотреть от себя"){
                            pointsInSborkaSegmentViewModel.helperID = ""
                            pointsInSborkaSegmentViewModel.update()
                        }
                    }))
                    
                    Menu {
                        Button("Не обработаны", action: {
                            pointsInSborkaSegmentViewModel.changeStatus(to: "0")
                        })
                        Button("Нет в наличии", action: {
                            pointsInSborkaSegmentViewModel.changeStatus(to: "1")
                        })
                        Button("Куплены", action: {
                            pointsInSborkaSegmentViewModel.changeStatus(to: "2")
                        })
                        Button("Любой", action: {
                            pointsInSborkaSegmentViewModel.changeStatus(to: "")
                        })
                    } label: {
                        Image(systemName : "slider.vertical.3")
                            .imageScale(.large)
                    }
                }
            }
            .onAppear{
                
                guard pointsInSborkaSegmentViewModel.items.isEmpty else {return}
                
                pointsInSborkaSegmentViewModel.update()
                
            }
            
            NavigationLink(destination: pointsInSborkaSegmentViewModel.prodsInPointView, isActive: $pointsInSborkaSegmentViewModel.showProdsInPointView) {
                EmptyView()
            }
            
        }
        
    }
    
}

struct PointsInSborkaSegmentView_Previews: PreviewProvider {
    static var previews: some View {
        PointsInSborkaSegmentView()
    }
}
