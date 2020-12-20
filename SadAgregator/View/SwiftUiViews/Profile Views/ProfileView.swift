//
//  MasterNastroekView.swift
//  SadAgregatorSwiftUi
//
//  Created by Sam Yerznkyan on 21.12.2020.
//

import SwiftUI

struct ProfileView: View {
    
    @State var alertTitle = ""
    @State var isAlertShown = false
    @State var alertTextFieldText = ""
    
    var body: some View {
        
        ZStack{
            
            ScrollView {
                
                VStack {
                    
                    VStack{
                        
                        VStack{
                            
                            CellView(labelText: "Имя", buttonText: "Максим",shouldShowAlert: $isAlertShown, alertTitle: $alertTitle)
                            
                            CellView(labelText: "Телефон", buttonText: "79090001122",shouldShowAlert: $isAlertShown, alertTitle: $alertTitle)
                            
                            CellView(labelText: "Email", buttonText: "mapmarket2007@yandex.ru", shouldShowImage: false,shouldShowAlert: $isAlertShown, alertTitle: $alertTitle)
                            
                            CellView(labelText: "Пароль", buttonText: "*********",shouldShowAlert: $isAlertShown, alertTitle: $alertTitle)
                            
                            CellView(labelText: "Код партнера", buttonText: "898917", shouldShowImage: false,shouldShowAlert: $isAlertShown, alertTitle: $alertTitle)
                            
                        }
                        
                        VStack{
                            
                            HStack{
                                
                                Image("vk-2")
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .center)
                                
                                Text("Подключить выгрузку")
                                    .font(.system(size: 18))
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(Color(.systemBlue))
                            .background(Color(.white))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemBlue))
                            )
                            
                            Text("Подключите ваш аккаунт ВКонтакте для публикации товаров поставщиков на своей стене")
                                .font(.caption)
                                .foregroundColor(Color(.systemGray))
                            
                            
                        }.padding() //Vk
                        
                        VStack{
                            
                            HStack{
                                
                                Image("odno")
                                    .resizable()
                                    .frame(width: 32, height: 35, alignment: .center)
                                
                                Text("Подключить выгрузку")
                                    .font(.system(size: 18))
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(Color(.systemOrange))
                            .background(Color(.white))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemOrange))
                            )
                            
                            Text("Подключите ваш аккаунт Одноклассников для публикации товаров поставщиков на своей стене")
                                .font(.caption)
                                .foregroundColor(Color(.systemGray))
                            
                            
                        }.padding(.horizontal)//Odno
                        
                    }
                    
                }
                
                
            }
            
            AlertWithTextFieldView(title: $alertTitle , text: $alertTextFieldText, isShown : $isAlertShown)
            
        }
        
        .navigationBarTitle("Профиль", displayMode: .inline)
        
    }
    
}

struct MasterNastroekView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct CellView: View {
    
    var labelText : String
    
    var buttonText : String
    
    var shouldShowImage : Bool = true
    
    @Binding var shouldShowAlert : Bool
    
    @Binding var alertTitle : String
    
    var body: some View {
        
        HStack{
            
            Text(labelText)
                .fontWeight(.semibold)
            
            Spacer()
            
            HStack{
                
                Button(action: {
                    
                    if !shouldShowImage {return}
                    
                    alertTitle = labelText
                    
                    shouldShowAlert = true
                    
                }, label: {
                    
                    Text(buttonText)
                    
                    shouldShowImage ? Image(systemName: "pencil") : nil
                    
                })
                
            }
            .foregroundColor(Color(.systemGray))
            
        }
        .padding()
    }
}
