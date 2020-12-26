//
//  MasterNastroekView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI

struct MasterNastroekView: View {
    
    @ObservedObject var masterViewModel = MasterViewModel()
    
    var body: some View {
        
        ZStack{
            
            Color(#colorLiteral(red: 0.9590891004, green: 0.9660314918, blue: 0.9695957303, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                
                ScrollView{
                    
                    VStack{
                        
                        if masterViewModel.currentViewData != nil{
                            
                            if masterViewModel.currentViewType == "simple_req"{
                                Spacer()
                                SimpleReqView()
                                Spacer()
                            }
                            
                            if masterViewModel.currentViewType == "input_val"{
                                Spacer()
                                InputValView()
                                Spacer()
                            }
                            
                            if masterViewModel.currentViewType == "list_select"{
                                ListSelectView()
                            }
                            
                            if masterViewModel.currentViewData!["descr"].exists(){
                                
                                Text(masterViewModel.currentViewData!["descr"].stringValue)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(.systemGray))
                                    .padding(.horizontal)
                                
                            }
                            
                            if masterViewModel.shouldShowBackButton{
                                
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
        .environmentObject(masterViewModel)
        .onAppear{
            masterViewModel.getStepData()
        }
        
    }
    
}
