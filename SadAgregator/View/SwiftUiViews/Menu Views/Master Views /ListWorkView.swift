//
//  ListWorkView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.12.2020.
//

import SwiftUI

struct ListWorkView: View {
    
    @EnvironmentObject var masterViewModel : MasterViewModel
    
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
                
                Button(action: {
                    
                    
                    
                }){
                    
                    HStack{
                        
                        Text(masterViewModel.currentViewData!["capt_list_ext_button"].stringValue)
                            .foregroundColor(Color(.systemBlue))
                        
                        Text(masterViewModel.currentViewData!["ext_list_cnt"].stringValue)
                            .padding(.all , 8)
                            .font(.system(size: 14))
                            .foregroundColor(Color(.white))
                            .background(Circle().foregroundColor(Color(.systemBlue)))
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    
                }
                
                Text(masterViewModel.currentViewData!["capt_list_name"].stringValue)
                    .font(.system(size: 19))
                    .bold()
                
                HStack{
                    
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(Color(.systemGray))
                    
                    TextField(masterViewModel.currentViewData!["edt_place_holder"].stringValue, text: $masterViewModel.listWorkSearchTextFieldText)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.white))
                .cornerRadius(8)
                .shadow(radius: 4)
                
            }
            
            if !masterViewModel.list.isEmpty{
                
                VStack{
                    
                    ForEach(masterViewModel.list , id: \.id){ item in
                        
                        VStack{
                            
                            HStack{
                                
                                VStack(alignment: .leading, spacing: 8){
                                    
                                    Text(item.capt)
                                    
                                    if item.subCapt != ""{
                                        Text(item.subCapt)
                                            .foregroundColor(Color(.systemGray))
                                    }
                                    
                                }
                                .font(.system(size: 16))
                                
                                Spacer()
                                
                                if item.act != ""{
                                    
                                    Button(action: {
                                        
                                    }){
                                        Text(item.act)
                                            .foregroundColor(Color(.systemBlue))
                                    }
                                }
                                
                            }
                            
                            Divider()
                            
                        }
                        .onTapGesture {
                            
                        }
                        
                    }
                    
                }
                .padding()
                .background(Color(.white))
                .cornerRadius(12)
                .shadow(radius: 4)
                
            }
            
        }
        .padding(.horizontal,16)
        .onDisappear{
            masterViewModel.listWorkSearchTextFieldText = ""
        }
        
    }
    
}

struct ListWorkItem : Identifiable{
    
    let id : Int
    let capt : String
    let subCapt : String
    let act : String
    let ext : Int
    
}
