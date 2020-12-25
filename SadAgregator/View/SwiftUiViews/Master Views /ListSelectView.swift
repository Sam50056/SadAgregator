//
//  ListSelectView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI

struct ListSelectView: View {
    
    @State var text : String = ""
    
    var array = ["Sam", "Sam","Sam", "Sam","Sam", "Sam","Sam", "Sam","Sam", "Sam","Sam", "Sam"]
    
    var body: some View {
        
        
        GeometryReader { geometry in
            
            ScrollView{
                
                VStack(alignment: .leading, spacing: 16){
                    
                    VStack(alignment: .leading,spacing: 16){
                        
                        Text("Sam Hello Sam")
                            .font(.system(size: 21))
                            .bold()
                        
                        HStack{
                            
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .center)
                                .foregroundColor(Color(.systemGray))
                            
                            TextField("Poisk", text: $text)
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.white))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        
                    }
                    
                    
                    VStack{
                        
                        ForEach(array , id: \.self){ item in
                            
                            VStack{
                                
                                HStack{
                                    
                                    VStack(alignment: .leading, spacing: 8){
                                        
                                        Text(item)
                                        
                                        Text("Some description")
                                            .foregroundColor(Color(.systemGray))
                                        
                                    }
                                    .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    Text("Connected")
                                        .foregroundColor(Color(.systemBlue))
                                    
                                }
                                .onTapGesture {
                                    print("Selected item: \(item)")
                                }
                                
                                Divider()
                                
                            }
                            
                        }
                        
                    }
                    .padding()
                    
                }
                .padding(.horizontal,16)
                .frame(width: geometry.size.width) // Make the scroll view full-width
                .frame(minHeight: geometry.size.height) // Set the content’s min height to the parent
                
            }
        }
        
    }
    
}
