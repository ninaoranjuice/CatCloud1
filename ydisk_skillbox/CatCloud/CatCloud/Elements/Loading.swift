//
//  Loading.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 31.05.2024.
//

import Foundation
import UIKit
import SnapKit

class Loading: UIView {
    
    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = Constants.Text.Elements.loading
        textLabel.textColor = .black
        textLabel.font = UIFont(name: "abosanova", size: 20)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
        addSubview(textLabel)
        
        textLabel.snp.makeConstraints {
            make in
            make.centerX.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}
