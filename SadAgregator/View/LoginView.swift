//
//  LoginView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.12.2020.
//

import SwiftUI

struct LoginView: View {
    
    @Binding var isPresented : Bool
    
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
                        
                        Text("Войти через Вконтаке")
                        
                    }
                    
                    HStack(spacing: 13){
                        
                        Image("odno")
                            .resizable()
                            .frame(width: 28, height: 30, alignment: .center)
                            
                        
                        Text("Войти через Одноклассники")
                        
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
                    
                    Button(action: {
                        
                        isPresented = false
                        
                    }, label: {
                        
                        VStack{
                            
                            Text("ВОЙТИ")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .background(Color(.systemBlue))
                                .cornerRadius(8)
                        }
                        
                    })
                    
                    Text("Забыли пароль для входа в систему?")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.systemGray))
                    
                    Button(action: {
                        
                    }, label: {
                        Text("Восстановить пароль")
                            .foregroundColor(Color(.systemBlue))
                            .font(.system(size: 14))
                            .bold()
                    })
                    
                }.padding(.horizontal, 20)
                
            }
            
            Spacer()
            
            Divider()
            
            HStack{
                
                Text("Нет аккаунта?")
                    .foregroundColor(Color(.systemGray))
                
                Button(action: {
                    
                }, label: {
                    Text("Зарегистрироваться")
                        .bold()
                })
                
            }
            .font(.system(size: 14))
            .padding(.bottom, 16)
            .padding(.top , 8)
            
        }
        
        .navigationBarTitle("Авторизация", displayMode: .inline)
        
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isPresented: .constant(false))
    }
}

struct DividerView: View {
    
    let label: String
    let horizontalPadding: CGFloat
    let color: Color
    
    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .gray) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }
    
    var body: some View {
        HStack {
            line
            Text(label).foregroundColor(color)
            line
        }
    }
    
    var line: some View {
        VStack { Divider().background(color) }.padding(.horizontal,horizontalPadding)
    }
}
