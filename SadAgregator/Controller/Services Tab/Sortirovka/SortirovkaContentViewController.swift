//
//  SortirovkaContentViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 27.08.2021.
//

import UIKit
import SwiftyJSON

class SortirovkaContentViewController: UIViewController {
    
    @IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var closeButtonImageView: UIImageView!
    @IBOutlet weak var closeButtonViewButton: UIButton!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraViewButton: UIButton!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBOutlet weak var dotsView: UIView!
    @IBOutlet weak var dotsViewButton: UIButton!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var dobavitPhotoViewButton: UIButton!
    @IBOutlet weak var podrobneeViewButton : UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    var key = ""
    
    private lazy var newPhotoPlaceDataManager = NewPhotoPlaceDataManager()
    private lazy var photoSavedDataManager = PhotoSavedDataManager()
    
    private var imageUrl : URL?
    private var image : UIImage?
    private var imageWebUrl : String?
    private var imageId : String?
    
    private var boxView = UIView()
    private var blurEffectView = UIVisualEffectView()
    
    var state = 1{
        didSet{
            UIView.animate(withDuration: 1) { [weak self] in
                self?.tableView.reloadData()
                self?.view.layoutIfNeeded()
                if self!.state == 3{
                    self?.bottomView.isHidden = false
                }else{
                    self?.bottomView.isHidden = true
                }
            }
        }
    } // 1 is bottom , 2 is half , 3 is full
    
    var closeButtonPressed : (() -> Void)?
    var podrobneeButtonPressed : (() -> Void)?
    var moveToState : ((Int) -> Void)?
    
    var items = [TableViewItem]()
    
    var mainText : String?
    
    var img : String?
    
    var showMore = false
    
    var autoHide = true{
        didSet{
            if timer != nil , !autoHide{
                timer.invalidate()
                timeProgressView.setProgress(0, animated: true)
                timeProgressView.isHidden = true
            }else{
                resetTimer()
            }
        }
    }
    
    var data : JSON?{
        didSet{
            
            guard let data = data else {return}
            
            mainText = "\(data["capt_main"].stringValue)\(data["capt_sub"].stringValue != "" ? "\n\(data["capt_sub"].stringValue)" : "")"
            
            img = data["img"].string
            
            data["opts"].arrayValue.forEach { jsonOpt in
                
                if jsonOpt["point_id"].stringValue != ""{
                    
                    items.append(TableViewItem(label1Text: jsonOpt["capt"].stringValue, label2Text: jsonOpt["val"].stringValue , shouldLabel2BeBlue: true , pointId: jsonOpt["point_id"].stringValue))
                    
                }else if jsonOpt["vend_id"].stringValue != ""{
                    
                    items.append(TableViewItem(label1Text: jsonOpt["capt"].stringValue, label2Text: jsonOpt["val"].stringValue , shouldLabel2BeBlue: true , vendId: jsonOpt["vend_id"].stringValue))
                    
                }else if jsonOpt["broker_id"].stringValue != ""{
                    
                    items.append(TableViewItem(label1Text: jsonOpt["capt"].stringValue, label2Text: jsonOpt["val"].stringValue, shouldLabel2BeBlue: true , brokerId: jsonOpt["broker_id"].stringValue))
                    
                }else if jsonOpt["url"].stringValue != ""{
                    
                    items.append(TableViewItem(label1Text: jsonOpt["capt"].stringValue, label2Text: jsonOpt["val"].stringValue, shouldLabel2BeBlue: true , url: jsonOpt["url"].stringValue))
                    
                }else if jsonOpt["img"].stringValue != ""{
                    
                    items.append(TableViewItem(label1Text: jsonOpt["capt"].stringValue, label2Text: jsonOpt["val"].stringValue , shouldLabel2BeBlue: true, img: jsonOpt["img"].stringValue))
                    
                }else{
                    
                    items.append(TableViewItem(label1Text: jsonOpt["capt"].stringValue, label2Text: jsonOpt["val"].stringValue))
                    
                }
                
            }
            
        }
    }
    
    var timer : Timer!
    var seconds : Float = 0
    
    var time : Float = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPhotoPlaceDataManager.delegate = self
        
        bottomView.isHidden = true
        
        cameraView.roundCorners(.allCorners, radius: 20)
        dotsView.roundCorners(.allCorners, radius: 20)
        
        closeButtonViewButton.setTitle(nil, for: .normal)
        cameraViewButton.setTitle(nil, for: .normal)
        dotsViewButton.setTitle(nil, for: .normal)
        
