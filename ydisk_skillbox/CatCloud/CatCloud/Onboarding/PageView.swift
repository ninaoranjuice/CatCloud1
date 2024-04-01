//
//  PageView.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 01.04.2024.
//

import UIKit
import SnapKit

protocol PageViewDelegate: AnyObject {
    func buttonTapped()
}

class PageView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let nextButton = UIButton(type: .roundedRect)
    
    weak var delegate: PageViewDelegate?
    
    init(frame: CGRect, page: OnboardingPage) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
        configure(with: page)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        descriptionLabel.textColor = .darkGray
        descriptionLabel.font = UIFont.systemFont(ofSize: 24)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        
        nextButton.setTitle("Далее", for: .normal)
        nextButton.setTitleColor(.blue, for: .normal)
        nextButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        nextButton.backgroundColor = .lightGray
        nextButton.layer.cornerRadius = 25
        nextButton.layer.masksToBounds = true
        addSubview(nextButton)
    }
    
    @objc private func buttonTapped() {
        delegate?.buttonTapped()
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(350)
            make.height.equalTo(350)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(400)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel).offset(50)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        nextButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(descriptionLabel).offset(100)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    private func configure(with page: OnboardingPage) {
        imageView.image = page.image
        titleLabel.text = page.title
        descriptionLabel.text = page.description
    }
}
