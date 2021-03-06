//
//  RegView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.12.2020.
//

import SwiftUI
import SwiftyJSON
import RealmSwift

struct RegView: View {
    
    let realm = try! Realm()
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
    @Binding var shouldShowLogin : Bool
    
    @State var emailText : String = ""
    @State var nameText : String = ""
    @State var passText : String = ""
    @State var phoneText : String = ""
    
    var body: some View {
        
        VStack{
            
            ScrollView{
                
                VStack(alignment: .leading, spacing: 16){
                    
                    Button(action: {
                        menuViewModel.vkAuth()
                    }){
                        HStack(spacing: 16){
                            
                            Image("vk")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .cornerRadius(5)
                            
                            Text("Регистрация через Вконтаке")
                            
                        }
                    }
                    
                    Button(action:{
                        
                        menuViewModel.okAuth()
                        
                    }){
                        
                        HStack(spacing: 13){
                            
                            Image("odno")
                                .resizable()
                                .frame(width: 28, height: 30, alignment: .center)
                            
                            
                            Text("Регистрация через Одноклассники")
                            
                        }
                        
                    }
                    
                    HStack{
                        
                        Spacer()
                        
                        SignInWithApple()
                            .frame(width: 270, height: 45)
                            .onTapGesture(perform: menuViewModel.showAppleLogin)
                        
                        Spacer()
                        
                    }
                    
                }
                .padding()
                
                DividerView(label: "ИЛИ", horizontalPadding: 30)
                
                VStack{
                    
                    HStack{
                        
                        TextField("Email", text: $emailText)
                            .padding(.horizontal , 8)
                            .padding(.vertical, 12)
                            .multilineTextAlignment(.leading)
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray))
                    )
                    .padding(.vertical, 8)
                    
                    HStack{
                        
                        SecureField("Имя", text: $nameText)
                            .padding(.horizontal , 8)
                            .padding(.vertical, 12)
                            .multilineTextAlignment(.leading)
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray))
                    )
                    .padding(.bottom, 8)
                    
                    HStack{
                        
                        TextField("Пароль", text: $passText)
                            .padding(.horizontal , 8)
                            .padding(.vertical, 12)
                            .multilineTextAlignment(.leading)
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray))
                    )
                    .padding(.bottom, 8)
                    
                    HStack{
                        
                        TextField("Телефон (не обязательно)", text: $phoneText)
                            .padding(.horizontal , 8)
                            .padding(.vertical, 12)
                            .multilineTextAlignment(.leading)
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray))
                    )
                    .padding(.bottom, 8)
                    
                    Button(action: {
                        
                        menuViewModel.loadUserData()
                        
                        RegisterDataManager(delegate: self).getRegisterData(key: menuViewModel.key, email: emailText, name: nameText, password: passText, phone: phoneText)
                        
                    }, label: {
                        
                        VStack{
                            
                            Text("РЕГИСТРАЦИЯ")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .background(Color(.systemBlue))
                                .cornerRadius(8)
                        }
                        
                    })
                    
                }.padding(.horizontal, 20)
                
                Spacer()
                
            }
            
            Divider()
            
            HStack{
                
                Text("Уже есть аккаунт?")
                    .foregroundColor(Color(.systemGray))
                
                Button(action: {
                    
                    withAnimation{
                        shouldShowLogin = true
                    }
                    
                }, label: {
                    Text("Войти")
                        .bold()
                })
                
            }
            .font(.system(size: 14))
            .padding(.bottom, 16)
            .padding(.top , 8)
            
        }
        
        .navigationBarTitle("Регистрация", displayMode: .inline)
        
    }
    
}

//MARK: - RegisterDataManagerDelegate

extension RegView : RegisterDataManagerDelegate {
    
    func didGetRegisterData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                menuViewModel.login(newKey:  data["key"].stringValue)
                
            }else{
                
                
                
            }
            
        }
        
    }
    
    func didFailGettingRegisterDataWithError(error: String) {
        print("Error with RegisterDataManager: \(error)")
    }
    
}