        timeProgressView.transform = timeProgressView.transform.scaledBy(x: 1, y: 2)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 1.5)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = UIColor(named: "whiteblack")
        
        dobavitPhotoViewButton.backgroundColor = UIColor(named: "gray")
        dobavitPhotoViewButton.layer.cornerRadius = 8
        
        setUpProgressView()
        
        podrobneeViewButton.setTitle("", for: .normal)
        dobavitPhotoViewButton.setTitle("", for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        resetTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: - Actions
 
    @IBAction func closeButtonPressed(_ sender : Any?){
        closeButtonPressed?()
    }
    
    @IBAction func podrobneeButtonPressed(_ sender : Any?){
        podrobneeButtonPressed?()
    }
    
    @IBAction func addImageButtonPressed(_ sender : Any?){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Сделать снимок", style: .default, handler: { [weak self] _ in
            self?.showImagePickerController(sourceType: .camera)
        }))
        
        alertController.addAction(UIAlertAction(title: "Из галереи", style: .default, handler: { [weak self] _ in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }))
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        present(alertController , animated: true)
        
    }
    
    @IBAction func moreButtonPressed(_ sender : Any?){
        
        showMore.toggle()
        
        tableView.reloadData()
        
    }
    
    @IBAction func autoHideSwitchValueChanged(_ sender : UISwitch){
        
        autoHide = sender.isOn
        
    }
    
    @IBAction func timeStepperValueChanged(_ sender : UIStepperWithInfo){
        
        //        print("New Value = \(sender.value)")
        
        time = Float(sender.value)
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        timer.invalidate()
        
        resetTimer(withSeconds: true)
        
    }
    
    //MARK: - Functions
    
    func resetTimer(withSeconds : Bool = true){
        
        timeProgressView.progress = 0.0
        
        if withSeconds{
            seconds = 0
        }
        
        if autoHide{
            
            timeProgressView.isHidden = false
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
                
                guard self.seconds < self.time else {
                    self.timer.invalidate()
                    self.closeButtonPressed?()
                    return
                }
                
                self.seconds += 0.01
                
                self.timeProgressView.setProgress(Float(self.seconds / self.time), animated: true)
                
            }
            
        }
        
    }
    
    func showBoxView(with text : String) {
        
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        let width = text.width(withConstrainedHeight: UIScreen.main.bounds.width - 16, font: UIFont.systemFont(ofSize: 17)) + 60
        
        // You only need to adjust this frame to move it anywhere you want
        boxView = UIView(frame: CGRect(x: view.frame.midX - (width/2), y: view.frame.midY - 25, width: width, height: 50))
        boxView.backgroundColor = UIColor(named: "gray")
        boxView.alpha = 0.95
        boxView.layer.cornerRadius = 10
        
        boxView.center = view.center
        
        //Here the spinnier is initialized
        let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 45, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.gray
        textLabel.text = text
        
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        view.addSubview(boxView)
        
        view.isUserInteractionEnabled = false
        
    }
    
    func removeBoxView(){
        
        boxView.removeFromSuperview()
        blurEffectView.removeFromSuperview()
        view.isUserInteractionEnabled = true
        
    }
    
    func checkSent() {
        
        guard let imageId = imageId , let pid = data?["pi_id"].string else {return}
        
        AssemblySetRealPhotoDataManager().getAssemblySetRealPhotoData(key: key, itemId: pid, imgId: imageId) { [weak self] data, error in
            
            if let error = error , data == nil{
                print("Error with :\(error)")
                return
            }
            
            if data!["result"].intValue == 1{
                
                guard let imageWebUrl = self?.imageWebUrl else {return}
                self?.img = imageWebUrl
                self?.tableView.reloadData()
                
                self?.resetTimer(withSeconds: false)
                
            }
            
        }
        
        self.image = nil
        self.imageId = nil
        self.imageUrl = nil
        self.imageWebUrl = nil
        
    }
    
    func setUpProgressView(){
        
        guard let data = data,
              let max = data["progress"]["max"].string,
              let curr = data["progress"]["curr"].string,
              !max.isEmpty
        else { progressView.isHidden = true; progressLabel.isHidden = true; return}
        
        let maxInt = Int(max)!
        let currInt = Int(curr)!
        
        progressView.setProgress(Float(currInt / maxInt), animated: false)
        
        progressLabel.text = curr + "/" + max
        
    }
    
}

//MARK: - TableView

