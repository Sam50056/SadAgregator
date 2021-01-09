//
//  MenuView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.12.2020.
//

import SwiftUI
import UIKit
import RealmSwift

struct MenuView: View {
    
    @ObservedObject var menuViewModel = MenuViewModel()
    
    @ObservedObject var masterViewModel = MasterViewModel()
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                
                if !menuViewModel.isLogged{
                    
                    Form{
                        
                        Section{
                            
                            Text("Добро пожаловать!")
                                .font(.title)
                                .fontWeight(.semibold)
                                .padding(.all, 5)
                            
                        } //Welcome
                        
                        Section{
                            
                            List{
                                
                                NavigationLink(destination: AuthView(showLogin: true), isActive: $menuViewModel.showModalLogIn){
                                    
                                    HStack(spacing: 23){
                                        
                                        Image(systemName: "arrow.forward.square")
                                            .resizable()
                                            .frame(width: 23, height: 20, alignment: .center)
                                            .foregroundColor(Color(.systemBlue))
                                        
                                        Text("Войти в аккаунт TK-SAD")
                                            .font(.custom("", size: 16))
                                        
                                    }
                                    .padding(.vertical, 5)
                                    
                                }
                                
                                NavigationLink(destination: AuthView(showLogin: false), isActive: $menuViewModel.showModalReg) {
                                    HStack(spacing: 16){
                                        
                                        Image(systemName: "person.2.fill")
                                            .resizable()
                                            .frame(width: 30, height: 20, alignment: .center)
                                            .foregroundColor(Color(.systemBlue))
                                        
                                        Text("Зарегистрироваться")
                                            .font(.custom("", size: 16))
                                        
                                    }
                                    .padding(.vertical, 5)
                                    
                                }
                                
                                
                            }
                            
                        } //Log in / reg stuff
                        
                        Section{
                            
                            HStack(spacing: 21){
                                
                                Image(systemName: "menubar.arrow.up.rectangle")
                                    .resizable()
                                    .frame(width: 25, height: 20, alignment: .center)
                                    .foregroundColor(Color(.systemGray))
                                
                                Text("Парсер")
                                    .font(.custom("", size: 16))
                                    .foregroundColor(Color(.systemGray))
                                
                            }
                            .padding(.vertical, 5)
                            
                        } //Parser
                        
                        Section{
                            
                            List{
                                
                                NavigationLink(destination: SendQuestionView(), isActive : $menuViewModel.showSendQuestionView){
                                    
                                    HStack(spacing: 20){
                                        
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .resizable()
                                            .frame(width: 26, height: 20, alignment: .center)
                                            .foregroundColor(Color(.systemBlue))
                                        
                                        Text("Задать вопрос")
                                            .font(.custom("", size: 16))
                                        
                                    }
                                    .padding(.vertical, 5)
                                    
                                }
                                
                                
                                HStack(spacing: 24){
                                    
                                    Image(systemName: "questionmark.circle.fill")
                                        .resizable()
                                        .frame(width: 22, height: 20, alignment: .center)
                                        .foregroundColor(Color(.systemBlue))
                                    
                                    Text("Помощь")
                                        .font(.custom("", size: 16))
                                    
                                }
                                .padding(.vertical, 5)
                                
                            }
                            
                        } // Help
                        
                    }
                    
                }else {
                    
                    Form{
                        
                        Section{
                            
                            NavigationLink(destination: ProfileView(), isActive: $menuViewModel.showProfile){
                                
                                VStack(alignment: .leading){
                                    
                                    Text(menuViewModel.name)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .padding([.top,.horizontal], 5)
                                        .padding(.bottom, 2)
                                    
                                    HStack{
                                        
                                        Text("Перейти в настройки")
                                            .font(.system(size: 15))
                                        
                                        Spacer()
                                        
                                        Text(menuViewModel.code)
                                            .font(.system(size: 15))
                                        
                                    }
                                    .padding([.bottom, .horizontal], 5)
                                    .foregroundColor(Color(.systemGray))
                                    
                                }
                                
                            }
                            
                        } //Top Section
                        
                        Section{
                            
                            List{
                                
                                NavigationLink(destination: FavoriteVendsView(), isActive: $menuViewModel.showFavoriteVends){
                                    
                                    HStack(spacing: 16){
                                        
                                        Image(systemName: "person.2.fill")
                                            .resizable()
                                            .frame(width: 30, height: 20, alignment: .center)
                                            .foregroundColor(Color(.systemBlue))
                                        
                                        Text("Избранные поставщики")
                                            .font(.custom("", size: 16))
                                        
                                        Spacer()
                                        
                                        if menuViewModel.lkVends != "0"{
                                            Text(menuViewModel.lkVends)
                                                .font(.custom("", size: 16))
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        
                                    }
                                    .padding(.vertical, 5)
                                    
                                }
                                
                                NavigationLink(destination: FavoritePostsView()){
                                    
                                    HStack(spacing: 23){
                                        
                                        Image(systemName: "rectangle.fill.on.rectangle.fill")
                                            .resizable()
                                            .frame(width: 23, height: 20, alignment: .center)
                                            .foregroundColor(Color(.systemBlue))
                                        
                                        Text("Избранные посты")
                                            .font(.custom("", size: 16))
                                        
                                        Spacer()
                                        
                                        if menuViewModel.lkPosts != "0"{
                                            Text(menuViewModel.lkPosts)
                                                .font(.custom("", size: 16))
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        
                                    }
                                    .padding(.vertical, 5)
                                    
                                }
                                
                                NavigationLink(destination: AddPointRequestView(), isActive : $menuViewModel.showAddPointRequestView){
                                    
                                    HStack(spacing: 26){
                                        
                                        Image(systemName: "person.badge.plus.fill")
                                            .resizable()
                                            .frame(width: 20, height: 20, alignment: .center)
                                            .foregroundColor(Color(.systemBlue))
                                        
                                        Text("Новый поставщик")
                                            .font(.custom("", size: 16))
                                        
                                    }
                                    .padding(.vertical, 5)
                                    
                                }
                                
                            }
                            
                        } //Log in / reg stuff
                        
                        Section{
                            
                            NavigationLink(destination: MasterNastroekView() , isActive: $masterViewModel.shouldShowMaster){
                                
                                HStack(spacing: 16){
                                    
                                    Image(systemName: "puzzlepiece.fill")
                                        .resizable()
                                        .frame(width: 30, height: 20, alignment: .center)
                                        .foregroundColor(Color(.systemBlue))
                                    
                                    Text("Быстрая настройка выгрузки")
                                        .font(.custom("", size: 16))
                                    
                                }
                                .padding(.vertical, 5)
                                
                            }
                            
                            HStack(spacing: 21){
                                
                                Image(systemName: "menubar.arrow.up.rectangle")
                                    .resizable()
                                    .frame(width: 25, height: 20, alignment: .center)
                                    .foregroundColor(Color(.systemBlue))
                                
                                Text("Парсер")
                                    .font(.custom("", size: 16))
                                
                            }
                            .padding(.vertical, 5)
                            
                        } //Parser
                        
                        Section{
                            
                            List{
                                
                                NavigationLink(destination: SendQuestionView(), isActive : $menuViewModel.showSendQuestionView){
                                    
                                    HStack(spacing: 20){
                                        
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .resizable()
                                            .frame(width: 26, height: 20, alignment: .center)
                                            .foregroundColor(Color(.systemBlue))
                                        
                                        Text("Задать вопрос")
                                            .font(.custom("", size: 16))
                                        
                                    }
                                    .padding(.vertical, 5)
                                    
                                }
                                
                                HStack(spacing: 24){
                                    
                                    Image(systemName: "questionmark.circle.fill")
                                        .resizable()
                                        .frame(width: 22, height: 20, alignment: .center)
                                        .foregroundColor(Color(.systemBlue))
                                    
                                    Text("Помощь")
                                        .font(.custom("", size: 16))
                                    
                                }
                                .padding(.vertical, 5)
                                
                                HStack(spacing: 24){
                                    
                                    Image(systemName: "arrow.right.square")
                                        .resizable()
                                        .frame(width: 22, height: 20, alignment: .center)
                                        .foregroundColor(Color(.systemBlue))
                                    
                                    Text("Выйти из аккаунта")
                                        .font(.custom("", size: 16))
                                    
                                }
                                .padding(.vertical, 5)
                                
                            }
                            
                        } // Help
                        
                    }
                    
                }
                
            }
            .onAppear {
                menuViewModel.loadUserData()
                menuViewModel.updateData()
            }
            
            .navigationBarHidden(true)
            .navigationBarTitle(Text(""), displayMode: .inline)
            
        }
        .environmentObject(menuViewModel)
        .environmentObject(masterViewModel)
        
    }
    
}

