//
//  MasterViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.12.2020.
//

import Foundation

class MasterViewModel : ObservableObject{
    
    @Published var currentViewType : MasterViewType = .inputVal
    @Published var shouldShowBackButton = true
    
}
