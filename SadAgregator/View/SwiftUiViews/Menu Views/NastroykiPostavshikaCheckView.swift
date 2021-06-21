//
//  NastroykiPostavshikaCheckView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.06.2021.
//

import SwiftUI
import SwiftyJSON

struct NastroykiPostavshikaCheckView: View {
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
    @State var shouldShowLogin : Bool?
    
    var body: some View {
        
        if shouldShowLogin != nil , shouldShowLogin!{
            
            GeometryReader { geometry in
                
                ScrollView(.vertical){
                    
                    VStack(alignment: .center){
                        
                        Text("Авторизируйтесь через Vk.com с помощью вашей торговой страницы")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(.systemGray))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        PodkluchitVkVigruzkuView(text: "Авторизоваться").onTapGesture {
                            
                        }
                        
                        Text("ИЛИ")
                            .foregroundColor(Color(.systemGray))
                        
                        PodkluchitVkVigruzkuView(text: "Подать заявку").onTapGesture {
                            UIApplication.shared.open(URL(string: "https://vk.me/club154227107")!, options: [:], completionHandler: nil)
                        }
                        
                    }
                    .frame(width: geometry.size.width) // Make the scroll view full-width
                    .frame(minHeight: geometry.size.height) // Set the content’s min height to the parent
                    
                }
                
            }
            
        }else if shouldShowLogin != nil , !shouldShowLogin!{
            
            NastroykiPostavshikaView().navigationTitle("Настройки поставщика")
            
        }else{
            ActivityIndicatorView(isAnimating: .constant(true), style: .large)
                .onAppear{
                    
                    guard let key = menuViewModel.getUserDataObject()?.key else {return}
                    
                    VendFormDataManager(delegate: self).getVendFormData(key: key)
                    
                }
        }
        
    }
    
}

//MARK: - VendFormDataManagerDelegate

extension NastroykiPostavshikaCheckView : VendFormDataManagerDelegate{
    
    func didGetVendFormData(data: JSON) {
        
        DispatchQueue.main.async {
            
            self.shouldShowLogin = data["show_login"].stringValue == "1" ? true : false
            
        }
        
    }
    
    func didFailGettingVendFormDataWithError(error: String) {
        print("Error with VendFormDataManager : \(error)")
    }
    
}

//MARK: - Views

extension NastroykiPostavshikaCheckView{
    
    private struct PodkluchitVkVigruzkuView : View{
        
        var text : String
        
        var body: some View{
            
            VStack{
                
                HStack{
                    
                    Image("vk")
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                    
                    Text(text)
                        .font(.system(size: 18))
                        .foregroundColor(Color.white)
                        .fontWeight(.semibold)
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical , 8)
                .foregroundColor(Color(.systemBlue))
                .background(Color(#colorLiteral(red: 0.3157836497, green: 0.5058068037, blue: 0.7203877568, alpha: 1)))
                .cornerRadius(8)
                
            }.padding()
            
        }
        
    }
    
}

struct NastroykiPostavshikaCheckView_Previews: PreviewProvider {
    static var previews: some View {
        NastroykiPostavshikaCheckView()
    }
}
