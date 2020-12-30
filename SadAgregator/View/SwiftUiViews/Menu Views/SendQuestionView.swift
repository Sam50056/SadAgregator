//
//  SendQuestionView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 30.12.2020.
//

import SwiftUI

struct SendQuestionView : View {
    
    @State var text1 = ""
    
    @State var text2 = ""
    
    var body: some View {
        
        ScrollView{
            
            VStack{
                
                VStack(spacing: 32){
                    
                    TextFieldWithDividerView(text: $text1, placeholderText: "Email")
                    
                    MultilineTextView(text: $text2)
                        .frame(height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(#colorLiteral(red: 0.8500244617, green: 0.8551172614, blue: 0.854884088, alpha: 1)))
                        )
                    
                }
                
                Spacer()
                    .frame(height: 16)
                
                HStack{
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }){
                        
                        Text("Добавить ссылку")
                            .padding(10)
                            .background(Color(.systemBlue))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                    }
                    
                }
                
            }
            .padding()
            
        }
        .navigationBarTitle(Text("Садовод - Агрегатор"), displayMode : .inline)
        
    }
    
}

