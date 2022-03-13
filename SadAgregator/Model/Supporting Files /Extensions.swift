//
//  Extensions.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.12.2020.
//

import UIKit
import RealmSwift
import SwiftyJSON
import MobileCoreServices
import SwiftUI
import AudioToolbox

//MARK: - String

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    mutating func compressPhotoQuality(compression : String){
        
        let originalUrlString = self
        
        let indexOfLastSlash = originalUrlString.lastIndex(of: "/")
        let indexOfDot = originalUrlString.lastIndex(of: ".")
        let firstPartOfURL = String(originalUrlString[originalUrlString.startIndex ..< indexOfLastSlash!])
        let secondPartOfURL = "/\(compression)\(String(originalUrlString[indexOfDot! ..< originalUrlString.endIndex]))"
        let fullURL = "\(firstPartOfURL)\(secondPartOfURL)"
        
        self = fullURL
        
    }
    
}

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert(separator: Self, every n: Int) {
        for index in indices.reversed() where index != startIndex &&
        distance(from: startIndex, to: index) % n == 0 {
            insert(contentsOf: separator, at: index)
        }
    }
    
    func inserting(separator: Self, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}

//MARK: - Date

extension Date{
    
    func formatDate(withDot : Bool = false) -> String{
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = withDot ? "dd.MM.yy" : "ddMMyy"
        
        //let date: NSDate? = dateFormatterGet.date(from: "2016-02-29 12:24:26") as NSDate?
        let formattedDate = dateFormatterGet.string(from: self)
        
        return formattedDate
        
    }
    
}

//MARK: - URL

extension URL {
    func mimeType() -> String {
        
        let pathExtension = self.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
        
    }
    
}

//MARK: - UIImageView

extension  UIImageView{
    func load(url: URL){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

//MARK: - UIViewController (DB)

extension UIViewController {
    
    func getUserDataObject () -> UserData?{
        
        let realm = try! Realm()
        
        let userData = realm.objects(UserData.self)
        
        if let userDataObject = userData.first{
            return userDataObject
        }
        
        return nil
    }
    
    func getKey() -> String?{
        
        return getUserDataObject()?.key
        
    }
    
}

//MARK: - UIViewController (Alerts)

extension UIViewController{
    
    func showSimpleAlertWithOkButton(title : String? , message : String? , dismissButtonText : String = "Ок" , dismissAction : (() -> Void)? = nil){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: dismissButtonText, style: .cancel) { (_) in
            
            dismissAction?()
            
            alertController.dismiss(animated: true, completion: nil)
            
        }
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showSimpleAlertWithTwoButtons(title : String? , message : String? = nil, cancelButtonText : String? = "Отмена" , actionButtonText : String , actionButtonAction : @escaping (() -> Void)){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: cancelButtonText, style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: actionButtonText, style: .default, handler: { _ in
            actionButtonAction()
        }))
        
        present(alertController , animated: true , completion: nil)
        
    }
    
