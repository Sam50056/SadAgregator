//
//  ListWorkView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.12.2020.
//

import SwiftUI

struct ListWorkView: View {
    
    @EnvironmentObject var masterViewModel : MasterViewModel
    
    @State var text = ""
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16){
            
            VStack(alignment: .leading,spacing: 16){
                
                Text(masterViewModel.currentViewData!["capt"].stringValue)
                    .font(.system(size: 21))
                    .bold()
                
                if masterViewModel.currentViewData!["hint"].stringValue != "" {
                    
                    Text(masterViewModel.currentViewData!["hint"].stringValue)
                        .foregroundColor(Color(.systemGray))
                        .font(.system(size: 17))
                    
                }
                
                Button(action: {
                    
                    
                    
                }){
                    
                    HStack{
                        
                        Text("Вы еще не добавили поставщиков")
                            .foregroundColor(Color(.systemBlue))
                        
                        ZStack{
                            
                            Circle()
                                .foregroundColor(Color(.systemBlue))
                                .frame(width: 30, height: 30)
                            
                            Text("0")
                                .foregroundColor(Color(.white))
                                .padding(2)
                        } // Text in cirlce
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    
                }
                
                Text("Поиск по поставщикам")
                    .font(.system(size: 19))
                    .bold()
                
                HStack{
                    
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(Color(.systemGray))
                    
                    TextField("Поиск по списку", text: $text)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.white))
                .cornerRadius(8)
                .shadow(radius: 4)
                
            }
            //
            //            VStack{
            //
            //                ForEach(masterViewModel.items , id: \.id){ item in
            //
            //                    VStack{
            //
            //                        HStack{
            //
            //                            VStack(alignment: .leading, spacing: 8){
            //
            //                                Text(item.capt)
            //
            //                                if item.hint != ""{
            //                                    Text(item.hint)
            //                                        .foregroundColor(Color(.systemGray))
            //                                }
            //
            //                            }
            //                            .font(.system(size: 16))
            //
            //                            Spacer()
            //
            //                            if item.button != ""{
            //                                Text(item.button)
            //                                    .foregroundColor(Color(.systemBlue))
            //                            }
            //
            //                        }
            //
            //                        Divider()
            //
            //                    }
            //                    .background(item.rec == 1 ? Color(#colorLiteral(red: 0.9177419543, green: 0.9516320825, blue: 0.9884006381, alpha: 1)) : Color.white)
            //                    .onTapGesture {
            //                        masterViewModel.selectListSelectViewAnswer(id: item.id)
            //                    }
            //
            //                }
            //
            //            }
            //            .padding()
            //            .background(Color(.white))
            //            .cornerRadius(12)
            //            .shadow(radius: 4)
            
        }
        .padding(.horizontal,16)
        
    }
    
}

struct ListWorkView_Previews: PreviewProvider {
    static var previews: some View {
        ListWorkView()
    }
}
