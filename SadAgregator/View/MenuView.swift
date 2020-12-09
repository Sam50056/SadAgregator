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
                        
                        HStack{
                            
                            Image(systemName: "person")
                            
                            Text("Войти в аккаунт TK-SAD")
                            
                        }.padding(.vertical, 5)
                        
                        HStack{
                            
                            Image(systemName: "person")
                            
                            Text("Зарегистрироваться")
                            
                        }
                        
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
