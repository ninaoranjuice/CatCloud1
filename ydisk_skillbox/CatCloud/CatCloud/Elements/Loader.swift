//
//  Loader.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 18.04.2024.
//

import UIKit

class Loader: UIActivityIndicatorView {
    override init(style: UIActivityIndicatorView.Style) {
        super.init(style: style)
        color = .red
        frame = CGRect(x: 220, y: 220, width: 140, height: 140)
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
