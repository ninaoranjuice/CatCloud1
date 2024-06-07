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
        color = Constants.Colors.logo
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
