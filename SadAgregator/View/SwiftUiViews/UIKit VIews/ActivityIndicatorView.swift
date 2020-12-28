//
//  ActivityIndicatorView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.12.2020.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
    
}