extension SortirovkaContentViewController : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if state == 1{
            return 3
        }else if state == 2{
            return 4
        }else if state == 3{
            return 4
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return showMore ? 1 : 0
        }else if section == 1{
            return 1
        }else if section == 2{
            return 1
        }else if section == 3{
            return state == 3 ? items.count : 1
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let section = indexPath.section
        
        var cell = UITableViewCell()
        
        if section == 0{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel ,
                  let autoHideSwitch = cell.viewWithTag(2) as? UISwitch,
                  let label2 = cell.viewWithTag(3) as? UILabel ,
                  let stepper = cell.viewWithTag(4) as? UIStepper,
                  let bgView = cell.viewWithTag(5)
            else {return cell}
            
            label1.text = "Скрывать автоматически"
            
            label2.text = "Через \(Int(time)) сек."
            
            autoHideSwitch.isOn = autoHide
            
            autoHideSwitch.addTarget(self, action: #selector(autoHideSwitchValueChanged(_:)), for: .valueChanged)
            
            stepper.value = Double(time)
            
            stepper.stepValue = 1
            
            stepper.minimumValue = 1
            
            stepper.maximumValue = .infinity
            
            stepper.addTarget(self, action: #selector(timeStepperValueChanged(_:)), for: .valueChanged)
            
            bgView.backgroundColor = UIColor(named: "grey")
            
        }else if section == 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "oneLabelCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = mainText ?? ""
            (cell.viewWithTag(1) as! UILabel).font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            (cell.viewWithTag(1) as! UILabel).numberOfLines = 0
            (cell.viewWithTag(1) as! UILabel).textAlignment = .center
            
        }else if section == 2{
            
            if state == 1{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "footerCell", for: indexPath)
                
                makeFooterCell(cell: cell)
                
            }else if state == 2 || state == 3{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
                
                if var img = img , !img.isEmpty{
                    
                    img.compressPhotoQuality(compression: "340")
                    
                    (cell.viewWithTag(1) as! UIImageView).sd_setImage(with: URL(string: img) , completed: nil)
                    (cell.viewWithTag(1) as! UIImageView).contentMode = .scaleAspectFill
                    (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = 8
                    
                }else{
                    
                    (cell.viewWithTag(1) as! UIImageView).image = UIImage(systemName: "cart")
                    (cell.viewWithTag(1) as! UIImageView).contentMode = .scaleAspectFit
                    
                }
                    
            }
            
        }else if section == 3{
                
            if state == 2{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "footerCell", for: indexPath)
                
                makeFooterCell(cell: cell)
                
            }else if state == 3{
                
                guard !items.isEmpty else {return cell}
                
                let item = items[index]
                
                cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath)
                
                guard let label1 = cell.viewWithTag(1) as? UILabel ,
                      let label2 = cell.viewWithTag(2) as? UILabel
                else {return cell}
                
                label1.text = item.label1Text
                label2.text = item.label2Text
                
                label2.textColor = item.shouldLabel2BeBlue ? .systemBlue : UIColor(named: "blackwhite")
                
            }
                
        }
        
        cell.backgroundColor = UIColor(named: "whiteblack")
        cell.contentView.backgroundColor = UIColor(named: "whiteblack")
        
        return cell
    }
    
    func makeFooterCell(cell : UITableViewCell){
        
        guard let dobavitPhotoButton = cell.viewWithTag(1) as? UIButton,
              let podrobneeButton = cell.viewWithTag(3) as? UIButton else {
                  return
              }
        
        dobavitPhotoButton.backgroundColor = UIColor(named: "gray")
        dobavitPhotoButton.layer.cornerRadius = 8
        
        dobavitPhotoViewButton.setTitle("", for: .normal)
        podrobneeViewButton.setTitle("", for: .normal)
        podrobneeButton.addTarget(self, action: #selector(podrobneeButtonPressed(_:)), for: .touchUpInside)
        dobavitPhotoButton.addTarget(self, action: #selector(addImageButtonPressed(_:)), for: .touchUpInside)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if section == 3 , state == 3 {
            
            let item = items[indexPath.row]
            
            guard item.shouldLabel2BeBlue else {return}
            
            timer.invalidate()
            
            if !item.url.isEmpty{
                
                guard let url = URL(string: item.url) else {return}
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }else if !item.img.isEmpty{
                
                previewImage(item.img)
                
            }else if !item.brokerId.isEmpty{
                
                let brokerCardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BrokerCardVC") as! BrokerCardViewController
                
                brokerCardVC.thisBrokerId = item.brokerId
                
                navigationController?.pushViewController(brokerCardVC, animated: true)
                
            }else if !item.vendId.isEmpty{
                
                let vendorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VendorVC") as! PostavshikViewController
                
                vendorVC.thisVendorId = item.vendId
                
                navigationController?.pushViewController(vendorVC, animated: true)
                
            }else if !item.pointId.isEmpty{
                
                let pointVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PointVC") as! PointViewController
                
                pointVC.thisPointId = item.pointId
                
                navigationController?.pushViewController(pointVC, animated: true)
                
            }
            
        }else if section == 2 , state == 2 || state == 3{
            
            guard let img = img else {return}
            
            timer.invalidate()
            
            previewImage(img)
            
        }
        
    }
    
}

