//
//  Cell.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 19.04.2024.
//

import UIKit
import SnapKit
import AlamofireImage

class CustomCell: UITableViewCell {
    var nameLabel = UILabel()
    var previewImage = UIImageView()
    var createdLabel = UILabel()
    var sizeLabel = UILabel()
    let loader = Loader(style: .large)
    
    let cell = "Cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(previewImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(createdLabel)
        contentView.addSubview(sizeLabel)
        loader.hidesWhenStopped = true
        contentView.addSubview(loader)
        
        nameLabel.font = UIFont(name: "abosanova", size: 20)
        createdLabel.font = UIFont(name: "abosanova", size: 20)
        sizeLabel.font = UIFont(name: "abosanova", size: 20)
        
        loader.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(previewImage).offset(10)
        }
        
        previewImage.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(previewImage.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        createdLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalTo(previewImage.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        sizeLabel.snp.makeConstraints { make in
            make.top.equalTo(createdLabel.snp.bottom).offset(5)
            make.leading.equalTo(previewImage.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().inset(10)
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

    
    

