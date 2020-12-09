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
                    
                }
                
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
                            
                            Image(systemName: "person.2")
                                .resizable()
                                .frame(width: 30, height: 20, alignment: .center)
                            
                            Text("Зарегистрироваться")
                                .font(.custom("", size: 16))
                            
                        }
                        .padding(.vertical, 5)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
