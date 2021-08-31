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
    
    var items = [TableViewItem]()
    
    var mainText : String?
    
    var img : String?
    
    var showMore = false
    
    var autoHide = true{
        didSet{
            if timer != nil , !autoHide{
                timer.invalidate()
                timeProgressView.setProgress(0, animated: true)
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
                items.append(TableViewItem(label1Text: jsonOpt["capt"].stringValue, label2Text: jsonOpt["val"].stringValue))
            }
            
        }
    }
    
    var timer : Timer!
    var seconds : Float = 0
    
    var time : Float = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomView.isHidden = true
        
        cameraView.roundCorners(.allCorners, radius: 20)
        dotsView.roundCorners(.allCorners, radius: 20)
        
        closeButtonViewButton.setTitle(nil, for: .normal)
        cameraViewButton.setTitle(nil, for: .normal)
        dotsViewButton.setTitle(nil, for: .normal)
        
        timeProgressView.transform = timeProgressView.transform.scaledBy(x: 1, y: 2)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 1.5)
        
        progressLabel.text = "18/26"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = UIColor(named: "whiteblack")
        
        dobavitPhotoViewButton.backgroundColor = UIColor(named: "gray")
        dobavitPhotoViewButton.layer.cornerRadius = 8
        
        resetTimer()
        
    }
    
    //MARK: - Actions
 
    @IBAction func closeButtonPressed(_ sender : Any?){
        closeButtonPressed?()
    }
    
    @IBAction func podrobneeButtonPressed(_ sender : Any?){
        podrobneeButtonPressed?()
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
        
        podrobneeButton.addTarget(self, action: #selector(podrobneeButtonPressed(_:)), for: .touchUpInside)
        
    }
    
}

extension SortirovkaContentViewController {
    
    struct TableViewItem{
        
        var label1Text : String
        var label2Text : String
        
    }
    
}
