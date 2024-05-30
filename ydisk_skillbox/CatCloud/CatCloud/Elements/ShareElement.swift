//
//  ShareElement.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 16.05.2024.
//

import Foundation
import UIKit
import SnapKit

class ShareElement: UIView {
    
    var linkLabel = UILabel()
    var copyButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        linkLabel.numberOfLines = 2
        linkLabel.text = Constants.Text.Elements.link
        linkLabel.lineBreakMode = .byTruncatingTail
        
        copyButton.setImage(UIImage(named: "doc_icon"), for: .normal)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        addSubview(linkLabel)
        addSubview(copyButton)
        
        backgroundColor = .systemPink
        
        linkLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview().offset(-10)
            make.trailing.equalToSuperview().offset(-70)
        }
        
        copyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func copyTapped() {
        guard let link = linkLabel.text, !link.isEmpty else {
            print("ошибка ссылки неть")
            return
        }
        UIPasteboard.general.string = link
        print("Ссылка скопирована! \(link)")
        self.isHidden = true
    }
    
    func setLink(_ link: String?) {
        linkLabel.text = link
    }
    
}
