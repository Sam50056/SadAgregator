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
                            .foregroundColor(Color(.systemGray))
                        
                        TextField("Поиск по списку", text: $masterViewModel.listSelectTextFieldText)
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(#colorLiteral(red: 0.8500244617, green: 0.8551172614, blue: 0.854884088, alpha: 1)))
                    )
                    
                }
                
                if !masterViewModel.filteredItems.isEmpty {
                    
                    VStack{
                        
                        ForEach(masterViewModel.filteredItems , id: \.id){ item in
                            
                            VStack{
                                
                                HStack{
                                    
                                    VStack(alignment: .leading, spacing: 8){
                                        
                                        Text(item.capt)
                                        
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
                            .background(item.rec == 1 ? Color(#colorLiteral(red: 0.9177419543, green: 0.9516320825, blue: 0.9884006381, alpha: 1)) : Color.white)
                            .onTapGesture {
                                masterViewModel.selectListSelectViewAnswer(id: item.id)
                            }
                            
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(#colorLiteral(red: 0.8500244617, green: 0.8551172614, blue: 0.854884088, alpha: 1)))
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
        .onAppear{
            masterViewModel.filteredItems = masterViewModel.items
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
