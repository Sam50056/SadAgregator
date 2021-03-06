//
//  CreateDiapazonViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.05.2021.
//

import UIKit
import SwiftyJSON

class CreateDiapazonViewController: UIViewController {
    
    @IBOutlet weak var otTextField: UITextField!
    @IBOutlet weak var nacenkaTextField: UITextField!
    @IBOutlet weak var doTextField: UITextField!
    @IBOutlet weak var fixNadbavkaTextField: UITextField!
    
    @IBOutlet weak var fixNadbavkalabel : UILabel!
    @IBOutlet weak var nacenkaTrailLabel : UILabel!
    @IBOutlet weak var tipNacenkiLabel : UILabel!
    
    @IBOutlet weak var okruglenieLabel: UILabel!
    
    @IBOutlet weak var inRublesButton: UIButton!
    @IBOutlet weak var inPercentsButton: UIButton!
    
    @IBOutlet weak var picker: UIPickerView!
    
    private var key = ""
    
    var thisZone : PurchaseZone?
    
    var isPosrednik = false
    
    var createdDiapazon : (() -> ())?
    
    private var isInRubles = true{
        didSet{
            if isInRubles{
                isInPercents = false
                selectRubles()
            }
        }
    }
    private var isInPercents = false{
        didSet{
            if isInPercents{
                isInRubles = false
                selectPercents()
            }
        }
    }
    
