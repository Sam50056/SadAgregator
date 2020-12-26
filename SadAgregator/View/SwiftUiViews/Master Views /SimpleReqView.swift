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
            
            VStack(spacing: 16){
                
                ForEach(0..<masterViewModel.currentViewData!["ansqers"].arrayValue.count) { index in
                    
                    Button(action: {
                        
                    }){
                        
                        HStack{
                            
                            VStack(alignment: .leading,spacing: 8){
                                
                                Text("\(masterViewModel.currentViewData!["ansqers"].arrayValue[index]["capt"].stringValue)")
                                    .foregroundColor(Color(.systemBlue))
                                
                                if masterViewModel.currentViewData!["ansqers"].arrayValue[index]["hint"].exists(){
                                    
                                    Text("\(masterViewModel.currentViewData!["ansqers"].arrayValue[index]["hint"].stringValue)")
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
                        .background(Color(.white))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        
                    }
                    
                }
                
            }
            
        }
        .padding(.horizontal , 16)
        
    }
    
}
