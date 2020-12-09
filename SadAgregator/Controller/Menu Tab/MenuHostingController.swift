//
//  MenuHostingController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.12.2020.
//

import UIKit
import SwiftUI

class MenuHostingController: UIHostingController<MenuView>{
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder, rootView: MenuView())
    }

}

