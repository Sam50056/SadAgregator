//
//  MasterNastroekView.swift
//  SadAgregatorSwiftUi
//
//  Created by Sam Yerznkyan on 21.12.2020.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        
        ZStack{
            
            ScrollView {
                
                VStack {
                    
                    VStack{
                        
                        VStack{
                            
                            CellView(labelText: "Имя", buttonText: "Максим",shouldShowAlert: $profileViewModel.isAlertShown, alertTitle: $profileViewModel.alertTitle)
                            
                            CellView(labelText: "Телефон", buttonText: "79090001122",shouldShowAlert: $profileViewModel.isAlertShown, alertTitle: $profileViewModel.alertTitle)
                            
                            CellView(labelText: "Email", buttonText: "mapmarket2007@yandex.ru",shouldShowImage: false, shouldShowAlert: $profileViewModel.isAlertShown , alertTitle: $profileViewModel.alertTitle)
                            
                            CellView(labelText: "Пароль", buttonText: "*********",shouldShowAlert: $profileViewModel.isAlertShown, alertTitle: $profileViewModel.alertTitle)
                            
                            CellView(labelText: "Код партнера", buttonText: "898917", shouldShowImage: false,shouldShowAlert: $profileViewModel.isAlertShown, alertTitle: $profileViewModel.alertTitle)
                            
                        } //Cells
                        
                        if !profileViewModel.isVkConnected{
                            
                            VStack{
                                
                                HStack{
                                    
                                    Image("vk-2")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                    
                                    Text("Подключить выгрузку")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(#colorLiteral(red: 0.3157836497, green: 0.5058068037, blue: 0.7203877568, alpha: 1)))
                                    
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(Color(.systemBlue))
                                .background(Color(.white))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(#colorLiteral(red: 0.3157836497, green: 0.5058068037, blue: 0.7203877568, alpha: 1)))
                                )
                                
                                Text("Подключите ваш аккаунт ВКонтакте для публикации товаров поставщиков на своей стене")
                                    .font(.caption)
                                    .foregroundColor(Color(.systemGray))
                                
                                
                            }.padding()
                            
                        }else {
                            
                            HStack(alignment: .top){
                                
                                Image("vk")
                                    .resizable()
                                    .cornerRadius(5)
                                    .frame(width: 25 , height: 25, alignment: .center)
                                
                                VStack(alignment: .leading, spacing: 8){
                                    
                                    Text("ВКонтакте")
                                        .foregroundColor(Color(#colorLiteral(red: 0.3157836497, green: 0.5058068037, blue: 0.7203877568, alpha: 1)))
                                    
                                    HStack{
                                        
                                        Text("дней осталось")
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        Text("114 дн.")
                                            .foregroundColor(Color(.systemGray))
                                        
                                    }
                                    .font(.system(size: 15))
                                    
                                    HStack{
                                        
                                        Text("выгружено фото")
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        Text("112")
                                            .foregroundColor(Color(.systemGray))
                                        
                                    }
                                    .font(.system(size: 15))
                                    
                                }
                                
                            }.padding()
                            
                        }
                        
                        if !profileViewModel.isOkConnected{
                            
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
                                
                                
                            }.padding(.horizontal)
                            
                        }else {
                            
                            HStack(alignment: .top){
                                
                                Image("odno")
                                    .resizable()
                                    .cornerRadius(5)
                                    .frame(width: 25 , height: 27, alignment: .center)
                                
                                VStack(alignment: .leading, spacing : 8){
                                    
                                    Text("Одноклассники")
                                        .foregroundColor(Color(.systemOrange))
                                    
                                    VStack(alignment: .leading, spacing: 8){
                                        
                                        HStack{
                                            
                                            Text("дней осталось")
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Text("114 дн.")
                                                .foregroundColor(Color(.systemGray))
                                            
                                        }
                                        .font(.system(size: 15))
                                        
                                        HStack{
                                            
                                            Text("выгружено фото")
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Text("112")
                                                .foregroundColor(Color(.systemGray))
                                            
                                        }
                                        .font(.system(size: 15))
                                        
                                    }
                                    
                                }
                                
                            }.padding(.horizontal)
                            
                        }
                        
                        HStack{
                            
                            Image(systemName: "puzzlepiece.fill")
                            
                            Text("БЫСТРАЯ НАСТРОЙКА ПАРСЕРА")
                                .fontWeight(.semibold)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(Color(.systemBlue))
                        .background(Color(#colorLiteral(red: 0.9591086507, green: 0.9659582973, blue: 0.9731834531, alpha: 1)))
                        
                        
                        HStack{
                            
                            Image(systemName: "menubar.arrow.up.rectangle")
                            
                            Text("БЫСТРАЯ НАСТРОЙКА ПАРСЕРА")
                                .fontWeight(.semibold)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(#colorLiteral(red: 0.9591086507, green: 0.9659582973, blue: 0.9731834531, alpha: 1)))
                        
                        VStack{
                            
                            HStack{
                                
                                Image("vk")
                                    .resizable()
                                    .frame(width: 40, height: 40, alignment: .center)
                                
                                Text("Выгрузка подключена")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.white)
                                    .fontWeight(.semibold)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical , 8)
                            .foregroundColor(Color(.systemBlue))
                            .background(Color(#colorLiteral(red: 0.3157836497, green: 0.5058068037, blue: 0.7203877568, alpha: 1)))
                            .cornerRadius(8)
                            
                            Text("Выгрузка подключена , теперь вы сможете выгружать товары к себе на страницу")
                                .font(.caption)
                                .foregroundColor(Color(.systemGray))
                            
                            HStack{
                                
                                Text("Переподключить аккаунт VK.COM")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.gray)
                                    .fontWeight(.semibold)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical , 14)
                            .foregroundColor(Color(.systemBlue))
                            .background(Color(#colorLiteral(red: 0.9622963071, green: 0.9662981629, blue: 0.9730395675, alpha: 1)))
                            .cornerRadius(8)
                            
                        }.padding()
                        
                        VStack{
                            
                            HStack{
                                
                                Image("odno")
                                    .resizable()
                                    .frame(width: 40, height: 40, alignment: .center)
                                
                                Text("Выгрузка подключена")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.white)
                                    .fontWeight(.semibold)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical , 8)
                            .foregroundColor(Color(.systemBlue))
                            .background(Color(#colorLiteral(red: 0.9986427426, green: 0.5983409286, blue: 0, alpha: 1)))
                            .cornerRadius(8)
                            
                            Text("Выгрузка подключена , теперь вы сможете выгружать товары к себе на страницу")
                                .font(.caption)
                                .foregroundColor(Color(.systemGray))
                            
                            HStack{
                                
                                Text("Переподключить аккаунт OK.RU")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.gray)
                                    .fontWeight(.semibold)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical , 14)
                            .foregroundColor(Color(.systemBlue))
                            .background(Color(#colorLiteral(red: 0.9622963071, green: 0.9662981629, blue: 0.9730395675, alpha: 1)))
                            .cornerRadius(8)
                            
                        }.padding(.horizontal).padding(.bottom , 16)
                        
                    }
                    
                }
                
                
            }
            
            AlertWithTextFieldView(title: $profileViewModel.alertTitle , text: $profileViewModel.alertTextFieldText, isShown : $profileViewModel.isAlertShown)
            
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
