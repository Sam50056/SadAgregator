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
import SDWebImage

class ReviewUpdateViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var key : String?
    var vendId : String?
    var myRate : Double?
    
    lazy var reviewUpdateDataManager = ReviewUpdateDataManager()
    
    lazy var newPhotoPlaceDataManager = NewPhotoPlaceDataManager()
    
    var selectedImageURL : URL?
    
    var selectedImageLink : String?
    var selectedImageId : String?
    
    var imageCellObjects = [ImageCellObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        
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
        let numberOfChars = newText.count
        return numberOfChars < 400;
    }
    
    //MARK: - Actions
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        guard let key = key , let vendId = vendId else {return}
        
        if !textView.text.contains("\\") , !titleTextField.text!.contains("\\"){
            
            reviewUpdateDataManager.getReviewUpdateData(key: key, vendId: vendId, rating: Int(ratingView.rating), title: titleTextField.text!, text: textView.text)
            
            self.navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    @IBAction func addPhotoPressed(_ sender: UIButton) {
        
        showImagePickerController(sourceType: .photoLibrary)
        
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton){
        
        let index = sender.tag
        
        imageCellObjects.remove(at: index)
        
        imagesCollectionView.reloadData()
        
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
            
            let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
                
                if error != nil {
                    print("Error sending file: \(error!.localizedDescription)")
                    return
                }
                
                guard let data = data else {return}
                
                let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
                
                print("Answer : \(json)")
                
                DispatchQueue.main.async {
                    
                    guard let imageId = selectedImageId , let imageLink = selectedImageLink else {return}
                    
                    imageCellObjects.append(ImageCellObject(id: imageId, link: imageLink))
                    
                    imagesCollectionView.reloadData()
                    
                    selectedImageLink = nil
                    selectedImageId = nil
                    selectedImageURL = nil
                    
                }
                
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
            
            let imageId = data["image_id"].stringValue
            
            let imageLinkWithPortAndWithoutFile = "\(data["post_to"].stringValue)"
            let splitIndex = imageLinkWithPortAndWithoutFile.lastIndex(of: ":")!
            let imageLink = "\(String(imageLinkWithPortAndWithoutFile[imageLinkWithPortAndWithoutFile.startIndex ..< splitIndex]))\(data["file_name"].stringValue)"
            
            print("Image Link: \(imageLink)")
            
            selectedImageId = imageId
            selectedImageLink = imageLink
            
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

//MARK: - UICollectionView Data Source

extension ReviewUpdateViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCellObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        let imageCellObject = imageCellObjects[indexPath.row]
        
        setUpImageCell(cell: cell, cellObject: imageCellObject, index: indexPath.row)
        
        return cell
        
    }
    
    func setUpImageCell(cell : UICollectionViewCell, cellObject : ImageCellObject, index : Int){
        
        if let imageView = cell.viewWithTag(1) as? UIImageView ,
           let badgeView = cell.viewWithTag(2),
           let removeButton = cell.viewWithTag(3) as? UIButton{
            
            if let safeURL = URL(string: cellObject.link){
                
                imageView.sd_setImage(with: safeURL)
                
                imageView.layer.cornerRadius = 8
                imageView.clipsToBounds = true
                badgeView.layer.cornerRadius = badgeView.frame.width / 2
                
                removeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), for: .touchUpInside)
                removeButton.tag = index
                
            }
            
        }
        
    }
    
}

struct ImageCellObject{
    
    let id : String
    let link : String
    
}
