//
//  ReviewUpdateViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 16.12.2020.
//

import UIKit
import Cosmos
import IQKeyboardManagerSwift
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
    
    //MARK: - File Sending
    
    func sendFileToServer(from fromUrl : URL, to toUrl : String){
        
        print("import result : \(fromUrl)")
        
        guard let toUrl = URL(string: toUrl) else {return}
        
        print("To URL: \(toUrl)")
        
        do{
            
            let data = try Data(contentsOf: fromUrl)
            
            let image = UIImage(data: data)!
            
            let imageData = image.jpegData(compressionQuality: 0.5)
            
            var request = URLRequest(url: toUrl)
            
            request.httpMethod = "POST"
            request.setValue("text/plane", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if error != nil {
                    print("Error sending file: \(error!.localizedDescription)")
                    return
                }
                
                guard let data = data else {return}
                
                let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
                
                print("Answer : \(json)")
                
            }
            
            task.resume()
            
        }catch{
            print(error)
        }
        
    }
    
}

//MARK: - NewPhotoPlaceDataManagerDelegate

extension ReviewUpdateViewController : NewPhotoPlaceDataManagerDelegate{
    
    func didGetNewPhotoPlaceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let url = "\(data["post_to"].stringValue)/store?file_name=\(data["file_name"].stringValue)"
            
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
