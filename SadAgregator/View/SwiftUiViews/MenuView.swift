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
    
    let realm = try! Realm()
    
    var key = ""
    
    @State var isLogged = false
    
    @State var showModalLogIn = false
    @State var showModalReg = false
    
    init() {
        loadUserData()
    }
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                
                if !isLogged{
                    
                    Form{
                        
                        Section{
                            
                            Text("Добро пожаловать!")
                                .font(.title)
                                .fontWeight(.semibold)
                                .padding(.all, 5)
                            
                        } //Welcome
                        
                        Section{
                            
                            List{
                                
                                NavigationLink(destination: AuthView(key: key, isPresented: $showModalLogIn, isLogged: $isLogged, showLogin: true), isActive: $showModalLogIn){
                                    
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
                                
                                NavigationLink(destination: AuthView(key: key, isPresented: $showModalReg, isLogged: $isLogged, showLogin: false), isActive: $showModalReg) {
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
                                
                                HStack(spacing: 20){
                                    
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .resizable()
                                        .frame(width: 26, height: 20, alignment: .center)
                                        .foregroundColor(Color(.systemBlue))
                                    
                                    Text("Задать вопрос")
                                        .font(.custom("", size: 16))
                                    
                                }
                                .padding(.vertical, 5)
                                
                                
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
                            
                            VStack(alignment: .leading){
                                
                                Text("Максим")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding([.top,.horizontal], 5)
                                    .padding(.bottom, 2)
                                
                                HStack{
                                    
                                    Text("Перейти в настройки")
                                        .font(.system(size: 15))
                                    
                                    Spacer()
                                    
                                    Text("32323")
                                        .font(.system(size: 15))
                                    
                                }
                                .padding([.bottom, .horizontal], 5)
                                .foregroundColor(Color(.systemGray))
                                
                            }
                            
                        } //Top Section
                        
                        Section{
                            
                            List{
                                
                                HStack(spacing: 16){
                                    
                                    Image(systemName: "person.2.fill")
                                        .resizable()
                                        .frame(width: 30, height: 20, alignment: .center)
                                        .foregroundColor(Color(.systemBlue))
                                    
                                    Text("Избранные поставщики")
                                        .font(.custom("", size: 16))
                                    
                                }
                                .padding(.vertical, 5)
                                
                                HStack(spacing: 23){
                                    
                                    Image(systemName: "rectangle.fill.on.rectangle.fill")
                                        .resizable()
                                        .frame(width: 23, height: 20, alignment: .center)
                                        .foregroundColor(Color(.systemBlue))
                                    
                                    Text("Избранные посты")
                                        .font(.custom("", size: 16))
                                    
                                }
                                .padding(.vertical, 5)
                                
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
                            
                        } //Log in / reg stuff
                        
                        Section{
                            
                            HStack(spacing: 16){
                                
                                Image(systemName: "puzzlepiece.fill")
                                    .resizable()
                                    .frame(width: 30, height: 20, alignment: .center)
                                    .foregroundColor(Color(.systemBlue))
                                
                                Text("Быстрая настройка выгрузки")
                                    .font(.custom("", size: 16))
                                
                            }
                            .padding(.vertical, 5)
                            
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
                                
                                HStack(spacing: 20){
                                    
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .resizable()
                                        .frame(width: 26, height: 20, alignment: .center)
                                        .foregroundColor(Color(.systemBlue))
                                    
                                    Text("Задать вопрос")
                                        .font(.custom("", size: 16))
                                    
                                }
                                .padding(.vertical, 5)
                                
                                
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
            
            .navigationBarHidden(true)
            
        }
        
    }
    
}


//MARK: - Data Manipulation Methods

extension MenuView {

    mutating func loadUserData (){

        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key

        isLogged = userDataObject.first!.isLogged

    }

}
