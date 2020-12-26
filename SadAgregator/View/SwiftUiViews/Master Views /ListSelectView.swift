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
        
        GeometryReader { geometry in
            
            ScrollView{
                
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
                                        Text("Connected")
                                            .foregroundColor(Color(.systemBlue))
                                    }
                                    
                                }
                                
                                Divider()
                                
                            }
                            .onTapGesture {
                                print("Selected item: \(item)")
                            }
                            
                        }
                        
                    }
                    .padding()
                    
                }
                .padding(.horizontal,16)
                .frame(width: geometry.size.width) // Make the scroll view full-width
                .frame(minHeight: geometry.size.height) // Set the content’s min height to the parent
                
            }
        }
        
    }
    
}

struct ListSelectItem : Identifiable{
    
    let id : Int
    let capt : String
    let hint : String
    let button : String = ""
    
}
