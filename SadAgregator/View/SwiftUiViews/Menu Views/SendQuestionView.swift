//
//  SendQuestionView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 30.12.2020.
//

import SwiftUI
import SwiftyJSON

struct SendQuestionView : View {
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
    @State var text1 = ""
    
    @State var text2 = ""
    
    var body: some View {
        
        ScrollView{
            
            VStack{
                
                VStack(spacing: 32){
                    
                    TextFieldWithDividerView(text: $text1, placeholderText: "Email")
                    
                    MultilineTextView(text: $text2)
                        .frame(height: 120)
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
                        
                        guard let key = menuViewModel.getUserDataObject()?.key else {return}
                        
                        SendQuestionDataManager(delegate: self).getSendQuestionData(key: key, email: text1, question: text2)
                        
                    }){
                        
                        Text("Задать вопрос")
                            .padding(10)
                            .background(Color(.systemBlue))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                    }
                    
                }
                
            }
            .padding()
            
        }
        .navigationBarTitle(Text("Задать вопрос"), displayMode : .inline)
        
    }
    
}

//MARK: - SendQuestionDataManagerDelegate

extension SendQuestionView : SendQuestionDataManagerDelegate{
    
    func didGetSendQuestionData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                menuViewModel.showSendQuestionView = false
                
            }
            
        }
        
    }
    
    func didFailGettingSendQuestionDataWithError(error: String) {
        print("Error with SendQuestionDataManager : \(error)")
    }
    
}
