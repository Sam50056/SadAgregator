//
//  MasterNastroekView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI

struct MasterNastroekView: View {
    
    @EnvironmentObject var masterViewModel : MasterViewModel
    
    var body: some View {
        
        ZStack{
            
            Color(#colorLiteral(red: 0.9590891004, green: 0.9660314918, blue: 0.9695957303, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                
                ScrollView{
                    
                    VStack{
                        
                        if masterViewModel.currentViewType != nil{
                            
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
                                ListSelectView().padding(.top)
                            }
                            
                            if masterViewModel.currentViewType == "list_work"{
                                Spacer()
                                ListWorkView().padding(.top)
                                Spacer()
                            }
                            
                            if masterViewModel.currentViewData!["descr"].exists(){
                                
                                Text(masterViewModel.currentViewData!["descr"].stringValue)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(.systemGray))
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                
                            }
                            
                            if masterViewModel.shouldShowBackButton{
                                
                                Button(action: {
                                    masterViewModel.backButtonPressed()
                                }){
                                    
                                    HStack(spacing: 8){
                                        
                                        Image(systemName: "arrow.backward")
                                            .resizable()
                                            .frame(width: 16, height: 12, alignment: .center)
                                        
                                        Text("НАЗАД")
                                            .font(.system(size: 16))
                                        
                                    }
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(.systemBlue))
                                    )
                                    
                                }
                                .padding(.horizontal, 8)
                                
                                
                            }
                            
                        }
                        
                    }
                    .padding(.bottom)
                    .frame(width: geometry.size.width) // Make the scroll view full-width
                    .frame(minHeight: geometry.size.height) // Set the content’s min height to the parent
                    
                }
                
            }
            
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .onAppear{
            masterViewModel.getStepData()
        }
        .onDisappear{
            
            if !masterViewModel.shouldShowSecondScreenInListWork{ //I add this check because there's one screen that is shown via nav link in list work , and there's no need for emptying data when showing it
                masterViewModel.emptyData()
            }
            
        }
        
    }
    
}
