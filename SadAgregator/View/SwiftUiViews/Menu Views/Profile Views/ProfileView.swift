//
//  MasterNastroekView.swift
//  SadAgregatorSwiftUi
//
//  Created by Sam Yerznkyan on 21.12.2020.
//

import SwiftUI

//MARK: - Profile View

struct ProfileView: View {
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
    @EnvironmentObject var profileViewModel : ProfileViewModel
    
    @EnvironmentObject var masterViewModel : MasterViewModel
    
    var body: some View {
        
        ZStack{
            
            ScrollView {
                
                VStack {
                    
                    VStack{
                        
                        VStack{
                            
                            CellView(labelText: "Имя", buttonText: profileViewModel.name,shouldShowAlert: $profileViewModel.isCustomAlertShown, shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.customAlertTitle)
                            
                            CellView(labelText: "Телефон", buttonText: profileViewModel.phone,shouldShowAlert: $profileViewModel.isCustomAlertShown, shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.customAlertTitle)
                            
                            CellView(labelText: "Email", buttonText: profileViewModel.email,shouldShowImage: false, shouldShowAlert: $profileViewModel.isCustomAlertShown , shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.customAlertTitle)
                            
                            CellView(labelText: "Пароль", buttonText: profileViewModel.password,shouldShowAlert: $profileViewModel.isCustomAlertShown, shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.customAlertTitle)
                            
                            CellView(labelText: "Код партнера", buttonText: profileViewModel.partnerCode, shouldShowImage: false,shouldShowAlert: $profileViewModel.isCustomAlertShown, shouldShowPassAlert: $profileViewModel.isPassAlertShown, alertTitle: $profileViewModel.customAlertTitle)
                            
                        } //Cells
                        
                        if profileViewModel.isVkConnected != nil , profileViewModel.isOkConnected != nil  {
                            
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
                                            
                                            Text(profileViewModel.vkExp)
                                                .foregroundColor(Color(.systemGray))
                                            
                                        }
                                        .font(.system(size: 15))
                                        
                                        HStack{
                                            
                                            Text("выгружено фото")
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Text(profileViewModel.autoVK)
                                                .foregroundColor(Color(.systemGray))
                                            
                                        }
                                        .font(.system(size: 15))
                                        
                                    }
                                    
                                }.padding()
                                
                            }
                            
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
                                                
                                                Text(profileViewModel.okExp)
                                                    .foregroundColor(Color(.systemGray))
                                                
                                            }
                                            .font(.system(size: 15))
                                            
                                            HStack{
                                                
                                                Text("выгружено фото")
                                                    .fontWeight(.semibold)
                                                
                                                Spacer()
                                                
                                                Text(profileViewModel.autoOK)
                                                    .foregroundColor(Color(.systemGray))
                                                
                                            }
                                            .font(.system(size: 15))
                                            
                                        }
                                        
                                    }
                                    
                                }.padding(.horizontal)
                                
                            }
                            
                            if profileViewModel.isOkConnected! || profileViewModel.isVkConnected! {
                                
                                NavigationLink(destination: MasterNastroekView() , isActive: $masterViewModel.shouldShowMasterFromProfile){
                                    
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
                                    
                                }
                                
                                
                                Button(action: {
                                    
                                    profileViewModel.isAlertShown = true
                                    
                                }){
                                    
                                    HStack{
                                        
                                        Image(systemName: "menubar.arrow.up.rectangle")
                                        
                                        Text("ВСЕ НАСТРОЙКИ ПАРСЕРА")
                                            .fontWeight(.semibold)
                                        
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(#colorLiteral(red: 0.9591086507, green: 0.9659582973, blue: 0.9731834531, alpha: 1)))
                                    
                                }
                                
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
                                        
                                        Button(action:{
                                            profileViewModel.addVkVigruzka()
                                        }){
                                            
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
                                            
                                        }
                                        
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
                                        
                                        Button(action:{
                                            profileViewModel.addOkVigruzka()
                                        }){
                                            
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
                                            
                                        }
                                        
                                    }.padding(.horizontal).padding(.bottom , 16)
                                    
                                }
                                
                            }
                            
                            
                            if !profileViewModel.isVkConnected!{
                                
                                Button(action:{
                                    
                                    profileViewModel.addVkVigruzka()
                                    
                                }){
                                    
                                    PodkluchitVkVigruzkuView()
                                    
                                }
                                
                            }
                            
                            if !profileViewModel.isOkConnected!{
                                
                                Button(action:{
                                    
                                    profileViewModel.addOkVigruzka()
                                    
                                }){
                                    
                                    PodkluchitOkVigruzkuView()
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            AlertWithTextFieldView(title: $profileViewModel.customAlertTitle , text: $profileViewModel.customAlertTextFieldText, isShown : $profileViewModel.isCustomAlertShown)
            
            PassAlertWithTextFieldsView(title: .constant("Изменение пароля"), oldPassText: $profileViewModel.oldPassText, newPassText: $profileViewModel.newPassText, confirmPassText: $profileViewModel.confirmPassText, isShown: $profileViewModel.isPassAlertShown)
            
        }
        .alert(isPresented: $profileViewModel.isAlertShown){
            Alert(title: Text(profileViewModel.alertTitle), message: nil, primaryButton: .default(Text("БЫСТРАЯ НАСТРОЙКА")){
                masterViewModel.shouldShowMasterFromProfile = true
            }, secondaryButton: .default(Text("ВСЁ РАВНО ПЕРЕЙТИ В WEB")){
                if let url = URL(string: profileViewModel.settings){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
        }
        
        .onAppear{
            profileViewModel.loadUserData()
            profileViewModel.getProfileData()
        }
        .onDisappear{
            if !masterViewModel.shouldShowMasterFromProfile{
                menuViewModel.updateData()
            }
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
