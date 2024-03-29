//
//  ThirdOnboarding.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 29.03.2024.
//

import UIKit
import SnapKit

class ThirdOnboarding: UIViewController {
    
    let image = UIImageView(image: UIImage(named: "Onboarding3"))
    let text = UILabel()
    let button = UIButton(type: .system)
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        view.backgroundColor = .white

        text.textColor = .blue
        text.text = "Делитесь вашими файлами с другими"
        text.numberOfLines = 0
        
        image.contentMode = .scaleAspectFit
        
        button.setTitle("Далее", for: .normal)
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 30
        
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(text)
        stackView.addArrangedSubview(button)
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.trailing.equalToSuperview().inset(50)
        }
    }
    
    @objc func tapButton() {
        present(MainViewController(), animated: true, completion: nil)
    }
}
