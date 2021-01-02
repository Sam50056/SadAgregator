//
//  AddPointRequestView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 30.12.2020.
//

import SwiftUI
import SwiftyJSON

struct AddPointRequestView: View {
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
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
                        AddPointRequestDataManager(delegate: self).getAddPointRequestData(key: menuViewModel.key, place: text1, vkUrl: text2, comment: text3)
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

//MARK: - AddPointRequestDataManagerDelegate

extension AddPointRequestView : AddPointRequestDataManagerDelegate{
    
    func didGetAddPointRequestData(data: JSON) {
        
        DispatchQueue.main.async{
            
            if data["result"].intValue == 1{
                
                menuViewModel.showAddPointRequestView = false
                
            }
            
        }
        
    }
    
    func didFailGettingAddPointRequestDataWithError(error: String) {
        print("Error with AddPointRequestDataManager : \(error)")
    }
    
    
}

//MARK: - TextFieldWithDividerView

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

