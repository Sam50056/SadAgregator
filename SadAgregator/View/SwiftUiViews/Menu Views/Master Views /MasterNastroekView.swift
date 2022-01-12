//
//  MasterNastroekView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.12.2020.
//

import SwiftUI

struct MasterNastroekView: View {
    
    @Binding var showMaster : Bool
    
    @ObservedObject var masterViewModel = MasterViewModel()
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
    var body: some View {
        
        ZStack{
            
            Color("whiteblack")
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
        .navigationBarTitle(Text("Мастер настроек"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: {
                                    
                                    if masterViewModel.shouldShowBackButton{
                                        masterViewModel.backButtonPressed()
                                    }else{
                                        showMaster = false
                                    }
                                    
                                }) {
                                    
                                    Image(systemName: "chevron.left")
                                        .frame(minWidth: 20, minHeight: 20)
                                        .contentShape(Rectangle())
                                        .padding()
                                }
                            ,trailing:
                                Button(action: {
                                    showMaster = false
                                    menuViewModel.updateData()
                                }){
                                    
                                    Image(systemName: "multiply")
                                        .frame(minWidth: 20, minHeight: 20)
                                        .contentShape(Rectangle())
                                        .padding()
                                    
                                })
        
        .onAppear{
            masterViewModel.hideMaster = {
                showMaster = false
            }
            masterViewModel.loadUserData()
            masterViewModel.getStepData()
        }
        .onDisappear{
            
            if !masterViewModel.shouldShowSecondScreenInListWork{ //I add this check because there's one screen that is shown via nav link in list work , and there's no need for emptying data when showing it
                masterViewModel.emptyData()
            }
            
        }
        .environmentObject(masterViewModel)
        
    }
    
}
