//
//  DatePickerViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.04.2021.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var picker: UIDatePicker!
    
    @IBOutlet weak var selectButton: UIButton!
    
    var dateSelected : ((Date) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectButton.layer.cornerRadius = 8
        picker.datePickerMode = .date
        
    }
    
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        dateSelected?(picker.date)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
