//
//  AlertWithTextFieldView.swift
//  SadAgregatorSwiftUi
//
//  Created by Sam Yerznkyan on 21.12.2020.
//

import SwiftUI

struct AlertWithTextFieldView: View {
    
    @Binding var title : String
    
    @Binding var text : String
    
    @Binding var isShown : Bool
    
    let screenSize = UIScreen.main.bounds
    
    @EnvironmentObject var profileViewModel : ProfileViewModel
    
    var body: some View {
        
        VStack(spacing: 16){
            
            Text(title)
                .foregroundColor(Color("blackwhite"))
            
            TextField(profileViewModel.customAlertTitle == "Имя" ? profileViewModel.name : profileViewModel.phone , text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack{
                
                Button("Отмена"){
                    
                    isShown = false
                    text = ""
                    
                    profileViewModel.hideKeyboard()
                    
                }.foregroundColor(Color("blackwhite"))
                
                Spacer()
                
                Button(action: {
                    
                    profileViewModel.changeUserOption()
                    
                }, label: {
                        
                    Text("Изменить")
                        .padding(.all , 5)
                        .foregroundColor(.white)
                        .background(Color(.systemBlue))
                        .cornerRadius(6)
                    
                })
                
            }.padding(.horizontal , 32)
            
        }.padding()
        .frame(width: screenSize.width * 0.7, height: screenSize.height * 0.25)
        .background(Color("gray"))
        .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
        .offset(y: isShown ? 0 : screenSize.height)
        .animation(.spring())
        .shadow(color: Color("shadow"), radius: 6, x: -9, y: -9)
        
    }
    
    
}

struct PassAlertWithTextFieldsView: View {
    
    @Binding var title : String
    
    @Binding var oldPassText : String
    @Binding var newPassText : String
    @Binding var confirmPassText : String
    
    @Binding var isShown : Bool
    
    let screenSize = UIScreen.main.bounds
    
    @EnvironmentObject var profileViewModel : ProfileViewModel
    
    var body: some View {
        
        VStack(spacing: 16){
            
            Text(title)
                .foregroundColor(Color("blackwhite"))
            
            SecureField("Старый пароль", text: $oldPassText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Новый пароль", text: $newPassText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Подтвердите пароль", text: $confirmPassText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack{
                
                Button("Отмена"){
                    isShown = false
                }.foregroundColor(Color("blackwhite"))
                
                Spacer()
                
                Button(action: {
                    
                    profileViewModel.changePass()
                    
                }, label: {
                        
                    Text("Изменить")
                        .padding(.all , 5)
                        .foregroundColor(.white)
                        .background(Color(.systemBlue))
                        .cornerRadius(6)
                    
                })
                
            }.padding(.horizontal , 32)
            
        }.padding()
        .frame(width: screenSize.width * 0.7, height: screenSize.height * 0.35)
        .background(Color("gray"))
        .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
        .offset(y: isShown ? 0 : screenSize.height)
        .animation(.spring())
        .shadow(color: Color("shadow"), radius: 6, x: -9, y: -9)
        
    }
    
    
}
