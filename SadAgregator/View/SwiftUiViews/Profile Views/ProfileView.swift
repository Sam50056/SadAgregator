//
//  MasterNastroekView.swift
//  SadAgregatorSwiftUi
//
//  Created by Sam Yerznkyan on 21.12.2020.
//

import SwiftUI

//MARK: - Profile View

struct ProfileView: View {
    
    @ObservedObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        
        ZStack{
            
            ScrollView {
                
                VStack {
                    
                    VStack{
                        
                        VStack{
                            
                            CellView(labelText: "Имя", buttonText: profileViewModel.name,shouldShowAlert: $profileViewModel.isAlertShown, shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.alertTitle)
                            
                            CellView(labelText: "Телефон", buttonText: profileViewModel.phone,shouldShowAlert: $profileViewModel.isAlertShown, shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.alertTitle)
                            
                            CellView(labelText: "Email", buttonText: profileViewModel.email,shouldShowImage: false, shouldShowAlert: $profileViewModel.isAlertShown , shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.alertTitle)
                            
                            CellView(labelText: "Пароль", buttonText: profileViewModel.password,shouldShowAlert: $profileViewModel.isAlertShown, shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.alertTitle)
                            
                            CellView(labelText: "Код партнера", buttonText: profileViewModel.partnerCode, shouldShowImage: false,shouldShowAlert: $profileViewModel.isAlertShown, shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.alertTitle)
                            
                        } //Cells
                        
                        if profileViewModel.isVkConnected != nil , profileViewModel.isOkConnected != nil  {
                            
                            if profileViewModel.isOkConnected! {
                                
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
                            
                            if profileViewModel.isVkConnected!{
                                
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
                            
                            
                            if profileViewModel.isOkConnected! || profileViewModel.isVkConnected! {
                                
                                HStack{
                                    
                                    Image(systemName: "puzzlepiece.fill")
                                    
                                    Text("БЫСТРАЯ НАСТРОЙКА ПАРСЕРА")
                                        .fontWeight(.semibold)
                                    
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color(.systemBlue))
                                .background(Color(#colorLiteral(red: 0.9591086507, green: 0.9659582973, blue: 0.9731834531, alpha: 1)))
                                .padding(.top , 8)
                                
                                
                                HStack{
                                    
                                    Image(systemName: "menubar.arrow.up.rectangle")
                                    
                                    Text("ВСЕ НАСТРОЙКИ ПАРСЕРА")
                                        .fontWeight(.semibold)
                                    
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(#colorLiteral(red: 0.9591086507, green: 0.9659582973, blue: 0.9731834531, alpha: 1)))
                                
                                if profileViewModel.isVkConnected!{
                                    
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
                                    
                                }
                                
                                if profileViewModel.isOkConnected!{
                                    
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
                            
                            
                            if !profileViewModel.isVkConnected!{
                                
                                PodkluchitVkVigruzkuView()
                                
                            }
                            
                            if !profileViewModel.isOkConnected!{
                                
                                PodkluchitOkVigruzkuView()
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            AlertWithTextFieldView(title: $profileViewModel.alertTitle , text: $profileViewModel.alertTextFieldText, isShown : $profileViewModel.isAlertShown)
            
            PassAlertWithTextFieldsView(title: .constant("Изменение пароля"), oldPassText: $profileViewModel.oldPassText, newPassText: $profileViewModel.newPassText, confirmPassText: $profileViewModel.confirmPassText, isShown: $profileViewModel.isPassAlertShown)
            
        }
        
        .onAppear{
            profileViewModel.getProfileData()
        }
        
        .environmentObject(profileViewModel)
        
        .navigationBarTitle("Профиль", displayMode: .inline)
        
    }
    
}

//MARK: - CellView

struct CellView: View {
    
    var labelText : String
    
    var buttonText : String
    
    var shouldShowImage : Bool = true
    
    @Binding var shouldShowAlert : Bool
    
    @Binding var shouldShowPassAlert : Bool
    
    @Binding var alertTitle : String
    
    var body: some View {
        
        HStack{
            
            Text(labelText)
                .fontWeight(.semibold)
            
            Spacer()
            
            HStack{
                
                Button(action: {
                    
                    shouldShowAlert = false
                    shouldShowPassAlert = false
                    
                    if !shouldShowImage {return}
                    
                    alertTitle = labelText
                    
                    if alertTitle == "Пароль"{
                        
                        shouldShowPassAlert = true
                        
                    }else {
                        
                        shouldShowAlert = true
                        
                    }
                    
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

//MARK: - PodkluchitVkVigruzkuView

struct PodkluchitVkVigruzkuView : View{
    
    var body: some View{
        
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
        
    }
    
}

//MARK: - PodkluchitOkVigruzkuView

struct PodkluchitOkVigruzkuView : View{
    
    var body: some View{
        
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
        .padding(.bottom , 8)
        
    }
    
}
