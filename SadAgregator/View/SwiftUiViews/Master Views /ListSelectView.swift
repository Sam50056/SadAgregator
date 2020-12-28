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
                    
                    TextField("Поиск по списку", text: $text)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.white))
                .cornerRadius(8)
                .shadow(radius: 4)
                
            }
            
            VStack{
                
                ForEach(masterViewModel.items , id: \.id){ item in
                    
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
            .background(Color(.white))
            .cornerRadius(12)
            .shadow(radius: 4)
            
        }
        .padding(.horizontal,16)
        .alert(isPresented: $masterViewModel.shouldShowAlertInListSelect) {
            Alert(title: Text("Обновить альбомы?"), primaryButton: .default(Text("Да")){
                
                masterViewModel.refreshAlbsData()
                
            } , secondaryButton: .cancel(Text("Нет")){
                masterViewModel.shouldShowAlertInListSelect = false
            })
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
