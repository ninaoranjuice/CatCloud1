//
//  GeneralViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 03.04.2024.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    
    var request = ProfileRequests()
    
    let exitButton = UIButton(type: .system)
    let publicButton = UIButton(type: .system)
    let freeMemory = UILabel()
    let occupiedMemory = UILabel()
    var diagramCircle = CircleChart()
    let allMemory = UILabel()
    var diagramma: Diagramma?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        setUI()
        setConstraints()
        loadInfo()
    }
    
    private func setUI() {
        view.backgroundColor = .white
        
        diagramCircle = CircleChart(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        freeMemory.text = "Свободно памяти: "
        freeMemory.font = UIFont(name: "abosanova", size: 24)
        freeMemory.textColor = .systemPink
        
        occupiedMemory.text = "Занято памяти: "
        occupiedMemory.font = UIFont(name: "abosanova", size: 24)
        occupiedMemory.textColor = .systemBlue
        
        allMemory.text = "0"
        allMemory.font = UIFont(name: "abosanova", size: 24)
        allMemory.textColor = .green
        
        publicButton.setTitle("Опубликованные файлы", for: .normal)
        publicButton.setTitleColor(.black, for: .normal)
        publicButton.titleLabel?.font = UIFont(name: "abosanova", size: 24)
        publicButton.layer.borderWidth = 2.0
        publicButton.layer.borderColor = UIColor.black.cgColor
        publicButton.backgroundColor = UIColor.clear
        publicButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)


        exitButton.setTitle("Выйти", for: .normal)
        exitButton.titleLabel?.font = UIFont(name: "abosanova", size: 24)
        exitButton.setTitleColor(.black, for: .normal)
        exitButton.layer.borderWidth = 2.0
        exitButton.layer.borderColor = UIColor.black.cgColor
        exitButton.backgroundColor = UIColor.clear
        exitButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)


        
        view.addSubview(diagramCircle)
        view.addSubview(allMemory)
        view.addSubview(freeMemory)
        view.addSubview(occupiedMemory)
        view.addSubview(publicButton)
        view.addSubview(exitButton)

    }
    
    private func setConstraints() {
        
        diagramCircle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(100)
        }
        
        allMemory.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(diagramCircle).offset(100)
        }
        
        freeMemory.snp.makeConstraints { make in
            make.top.equalTo(diagramCircle).offset(300)
            make.leading.equalToSuperview().offset(20)
        }
        
        occupiedMemory.snp.makeConstraints { make in
            make.top.equalTo(freeMemory.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        exitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(publicButton.snp.bottom).offset(20)
            make.height.equalTo(50)
        }
        
        publicButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(occupiedMemory.snp.bottom).offset(50)
            make.height.equalTo(50)
        }
    }
    
    private func loadInfo() {
        request.loadInformation { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let diagramma):
                    self.updateUI(with: diagramma)
                case .failure(let error):
                    print("Ошибка загрузки данных: \(error)")
                }
            }
        }
    }
    
    func updateUI(with diagramma: Diagramma) {
        DispatchQueue.main.async {
            self.freeMemory.text = "Свободно памяти: \(self.toMB(chislo: diagramma.total_space)) MB"
            self.occupiedMemory.text = "Занято памяти: \(self.toMB(chislo: diagramma.used_space)) MB"
            self.allMemory.text = "\(self.toMB(chislo: diagramma.total_space + diagramma.used_space)) MB"
            
            self.diagramCircle.updateCircleChart(usedMemory: CGFloat(diagramma.used_space), totalMemory: CGFloat(diagramma.total_space + diagramma.used_space))
        }
    }
    
    private func toMB(chislo: Int) -> Int {
        return chislo/8/1024/1024
    }
}



