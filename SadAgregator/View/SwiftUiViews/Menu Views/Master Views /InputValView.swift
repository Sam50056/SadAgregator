//
//  InputValView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI

struct InputValView: View {
    
    @EnvironmentObject var masterViewModel : MasterViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16){
            
            Text(masterViewModel.currentViewData!["capt"].stringValue)
                .font(.system(size: 21))
                .bold()
            
            if masterViewModel.currentViewData!["hint"].stringValue != "" {
                
                Text(masterViewModel.currentViewData!["hint"].stringValue)
                    .foregroundColor(Color(.systemGray))
                    .font(.system(size: 17))
                
            }
            
            HStack{
                
                if masterViewModel.currentViewData!["input_val"]["can_edit"].intValue == 1{
                    
                    TextField(masterViewModel.currentViewData!["input_val"]["place_holder"].stringValue, text: $masterViewModel.inputValTextFieldText)
                    
                }else {
                    
                    Text(masterViewModel.currentViewData!["input_val"]["def_val"].stringValue)
                    
                    Spacer()
                    
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.white))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(#colorLiteral(red: 0.8500244617, green: 0.8551172614, blue: 0.854884088, alpha: 1)))
            )
            
            HStack{
                
                if masterViewModel.currentViewData!["buttons"]["left"].exists(){
                    
                    Button(action: {
                        
                        masterViewModel.selectInputValViewButton(id: masterViewModel.currentViewData!["buttons"]["left"]["id"].intValue)
                        
                    }){
                        
                        Text(masterViewModel.currentViewData!["buttons"]["left"]["capt"].stringValue)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBlue))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                    }
                    
                }
                
                if masterViewModel.currentViewData!["buttons"]["right"].exists(){
                    
                    Button(action:{
                        
                        masterViewModel.selectInputValViewButton(id: masterViewModel.currentViewData!["buttons"]["right"]["id"].intValue)
                        
                    }){
                        
                        Text(masterViewModel.currentViewData!["buttons"]["right"]["capt"].stringValue)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBlue))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                    }
                    
                }
                
            }
            
        }
        .padding(.horizontal,16)
        
    }
    
}
