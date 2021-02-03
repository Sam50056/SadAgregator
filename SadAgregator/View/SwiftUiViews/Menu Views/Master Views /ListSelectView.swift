//
//  ListSelectView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI

struct ListSelectView: View {
    
    @EnvironmentObject var masterViewModel : MasterViewModel
    
    @State var text : String = ""
    
    var body: some View {
        
        ZStack{
            
            VStack(alignment: .leading, spacing: 16){
                
                VStack(alignment: .leading,spacing: 16){
                    
                    Text(masterViewModel.currentViewData!["capt"].stringValue)
                        .font(.system(size: 21))
                        .bold()
                    
                    if masterViewModel.currentViewData!["hint"].stringValue != "" {
                        
                        Text(masterViewModel.currentViewData!["hint"].stringValue)
                            .foregroundColor(Color(.systemGray))
                            .font(.system(size: 17))
                        
                    }
                    
                    if masterViewModel.currentViewData!["refresh_albs"].intValue == 1{
                        
                        Button(action: {
                            
                            masterViewModel.shouldShowAlbomAlertInListSelect = true
                            masterViewModel.shouldShowAlertInListSelect = true //Showing the alert
                            
                        }){
                            Text("Обновить список альбомов")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBlue))
                                .foregroundColor(Color.white)
                                .cornerRadius(8)
                        }
                        
                        
                    }
                    
                    HStack{
                        
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                            .foregroundColor(Color("searchbargray"))
                        
                        TextField("Поиск по списку", text: $masterViewModel.listSelectTextFieldText)
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("whiteblack"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("searchbargray"))
                    )
                    
                }
                
                if !masterViewModel.filteredItems.isEmpty {
                    
                    VStack{
                        
                        ForEach(masterViewModel.filteredItems , id: \.id){ item in
                            
                            VStack{
                                
                                HStack{
                                    
                                    VStack(alignment: .leading, spacing: 8){
                                        
                                        Text(item.capt)
                                            .foregroundColor(Color("blackwhite"))
                                        
                                        if item.hint != ""{
                                            Text(item.hint)
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        
                                    }
                                    .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    if item.button != ""{
                                        Text(item.button)
                                            .foregroundColor(Color(.systemBlue))
                                    }
                                    
                                }
                                
                                Divider()
                                
                            }
                            .background(item.rec == 1 ? Color("highlited") : Color("whiteblack"))
                            .onTapGesture {
                                masterViewModel.selectListSelectViewAnswer(id: item.id)
                            }
                            
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("whiteblack"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("searchbargray"))
                    )
                    
                }
                
            }
            .padding(.horizontal,16)
            .alert(isPresented: $masterViewModel.shouldShowAlertInListSelect) {
                
                if masterViewModel.shouldShowAlbomAlertInListSelect{
                    
                    return Alert(title: Text("Обновить альбомы?"), primaryButton: .default(Text("Да")){
                        
                        masterViewModel.refreshAlbsData()
                        
                    } , secondaryButton: .default(Text("Нет")){
                        masterViewModel.shouldShowAlertInListSelect = false
                    })
                    
                }else {
                    
                    return Alert(title: Text(masterViewModel.simpleAlerttextInListSelect), dismissButton: .default(Text("Ок")){
                        masterViewModel.shouldShowAlertInListSelect = false
                    })
                    
                }
                
            }
            
            ActivityIndicatorView(isAnimating : $masterViewModel.shouldShowAnimationInListSelect, style: .large)
                .frame(width: 50, height: 50, alignment: .center)
            
        }
        .onDisappear{
            masterViewModel.listSelectTextFieldText = "" 
        }
        
    }
    
}

struct ListSelectItem : Identifiable{
    
    let id : Int
    let capt : String
    let hint : String
    let button : String
    let rec : Int
    
}