    func showActionsSheet(actionsArray : [JSON] , _ selectionCallBack : @escaping (_ action : JSON) -> Void){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionsArray.forEach { (action) in
            
            let alertAction = UIAlertAction(title: action["capt"].stringValue, style: .default) { (_) in
                
                selectionCallBack(action)
                
            }
            
            alertController.addAction(alertAction)
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

//MARK: - UIViewController(animations)

extension UIViewController {
    
    func showSimpleCircleAnimation(activityController : UIActivityIndicatorView){
        
        activityController.center = self.view.center
        
        activityController.style = .large
        
        activityController.startAnimating()
        
        self.view.addSubview(activityController)
        
    }
    
    func stopSimpleCircleAnimation(activityController : UIActivityIndicatorView){
        
        activityController.removeFromSuperview()
        
        activityController.stopAnimating()
        
    }
    
    func previewImage(_ imageLink : String){
        
        let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        galleryVC.previewMode = .simple
        
        galleryVC.selectedImageIndex = 0
        
        galleryVC.images = [PostImage(image: imageLink, imageId: "")]
        
        galleryVC.sizes = []
        
        let navVC = UINavigationController(rootViewController: galleryVC)
        
        self.presentHero(navVC, navigationAnimationType: .fade)
        
    }
    
    func previewTovarImage(_ imageLink : String , tovarTrashTapped : (() -> Void)? , tovarQuestionMarkTapped : (() -> Void)? , tovarInfoTapped : (() -> Void)? , tovarCommentTapped : (() -> Void)? , tovarMagnifyingGlassTapped : (() -> Void)?){
        
        let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        galleryVC.previewMode = .tovar
        
        galleryVC.tovarTrashTapped = tovarTrashTapped
        galleryVC.tovarQuestionMarkTapped = tovarQuestionMarkTapped
        galleryVC.tovarInfoTapped = tovarInfoTapped
        galleryVC.tovarCommentTapped = tovarCommentTapped
        galleryVC.tovarCommentTapped = tovarCommentTapped
        galleryVC.tovarMagnifyingGlassTapped = tovarMagnifyingGlassTapped
        
        galleryVC.selectedImageIndex = 0
        
        galleryVC.images = [PostImage(image: imageLink, imageId: "")]
        
        galleryVC.sizes = []
        
        let navVC = UINavigationController(rootViewController: galleryVC)
        
        self.presentHero(navVC, navigationAnimationType: .fade)
        
    }
    
    func previewImages(_ imageLinks : [String] , selectedImageIndex : Int = 0){
        
        let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        galleryVC.previewMode = .simple
        
        galleryVC.selectedImageIndex = selectedImageIndex
        
        var newImages = [PostImage]()
        
        imageLinks.forEach { imageLink in
            newImages.append(PostImage(image: imageLink, imageId: ""))
        }
        
        galleryVC.images = newImages
        
        galleryVC.sizes = []
        
        let navVC = UINavigationController(rootViewController: galleryVC)
        
        self.presentHero(navVC, navigationAnimationType: .fade)
        
    }
    
}

//MARK: - UIViewController (funcs)

extension UIViewController{
    
    func formatDate(_ date : Date , withDot : Bool = false) -> String{
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = withDot ? "dd.MM.yy" : "ddMMyy"
        
        //let date: NSDate? = dateFormatterGet.date(from: "2016-02-29 12:24:26") as NSDate?
        let formattedDate = dateFormatterGet.string(from: date)
        
        return formattedDate
        
    }
    
    func showAuthScreen(){
        
        MenuViewController.shared.shouldOpenAuthView = true
        self.tabBarController?.selectedIndex = 3
        
    }
    
}

//MARK: - UIView

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
}

//MARK: - RoundedCornerView

class RoundedCornerView: UIView {
    
    // if cornerRadius variable is set/changed, change the corner radius of the UIView
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
}

//MARK: - UIButtonWithInfo

class UIButtonWithInfo : UIButton{
    
    @IBInspectable var info : String = ""
    
}

//MARK: - UIStepper

class UIStepperWithInfo : UIStepper{
    
    @IBInspectable var info : String = ""
    
}

//MARK: - SwiftUI

struct WillDisappearHandler: UIViewControllerRepresentable {
    func makeCoordinator() -> WillDisappearHandler.Coordinator {
        Coordinator(onWillDisappear: onWillDisappear)
    }
    
    let onWillDisappear: () -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<WillDisappearHandler>) -> UIViewController {
        context.coordinator
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<WillDisappearHandler>) {
    }
    
    typealias UIViewControllerType = UIViewController
    
    class Coordinator: UIViewController {
        let onWillDisappear: () -> Void
        
        init(onWillDisappear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}

struct WillDisappearModifier: ViewModifier {
    let callback: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(WillDisappearHandler(onWillDisappear: callback))
    }
}

extension View {
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        self.modifier(WillDisappearModifier(callback: perform))
    }
}

enum Vibration {
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    @available(iOS 13.0, *)
    case soft
    @available(iOS 13.0, *)
    case rigid
    case selection
    case oldSchool
    
    public func vibrate() {
        switch self {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .soft:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        case .rigid:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
