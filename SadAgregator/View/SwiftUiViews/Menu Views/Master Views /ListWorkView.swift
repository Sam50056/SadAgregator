//
//  ListWorkView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.12.2020.
//

import SwiftUI
import SwiftyJSON

struct ListWorkView: View {
    
    @EnvironmentObject var masterViewModel : MasterViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16){
            
            Spacer()
            
            VStack(alignment: .leading,spacing: 16){
                
                Text(masterViewModel.currentViewData!["capt"].stringValue)
                    .font(.system(size: 21))
                    .bold()
                
                if masterViewModel.currentViewData!["hint"].stringValue != "" {
                    
                    Text(masterViewModel.currentViewData!["hint"].stringValue)
                        .foregroundColor(Color(.systemGray))
                        .font(.system(size: 17))
                    
                }
                
                NavigationLink(destination:
                                
                                ScrollView{
                                    
                                    VStack{
                                        
                                        ForEach(masterViewModel.list2 , id: \.id){ item in
                                            
                                            ListWorkItemView(item: item, isList1: false)
                                                .environmentObject(masterViewModel)
                                            
                                        }
                                        
                                    }
                                    .padding()
                                    .background(Color("whiteblack"))
                                    .frame(maxWidth: .infinity)
                                    
                                }.onAppear{
                                    masterViewModel.extButtonPressed()
                                }
                                .onDisappear{
                                    masterViewModel.getSearchListWorkData()
                                }
                                .navigationBarTitle(Text(masterViewModel.currentViewData!["capt_list_exists"].stringValue), displayMode: .inline)
                               
                               , isActive : $masterViewModel.shouldShowSecondScreenInListWork){
                    HStack{
                        
                        Text(masterViewModel.currentViewData!["capt_list_ext_button"].stringValue)
                            .foregroundColor(Color(.systemBlue))
                        
                        Text("\(masterViewModel.extButtonTitleCount)")
                            .padding(.all , 8)
                            .font(.system(size: 14))
                            .foregroundColor(Color("whiteblack"))
                            .background(Circle().foregroundColor(Color(.systemBlue)))
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("whiteblack"))
                    .foregroundColor(Color("whiteblack"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("searchbargray"))
                    )
                    
                }
                
                Text(masterViewModel.currentViewData!["capt_list_name"].stringValue)
                    .font(.system(size: 19))
                    .bold()
                
                HStack{
                    
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(Color("searchbargray"))
                    
                    TextField(masterViewModel.currentViewData!["edt_place_holder"].stringValue, text: $masterViewModel.listWorkSearchTextFieldText)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.white))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("searchbargray"))
                )
                
            }
            
            if !masterViewModel.list.isEmpty{
                
                VStack{
                    
                    ForEach(masterViewModel.list , id: \.id){ item in
                        
                        ListWorkItemView(item: item, isList1: true)
                        
                    }
                    
                }
                .padding()
                .background(Color("whiteblack"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(#colorLiteral(red: 0.8500244617, green: 0.8551172614, blue: 0.854884088, alpha: 1)))
                )
                
            }
            
            Spacer()
            
            Button(action: {
                
                masterViewModel.donePressedInListWork()
                
            }){
                
                VStack(alignment: .center){
                    
                    Text("Готово")
                    
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBlue))
                .foregroundColor(.white)
                .cornerRadius(8)
                .offset(y: 26)
                
            }
            
        }
        .padding(.horizontal,16)
        .onDisappear{
            if !masterViewModel.shouldShowSecondScreenInListWork{
                masterViewModel.listWorkSearchTextFieldText = ""
            }
        }
        
    }
    
}

struct ListWorkItem : Identifiable{
    
    let id : Int
    let capt : String
    let subCapt : String
    let act : String
    let ext : Int
    
}

struct ListWorkItemView : View , AddOrDeleteListWorkExtDataManagerDelegate{
    
    @EnvironmentObject var masterViewModel : MasterViewModel
    
    let item : ListWorkItem
    
    let isList1 : Bool //This var shows if current item is in list1 or list2 
    
    var body: some View{
        
        VStack{
            
            HStack{
                
                VStack(alignment: .leading, spacing: 8){
                    
                    Text(item.capt)
                        .foregroundColor(Color("blackwhite"))
                    
                    if item.subCapt != ""{
                        Text(item.subCapt)
                            .foregroundColor(Color(.systemGray))
                    }
                    
                }
                .font(.system(size: 16))
                
                Spacer()
                
                if item.act != ""{
                    
                    Button(action: {
                        
                        AddOrDeleteListWorkExtDataManager(delegate: self).getAddOrDeleteListWorkExtData(method: (item.ext == 1 ? "del" : "add"), key: masterViewModel.key, stepId: masterViewModel.currentStepId!, listId: item.id)
                        
                    }){
                        Text(item.act)
                            .foregroundColor(Color(.systemBlue))
                    }
                }
                
            }
            
            Divider()
            
        }
        
    }
    
    func didGetAddOrDeleteListWorkExtData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                masterViewModel.extButtonTitleCount = item.ext == 1 ? masterViewModel.extButtonTitleCount - 1 : masterViewModel.extButtonTitleCount + 1
                
                if isList1 {
                    masterViewModel.getSearchListWorkData()
                }else{
                    masterViewModel.extButtonPressed()
                }
                
            }
            
        }
        
    }
    
    func didFailGettingAddOrDeleteListWorkExtDataWithError(error: String) {
        print("Error with AddOrDeleteListWorkExtDataManager : \(error)")
    }
    
}
