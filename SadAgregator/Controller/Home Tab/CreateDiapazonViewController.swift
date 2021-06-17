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
    
    @IBOutlet weak var okruglenieLabel: UILabel!
    
    @IBOutlet weak var inRublesButton: UIButton!
    @IBOutlet weak var inPercentsButton: UIButton!
    
    @IBOutlet weak var otmenaButton: UIButton!
    @IBOutlet weak var sozdatButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var picker: UIPickerView!
    
    private var key = ""
    
    var thisZone : PurchaseZone?
    
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
        otmenaButton.addTarget(self, action: #selector(otmenaButtonTapped(_:)), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped(_:)), for: .touchUpInside)
        
        picker.delegate = self
        picker.dataSource = self
        
        sozdatButton.layer.cornerRadius = 8
        
        inRublesButton.layer.cornerRadius = 8
        inPercentsButton.layer.cornerRadius = 8
        
        if thisZone != nil {
            sozdatButton.setTitle("Изменить", for: .normal)
            prewriteParameters()
        }else{
            picker.selectRow(1, inComponent: 0, animated: false)
            selectRubles()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = thisZone == nil ? "Создать диапазон" : "Изменить диапазон"
        
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
            
            nacenkaTrailLabel.text = "руб."
            
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
        
        if zone.marge.contains("%"){
            isInPercents = true
        }else{
            isInRubles = true
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
    
    @IBAction func createButtonTapped(_ sender : UIButton){
        
        let from = otTextField.text!.isEmpty ? "0" : otTextField.text!
        let to = doTextField.text!.isEmpty ? "0" : doTextField.text!
        
        let nacenka = nacenkaTextField.text! + (isInPercents ? "%" : "")
        let fix = fixNadbavkaTextField.text!.isEmpty ? "0" : fixNadbavkaTextField.text!
        
        if let zone = thisZone {
            PurchasesUpdateZonePriceDataManager(delegate: self).getPurchasesUpdateZonePriceDataManager(key: key, zoneId : zone.id , from: from, to: to, merge: nacenka, fix: fix, trunc: okruglenieArray[picker.selectedRow(inComponent: 0)])
        }else{
            PurchasesAddZonePriceDataManager(delegate: self).getPurchasesAddZonePriceDataManager(key: key, from: from, to: to, merge: nacenka, fix: fix, trunc: okruglenieArray[picker.selectedRow(inComponent: 0)])
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
                
                showSimpleAlertWithOkButton(title: "Ошибка запроса", message: nil)
                
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
                
                showSimpleAlertWithOkButton(title: "Ошибка запроса", message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesUpdateZonePriceDataWithError(error: String) {
        print("Error with PurchasesUpdateZonePriceDataManager : \(error)")
    }
    
}
