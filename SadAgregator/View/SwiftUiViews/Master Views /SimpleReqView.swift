//
//  SimpleReqView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI

struct SimpleReqView: View {
    
    var capt : String
    
    var answers : [String]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16){
            
            Text(capt)
                .bold()
                .font(.system(size: 21))
            
            VStack(spacing: 16){
                
                ForEach(self.answers , id: \.self) { answer in
                    
                    HStack{
                        
                        VStack(spacing: 8){
                            
                            Text(answer)
                                .foregroundColor(Color(.systemBlue))
                            
                            Text(answer)
                            
                        }
                        Spacer()
                        
                    }
                    .font(.system(size: 18))
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    
                }
                
            }
            
        }
        .padding(.horizontal , 16)
        
    }
    
}