    private var okruglenieArray = ["10" , "50" , "100"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        key = "part_2_test"
        
        inRublesButton.addTarget(self, action: #selector(inRublesButtonTapped(_:)), for: .touchUpInside)
        inPercentsButton.addTarget(self, action: #selector(inPersentsButtonTapped(_:)), for: .touchUpInside)
        
        picker.delegate = self
        picker.dataSource = self
        
        inRublesButton.layer.cornerRadius = 8
        inPercentsButton.layer.cornerRadius = 8
        
        if isPosrednik{
            
            isInPercents = true
            
            fixNadbavkalabel.isHidden = true
            fixNadbavkaTextField.isHidden = true
            okruglenieLabel.isHidden = true
            picker.isHidden = true
            inRublesButton.isHidden = true
            inPercentsButton.isHidden = true
            tipNacenkiLabel.isHidden = true
            
            if thisZone != nil {
                prewriteParameters()
            }
            
        }else{
            
            if thisZone != nil {
                prewriteParameters()
            }else{
                picker.selectRow(1, inComponent: 0, animated: false)
                selectRubles()
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = thisZone == nil ? "?????????????? ????????????????" : "???????????????? ????????????????"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: (thisZone != nil ? "????????????????" : "??????????????"), style: .plain, target: self, action: #selector(createButtonTapped(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "????????????", style: .plain, target: self, action: #selector(otmenaButtonTapped(_:)))
        
    }
    
}

//MARK: - Functions

extension CreateDiapazonViewController{
    
    func selectRubles(){
        
        UIView.animate(withDuration: 0.3) { [self] in
            
            inRublesButton.backgroundColor = .systemBlue
            inRublesButton.setTitleColor(.white, for: .normal)
            
            inPercentsButton.backgroundColor = .none
            inPercentsButton.setTitleColor(.systemBlue, for: .normal)
            
            nacenkaTrailLabel.text = "??????."
            
            fixNadbavkaTextField.isHidden = true
            fixNadbavkalabel.isHidden = true
            
            picker.isHidden = true
            okruglenieLabel.isHidden = true
            
        }
        
    }
    
    func selectPercents() {
        
        UIView.animate(withDuration: 0.3) { [self] in
            
            inPercentsButton.backgroundColor = .systemBlue
            inPercentsButton.setTitleColor(.white, for: .normal)
            
            inRublesButton.backgroundColor = .none
            inRublesButton.setTitleColor(.systemBlue, for: .normal)
            
            nacenkaTrailLabel.text = "%"
            
            fixNadbavkaTextField.isHidden = false
            fixNadbavkalabel.isHidden = false
            
            picker.isHidden = false
            okruglenieLabel.isHidden = false
            
        }
        
    }
    
    func prewriteParameters(){
        
        guard let zone = thisZone else {return}
        
        otTextField.text = zone.from == "0" ? "" : zone.from
        
        doTextField.text = zone.to == "0" ? "" : zone.to
        
        nacenkaTextField.text = zone.marge.replacingOccurrences(of: "%", with: "")
        
        if !isPosrednik{
            
            if zone.marge.contains("%"){
                isInPercents = true
            }else{
                isInRubles = true
            }
            
        }
        
        picker.selectRow(okruglenieArray.firstIndex(of: zone.trunc) ?? 1, inComponent: 0, animated: false)
        
        fixNadbavkaTextField.text = zone.fix
        
    }
    
}

//MARK: - Actions

extension CreateDiapazonViewController{
    
    @IBAction func inRublesButtonTapped(_ sender : UIButton){
        
        isInRubles = true
        
    }
    
    @IBAction func inPersentsButtonTapped(_ sender : UIButton){
        
        isInPercents = true
        
    }
    
    @IBAction func otmenaButtonTapped(_ sender : UIButton){
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func createButtonTapped(_ sender : Any){
        
        let from = otTextField.text!.isEmpty ? "0" : otTextField.text!
        let to = doTextField.text!.isEmpty ? "0" : doTextField.text!
        
        let nacenka = nacenkaTextField.text! + (isInPercents ? "%" : "")
        let fix = fixNadbavkaTextField.text!.isEmpty ? "0" : fixNadbavkaTextField.text!
        
        if isPosrednik{
            
            if let zone = thisZone {
                BrokersUpdZonePriceDataManager(delegate: self).getBrokersUpdZonePriceData(key: key, zoneId : zone.id , from: from, to: to, merge: nacenka)
            }else{
                BrokersAddZonePriceDataManager(delegate: self).getBrokersAddZonePriceData(key: key, from: from, to: to, merge: nacenka)
            }
            
        }else{
            
            if let zone = thisZone {
                PurchasesUpdateZonePriceDataManager(delegate: self).getPurchasesUpdateZonePriceDataManager(key: key, zoneId : zone.id , from: from, to: to, merge: nacenka, fix: fix, trunc: okruglenieArray[picker.selectedRow(inComponent: 0)])
            }else{
                PurchasesAddZonePriceDataManager(delegate: self).getPurchasesAddZonePriceDataManager(key: key, from: from, to: to, merge: nacenka, fix: fix, trunc: okruglenieArray[picker.selectedRow(inComponent: 0)])
            }
            
        }
        
    }
    
}

//MARK: - UIPickerViewDelegate

extension CreateDiapazonViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return okruglenieArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return okruglenieArray[row]
    }
    
}

//MARK: - PurchasesAddZonePriceDataManagerDelegate

extension CreateDiapazonViewController : PurchasesAddZonePriceDataManagerDelegate{
    
    func didGetPurchasesAddZonePriceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                navigationController?.popViewController(animated: true)
                
                createdDiapazon?()
                
            }else{
                
                showSimpleAlertWithOkButton(title: "???????????? ??????????????", message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesAddZonePriceDataWithError(error: String) {
        print("Error with PurchasesAddZonePriceDataManager : \(error)")
    }
    
}

//MARK: - PurchasesUpdateZonePriceDataManagerDelegate

extension CreateDiapazonViewController : PurchasesUpdateZonePriceDataManagerDelegate{
    
    func didGetPurchasesUpdateZonePriceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                navigationController?.popViewController(animated: true)
                
                createdDiapazon?()
                
            }else{
                
                showSimpleAlertWithOkButton(title: "???????????? ??????????????", message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesUpdateZonePriceDataWithError(error: String) {
        print("Error with PurchasesUpdateZonePriceDataManager : \(error)")
    }
    
}

//MARK: - BrokersAddZonePriceDataManagerDelegate

extension CreateDiapazonViewController : BrokersAddZonePriceDataManagerDelegate{
    
    func didGetBrokersAddZonePriceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                navigationController?.popViewController(animated: true)
                
                createdDiapazon?()
                
            }else{
                
                showSimpleAlertWithOkButton(title: "???????????? ??????????????", message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingBrokersAddZonePriceDataWithError(error: String) {
        print("Error with BrokersAddZonePriceDataManager : \(error)")
    }
    
}

//MARK: - BrokersUpdZonePriceDataManagerDelegate

extension CreateDiapazonViewController : BrokersUpdZonePriceDataManagerDelegate{
    
    func didGetBrokersUpdZonePriceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                navigationController?.popViewController(animated: true)
                
                createdDiapazon?()
                
            }else{
                
                showSimpleAlertWithOkButton(title: "???????????? ??????????????", message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingBrokersUpdZonePriceDataWithError(error: String) {
        print("Error with BrokersUpdZonePriceDataManager : \(error)")
    }
    
}
