//
//  InputValView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI

struct InputValView: View {
    
    @State var textFieldText = ""
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16){
            
            Text("Aasdoasjdoajsdojasodj")
                .font(.system(size: 21))
                .bold()
            
            HStack{
                
                TextField("", text: $textFieldText)
                
            }
            .padding()
            .background(Color(.white))
            .cornerRadius(8)
            .shadow(radius: 2)
            
            HStack{
                
                Text("Done")
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBlue))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                Text("Done")
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBlue))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
            }
            
        }
        .padding(.horizontal,16)
        
    }
    
}
