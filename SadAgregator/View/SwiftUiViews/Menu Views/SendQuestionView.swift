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
                    
                    VStack{
                        
                        TextField("",text: $text2)
                            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.horizontal, 4)
                            .padding(.vertical , 4)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("searchbargray"))
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
                
            }else{
                
                
                
            }
            
        }
        
    }
    
    func didFailGettingSendQuestionDataWithError(error: String) {
        print("Error with SendQuestionDataManager : \(error)")
    }
    
}
