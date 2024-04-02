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
    func closeTapped()
}

class PageView: UIView {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let nextButton = UIButton(type: .roundedRect)
    let closeButton = UIButton()
    var index: Int?
    var totalPages: Int?
    
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
        
        closeButton.setImage(UIImage(named: "Exit"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)
    }
        
    @objc private func closeTapped() {
        delegate?.closeTapped()
        }
    
    @objc private func buttonTapped() {
        delegate?.buttonTapped()
        if let index = index, let totalPages = totalPages, index == totalPages - 1 {
            delegate?.closeTapped()
        }
    }
    
private func setupConstraints() {
    imageView.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.top.equalToSuperview().offset(60)
        make.width.equalTo(300)
        make.height.equalTo(300)
    }
    titleLabel.snp.makeConstraints { make in
        make.top.equalTo(imageView).offset(360)
        make.leading.equalToSuperview().offset(20)
        make.trailing.equalToSuperview().offset(-20)
    }
    descriptionLabel.snp.makeConstraints { make in
        make.top.equalTo(titleLabel).offset(60)
        make.leading.equalToSuperview().offset(20)
        make.trailing.equalToSuperview().offset(-20)
    }
    nextButton.snp.makeConstraints { make in
        make.leading.equalToSuperview().offset(20)
        make.trailing.equalToSuperview().offset(-20)
        make.top.equalTo(descriptionLabel).offset(120)
        make.width.equalTo(180)
        make.height.equalTo(60)
    }
    
    closeButton.snp.makeConstraints { make in
        make.top.equalToSuperview().offset(60)
        make.trailing.equalToSuperview().offset(-20)
        make.width.height.equalTo(50)
    }
}
    
     func configure(with page: OnboardingPage) {
        imageView.image = page.image
        titleLabel.text = page.title
        descriptionLabel.text = page.description
    }
}
