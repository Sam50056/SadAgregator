//
//  MasterNastroekView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI

enum MasterViewType{
    case simpleReq , inputVal , listSelect , listWork
}

struct MasterNastroekView: View {
    
    @State var currentViewType : MasterViewType = .inputVal
    @State var shouldShowBackButton = true
    
    let screenSize = UIScreen.main.bounds
    
    var body: some View {
        
        ZStack{
            
            Color(#colorLiteral(red: 0.9590891004, green: 0.9660314918, blue: 0.9695957303, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                
                ScrollView{
                    
                    VStack{
                        
                        if currentViewType != nil{
                            
                            if currentViewType == .simpleReq{
                                Spacer()
                                SimpleReqView(capt: "Hello", answers: ["Sam" , "Hey", "Another Sam"])
                            }
                            
                            if currentViewType == .inputVal{
                                Spacer()
                                InputValView()
                            }
                            
                            if currentViewType == .listSelect{
                                ListSelectView()
                            }
                            
                            if shouldShowBackButton{
                                
                                Spacer()
                                
                                Button("Back"){
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    .padding(.bottom)
                    .frame(width: geometry.size.width) // Make the scroll view full-width
                    .frame(minHeight: geometry.size.height) // Set the content’s min height to the parent
                    
                }
                
            }
            
        }
        
    }
    
}
