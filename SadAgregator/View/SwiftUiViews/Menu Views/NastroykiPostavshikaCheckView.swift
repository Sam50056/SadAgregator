//
//  NastroykiPostavshikaCheckView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.06.2021.
//

import SwiftUI
import SwiftyJSON
import RealmSwift

struct NastroykiPostavshikaCheckView: View {
    
    @EnvironmentObject private var menuViewModel : MenuViewModel
    
    @State private var shouldShowLogin : Bool?
    
    let realm = try! Realm()
    
    private let vkAuthService = VKAuthService()
    
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
                            .padding(.horizontal)
                        
                        PodkluchitVkVigruzkuView(text: "Авторизоваться").onTapGesture {
                            
                            vkAuthService.isPresentedInProfileView = false
                            vkAuthService.isPresentedInNastroykiPostavshika = true
                            vkAuthService.delegate = self
                            vkAuthService.wakeUpSession()
                            
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
                    
                    update()
                    
                }
        }
        
    }
    
}

//MARK:- Functions

extension NastroykiPostavshikaCheckView{
    
    func update(with newKey : String = "") {
        
        var key = ""
        
        if !newKey.isEmpty{
            key = newKey
        }else{
            guard let oldKey = menuViewModel.getUserDataObject()?.key else {return}
            key = oldKey
        }
        
        VendFormDataManager(delegate: self).getVendFormData(key: key)
        
    }
    
    func login(newKey : String){
        
        if let userDataObject = menuViewModel.getUserDataObject(){
            
            try! realm.write{
                userDataObject.key = newKey
            }
            
//            loadUserData()
            
        }
        
//        isLogged = true
//
        update()
        
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

//MARK: - Vk Stuff

extension NastroykiPostavshikaCheckView : VKAuthServiceDelegate{
    
    func vkAuthServiceShouldShow(viewController: UIViewController) {
        
        guard !vkAuthService.isPresentedInProfileView else {return}
        
        //Presenting VK View Controller
        SceneDelegate.shared().window?.rootViewController?.present(viewController, animated: true, completion: nil)
        
    }
    
    func vkAuthServiceSignIn() {
        
        guard !vkAuthService.isPresentedInProfileView else {return}
        
        print("Successfully Signed via VK")
        
        if let safeVkToken = vkAuthService.token{
            
            AuthSocialDataManagerWithClosure().getGetAuthSocialData(social: "VK", token: safeVkToken, key: menuViewModel.getUserDataObject()!.key) { data, error in
                
                DispatchQueue.main.async {
                    
                    if let error = error , data == nil{
                        print("Error with AuthSocialDataManagerWithClosure : \(error)")
                        return
                    }
                    
                    guard let newKey = data!["token"].string else {
                        print("Error with token in AuthSocialDataManager")
                        return
                    }
                    
                    print("NEW KEY : \(newKey)")
                    
                    login(newKey: newKey)
                    
                }
                
            }
            
        }
        
    }
    
    func vkAuthServiceSignInDidFail() {
        
        guard !vkAuthService.isPresentedInProfileView else {return}
        
        print("Failed VK Sign In")
        
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
