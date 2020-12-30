//
//  MultilineTextView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 30.12.2020.
//

import SwiftUI

struct MultilineTextView: UIViewRepresentable {
    
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        
        let view = UITextView()
        
        view.isScrollEnabled = false
        
        view.isEditable = true
        
        view.isUserInteractionEnabled = true
        
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
