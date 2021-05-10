//
//  CreateDiapazonViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.05.2021.
//

import UIKit

class CreateDiapazonViewController: UIViewController {
    
    @IBOutlet weak var otTextField: UITextField!
    @IBOutlet weak var nacenkaTextField: UITextField!
    @IBOutlet weak var doTextField: UITextField!
    @IBOutlet weak var fixNadbavkaTextField: UITextField!
    
    @IBOutlet weak var inRublesButton: UIButton!
    @IBOutlet weak var inPercentsButton: UIButton!
    
    @IBOutlet weak var otmenaButton: UIButton!
    @IBOutlet weak var sozdatButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var picker: UIPickerView!
    
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
        
        inRublesButton.addTarget(self, action: #selector(inRublesButtonTapped(_:)), for: .touchUpInside)
        inPercentsButton.addTarget(self, action: #selector(inPersentsButtonTapped(_:)), for: .touchUpInside)
        otmenaButton.addTarget(self, action: #selector(otmenaButtonTapped(_:)), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped(_:)), for: .touchUpInside)
        
        picker.delegate = self
        picker.dataSource = self
        
        picker.selectRow(1, inComponent: 0, animated: false)
        
        sozdatButton.layer.cornerRadius = 8
        
        inRublesButton.layer.cornerRadius = 8
        inPercentsButton.layer.cornerRadius = 8
        
        selectRubles()
        
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
            
        }
        
    }
    
    func selectPercents() {
        
        UIView.animate(withDuration: 0.3) { [self] in
            
            inPercentsButton.backgroundColor = .systemBlue
            inPercentsButton.setTitleColor(.white, for: .normal)
            
            inRublesButton.backgroundColor = .none
            inRublesButton.setTitleColor(.systemBlue, for: .normal)
            
        }
        
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
