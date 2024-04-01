//
//  ViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 28.03.2024.
//

import UIKit
import SnapKit

class StartViewController: UIViewController {
    
    let image = UIImageView(image: UIImage(named: "Logo"))
    let text = UILabel()
    let stackView = UIStackView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
               image.isUserInteractionEnabled = true
               image.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUI() {
        view.backgroundColor = .white

        text.textColor = .blue
        text.text = "CATCLOUD"
        text.font = .boldSystemFont(ofSize: 40)
        
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
    
    @objc private func imageTapped() {
        let onboardingViewController = OnboardingViewController()
        present(onboardingViewController, animated: true, completion: nil)
    }
}

