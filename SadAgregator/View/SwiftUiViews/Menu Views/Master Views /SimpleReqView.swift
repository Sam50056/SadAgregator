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
                        .background(answer.rec == 1 ? Color(#colorLiteral(red: 0.9177419543, green: 0.9516320825, blue: 0.9884006381, alpha: 1)) : Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(#colorLiteral(red: 0.8500244617, green: 0.8551172614, blue: 0.854884088, alpha: 1)))
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