//MARK: - Structs

extension SortirovkaContentViewController {
    
    struct TableViewItem{
        
        var label1Text : String
        var label2Text : String
        
        var shouldLabel2BeBlue : Bool = false
        
        var pointId : String = ""
        var vendId : String = ""
        var brokerId : String = ""
        var url : String = ""
        var img : String = ""
        
    }
    
}

//MARK: - UIImagePickerControllerDelegate

extension SortirovkaContentViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func showImagePickerController(sourceType : UIImagePickerController.SourceType) {
        
        timer.invalidate()
        moveToState?(3)
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let safeUrl = info[.imageURL] as? URL{
            
            imageUrl = safeUrl
            showBoxView(with: "Загрузка фото чека")
            newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
            
        }else if let safeImage = info[.originalImage] as? UIImage{
            
            image = safeImage
            showBoxView(with: "Загрузка фото чека")
            newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
            
        }
        
        //        print(info)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


//MARK: - NewPhotoPlaceDataManagerDelegate

extension SortirovkaContentViewController : NewPhotoPlaceDataManagerDelegate{
    
    func didGetNewPhotoPlaceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let url = "\(data["post_to"].stringValue)/store?file_name=\(data["file_name"].stringValue)"
                
                print("URL FOR SENDING THE FILE: \(url)")
                
                if let checkImageUrl = imageUrl {
                    sendFileToServer(from: checkImageUrl, to: url)
                }else if let image = image{
                    sendFileToServer(image: image, to: url)
                }
                
                let imageId = data["image_id"].stringValue
                
                let imageLinkWithPortAndWithoutFile = "\(data["post_to"].stringValue)"
                let splitIndex = imageLinkWithPortAndWithoutFile.lastIndex(of: ":")!
                let imageLink = "\(String(imageLinkWithPortAndWithoutFile[imageLinkWithPortAndWithoutFile.startIndex ..< splitIndex]))\(data["file_name"].stringValue)"
                
                print("Image Link: \(imageLink)")
                
                imageWebUrl = imageLink
                
                self.imageId = imageId
                
            }else{
                
                removeBoxView()
                
            }
            
        }
        
    }
    
    func didFailGettingNewPhotoPlaceDataWithError(error: String) {
        print("Error with NewPhotoPlaceDataManager: \(error)")
    }
    
}

//MARK: - File Sending

extension SortirovkaContentViewController{
    
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
                
                DispatchQueue.main.async { [self] in
                    
                    print("Got check sent to server")
                    
                    photoSavedDataManager.getPhotoSavedData(key: key, photoId: imageId!) { data, error in
                        
                        if let error = error{
                            print("Error with PhotoSavedDataManager : \(error)")
                            return
                        }
                        
                        guard let data = data else {return}
                        
                        if data["result"].intValue == 1{
                            
                            print("Check image successfuly saved to server")
                            
                            DispatchQueue.main.async { [weak self] in
                                
                                self?.removeBoxView()
                                
                                self?.checkSent()
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            
            task.resume()
            
        }catch{
            print(error)
        }
        
    }
    
    func sendFileToServer(image : UIImage, to toUrl : String){
        
        //        print("import result : \(fromUrl)")
        
        guard let toUrl = URL(string: toUrl) else {return}
        
        print("To URL: \(toUrl)")
        
        do{
            
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
                
                DispatchQueue.main.async { [self] in
                    
                    print("Got check sent to server")
                    
                    photoSavedDataManager.getPhotoSavedData(key: key, photoId: imageId!) { data, error in
                        
                        if let error = error{
                            print("Error with PhotoSavedDataManager : \(error)")
                            return
                        }
                        
                        guard let data = data else {return}
                        
                        if data["result"].intValue == 1{
                            
                            print("Check image successfuly saved to server")
                            
                            DispatchQueue.main.async { [weak self] in
                                
                                self?.removeBoxView()
                                
                                self?.checkSent()
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            
            task.resume()
            
        }catch{
            print(error)
        }
        
    }
    
}
