//
//  RegView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.12.2020.
//

import SwiftUI

struct RegView: View {
    
    @Binding var isPresented : Bool
    
    @Binding var shouldShowLogin : Bool
    
    @State var emailText : String = ""
    
    var body: some View {
        
        VStack{
            
            ScrollView{
                
                VStack(alignment: .leading, spacing: 16){
                    
                    HStack(spacing: 16){
                        
                        Image("vk")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .cornerRadius(5)
                        
                        Text("Регистрация через Вконтаке")
                        
                    }
                    
                    HStack(spacing: 13){
                        
                        Image("odno")
                            .resizable()
                            .frame(width: 28, height: 30, alignment: .center)
                        
                        
                        Text("Регистрация через Одноклассники")
                        
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
                        
                        TextField("Имя", text: $emailText)
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
                        
                        TextField("Пароль", text: $emailText)
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
                        
                        TextField("Телефон (не обязательно)", text: $emailText)
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
                        
                        isPresented = false
                        
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
                
            }
            
            Spacer()
            
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
