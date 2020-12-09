//
//  MenuView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.12.2020.
//

import SwiftUI

struct MenuView: View {
    
    var body: some View {
        
        VStack{
            
            Form{
                
                Section{
                    
                    Text("Добро пожаловать!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.all, 5)
                    
                } //Welcome
                
                Section{
                    
                    List{
                        
                        HStack(spacing: 23){
                            
                            Image(systemName: "arrow.forward.square")
                                .resizable()
                                .frame(width: 23, height: 20, alignment: .center)
                            
                            Text("Войти в аккаунт TK-SAD")
                                .font(.custom("", size: 16))
                            
                        }
                        .padding(.vertical, 5)
                        
                        
                        HStack(spacing: 16){
                            
                            Image(systemName: "person.2.fill")
                                .resizable()
                                .frame(width: 30, height: 20, alignment: .center)
                            
                            Text("Зарегистрироваться")
                                .font(.custom("", size: 16))
                            
                        }
                        .padding(.vertical, 5)
                        
                    }
                    
                } //Log in / reg stuff
                
                Section{
                    
                    HStack(spacing: 21){
                        
                        Image(systemName: "menubar.arrow.up.rectangle")
                            .resizable()
                            .frame(width: 25, height: 20, alignment: .center)
                        
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
                            
                            Text("Задать вопрос")
                                .font(.custom("", size: 16))
                            
                        }
                        .padding(.vertical, 5)
                        
                        
                        HStack(spacing: 24){
                            
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 20, alignment: .center)
                            
                            Text("Помощь")
                                .font(.custom("", size: 16))
                            
                        }
                        .padding(.vertical, 5)
                        
                    }
                    
                } // Help
                
            }
            
        }
        
    }
    
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
