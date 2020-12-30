//
//  AddPointRequestView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 30.12.2020.
//

import SwiftUI

struct AddPointRequestView: View {
    
    @State var text1 = ""
    @State var text2 = ""
    @State var text3 = ""
    
    var body: some View {
        
        ScrollView{
            
            VStack{
                
                VStack(spacing: 32){
                    
                    TextFieldWithDividerView(text: $text1, placeholderText: "Номер места")
                    
                    TextFieldWithDividerView(text: $text2, placeholderText: "Ссылка на поставщика в vk.com")
                    
                    TextFieldWithDividerView(text: $text3, placeholderText: "Комментарий")
                    
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

struct AddPointRequestView_Previews: PreviewProvider {
    static var previews: some View {
        AddPointRequestView()
    }
}

struct TextFieldWithDividerView : View{
    
    @Binding var text : String
    
    var placeholderText : String
    
    var body: some View{
        
        VStack{
            
            TextField(placeholderText, text: $text)
            
            Divider()
            
        }
        
    }
    
}

