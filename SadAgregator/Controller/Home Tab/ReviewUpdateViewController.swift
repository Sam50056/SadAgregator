//
//  ReviewUpdateViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 16.12.2020.
//

import UIKit
import Cosmos
import IQKeyboardManagerSwift
import MobileCoreServices
import Alamofire
import SwiftyJSON

class ReviewUpdateViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var key : String?
    var vendId : String?
    var myRate : Double?
    
    lazy var reviewUpdateDataManager = ReviewUpdateDataManager()
    
    lazy var newPhotoPlaceDataManager = NewPhotoPlaceDataManager()
    
    var selectedImageURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        newPhotoPlaceDataManager.delegate = self
        
        textView.text = ""
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = #colorLiteral(red: 0.9175441861, green: 0.917704761, blue: 0.9175459743, alpha: 1)
        
        textView.layer.cornerRadius = 5
        
        saveButton.layer.cornerRadius = 5
        
        if let myRate = myRate {
            
            ratingView.rating = myRate
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let myRate = myRate else {return}
        
        self.navigationItem.title = myRate == 0 ? "ОСТАВИТЬ ОТЗЫВ" : "РЕДАКТИРОВАТЬ ОТЗЫВ"
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars < 400;
    }
    
    //MARK: - Actions
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        
        guard let key = key , let vendId = vendId else {return}
        
        if !textView.text.contains("\\"){
            
            reviewUpdateDataManager.getReviewUpdateData(key: key, vendId: vendId, rating: Int(ratingView.rating), title: titleTextField.text!, text: textView.text)
            
            self.navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    @IBAction func addPhotoPressed(_ sender: UIButton) {
        
        showImagePickerController(sourceType: .photoLibrary)
        
    }
    
    func sendFileToServer(from fromUrl : URL, to toUrl : String){
        
        print("import result : \(fromUrl)")
        
        let fileName = fromUrl.lastPathComponent
        let mimeType = fromUrl.mimeType()
        
        do{
            
            let data = try Data(contentsOf: fromUrl)
            
            let headers: HTTPHeaders = [.contentType("multipart/form")]
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file" , fileName: fileName , mimeType: mimeType)
            },
            to: toUrl, headers : headers)
            .responseJSON { response in
                print("ANSWER: \(String(data: response.data!, encoding: String.Encoding.windowsCP1251)!)")
            }
            
        }catch{
            print(error)
        }
        
    }
    
}

//MARK: - NewPhotoPlaceDataManagerDelegate

extension ReviewUpdateViewController : NewPhotoPlaceDataManagerDelegate{
    
    func didGetNewPhotoPlaceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let url = "\(data["post_to"].stringValue)\(data["file_name"].stringValue)"
            
            print("URL FOR SENDING THE FILE: \(url)")
            
            guard let selectedImageURL = self.selectedImageURL else {return}
            
            sendFileToServer(from: selectedImageURL, to: url)
            
        }
        
    }
    
    func didFailGettingNewPhotoPlaceDataWithError(error: String) {
        print("Error with NewPhotoPlaceDataManager: \(error)")
    }
    
}

//MARK: - UIDocumentPickerDelegate

extension ReviewUpdateViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func showImagePickerController(sourceType : UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let safeUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL , let key = key{
            
            
            newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
            
            selectedImageURL = safeUrl
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
