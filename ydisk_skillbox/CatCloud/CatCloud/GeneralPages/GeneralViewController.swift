//
//  GeneralViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 03.04.2024.
//

import UIKit
import SnapKit

class GeneralViewController: UIViewController {
    
    let image = UIImageView(image: UIImage(named: "Logo"))
    let text = UILabel()
    let stackView = UIStackView()
    let registrationButton = UIButton(type: .roundedRect)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        setUI()
    }
    
    private func setUI() {
        view.backgroundColor = .white

        text.textColor = .blue
        text.text = "CATCLOUD"
        text.font = .boldSystemFont(ofSize: 40)

        image.contentMode = .scaleAspectFit
        
        registrationButton.setTitle("Страница с тапбаром тут", for: .normal)
        registrationButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 30
        
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(text)
        stackView.addArrangedSubview(registrationButton)
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.trailing.equalToSuperview().inset(50)
        }
    }
    
    @objc private func register() {
        
     }
}



