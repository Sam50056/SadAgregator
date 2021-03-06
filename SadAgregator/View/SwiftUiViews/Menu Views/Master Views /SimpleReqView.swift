//
//  SimpleReqView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI
import SwiftyJSON

struct SimpleReqView: View {
    
    @EnvironmentObject var masterViewModel : MasterViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16){
            
            Text(masterViewModel.currentViewData!["capt"].stringValue)
                .bold()
                .font(.system(size: 21))
            
            if masterViewModel.currentViewData!["hint"].stringValue != "" {
                
                Text(masterViewModel.currentViewData!["hint"].stringValue)
                    .foregroundColor(Color(.systemGray))
                    .font(.system(size: 17))
                
            }
            
            VStack(spacing: 16){
                
                ForEach(masterViewModel.answers , id: \.id) { answer in
                    
                    Button(action: {
                        
                        masterViewModel.selectSimpleReqViewAnswer(id: answer.id)
                        
                    }){
                        
                        HStack{
                            
                            VStack(alignment: .leading,spacing: 8){
                                
                                Text("\(answer.capt)")
                                    .foregroundColor(Color(.systemBlue))
                                
                                if answer.hint != ""{
                                    
                                    Text("\(answer.hint)")
                                        .foregroundColor(Color(.systemGray))
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                }
                                
                            }
                            
                            Spacer()
                            
                        }
                        .font(.system(size: 18))
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(answer.rec == 1 ? Color("highlited") : Color("gray"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("gray"))
                        )
                        
                    }
                    
                }
                
            }
            
        }
        .padding(.horizontal , 16)
        
    }
    
}

struct SimpleReqAnswer : Identifiable {
    
    let id : Int
    let capt : String
    let hint : String
    let rec : Int
    
}
