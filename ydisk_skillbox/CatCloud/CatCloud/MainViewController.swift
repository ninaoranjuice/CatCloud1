//
//  MainViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 29.03.2024.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    let image = UIImageView(image: UIImage(named: "Logo"))
    let text = UILabel()
    let stackView = UIStackView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        view.backgroundColor = .white
        
        text.textColor = .red
        text.text = "CATCLOUD"
        
        image.contentMode = .scaleAspectFit
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 30
        
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(text)
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.trailing.equalToSuperview().inset(50)
        }
    }
}


