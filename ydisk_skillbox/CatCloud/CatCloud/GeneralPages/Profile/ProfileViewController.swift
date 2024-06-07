//
//  GeneralViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 03.04.2024.
//

import UIKit
import SnapKit
import Toast_Swift

class ProfileViewController: NetworkController {
    
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
        title = Constants.Text.TapBarController.profile
        setUI()
        setConstraints()
        setupNetworkMonitoring()
        loadInfo()
    }
    
    private func setUI() {
        view.backgroundColor = .white
        
        diagramCircle = CircleChart(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        freeMemory.text = Constants.Text.Profile.freeMemory
        freeMemory.font = UIFont(name: "abosanova", size: 24)
        freeMemory.textColor = Constants.Colors.pink
        
        occupiedMemory.text = Constants.Text.Profile.usedMemory
        occupiedMemory.font = UIFont(name: "abosanova", size: 24)
        occupiedMemory.textColor = Constants.Colors.blue
        
        allMemory.text = "0"
        allMemory.font = UIFont(name: "abosanova", size: 24)
        allMemory.textColor = Constants.Colors.green
        
        publicButton.setTitle(Constants.Text.Profile.publicButtonHeader, for: .normal)
        publicButton.setTitleColor(Constants.Colors.button, for: .normal)
        publicButton.titleLabel?.font = UIFont(name: "abosanova", size: 24)
        publicButton.layer.borderWidth = 2.0
        publicButton.layer.borderColor = Constants.Colors.button.cgColor
        publicButton.backgroundColor = UIColor.clear
        publicButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        publicButton.addTarget(self, action: #selector(tapPublic), for: .touchUpInside)
        
        exitButton.setTitle(Constants.Text.Profile.exitButtonHeader, for: .normal)
        exitButton.titleLabel?.font = UIFont(name: "abosanova", size: 24)
        exitButton.setTitleColor(Constants.Colors.button, for: .normal)
        exitButton.layer.borderWidth = 2.0
        exitButton.layer.borderColor = Constants.Colors.button.cgColor
        exitButton.backgroundColor = UIColor.clear
        exitButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        exitButton.addTarget(self, action: #selector(tapExit), for: .touchUpInside)

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
        if !NetworkMonitor.shared.isConnected {
            self.view.makeToast(Constants.Text.Elements.noNetwork)
            loadCachedData()
        } else {
            loadDataFromNet()
        }
    }
    
    override func loadDataFromNet() {
        request.loadInformation { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let diagramma):
                    self?.updateUI(with: diagramma)
                    if let data = try? JSONEncoder().encode(diagramma) {
                        SaveInfo.shared.saveFile(data, fileName: "profileData")
                    }
                case .failure(let error):
                    print("Ошибка загрузки данных: \(error)")
                }
            }
        }
    }
    
    override func loadCachedData() {
        if let data = SaveInfo.shared.getFileData(fileName: "profileData"),
           let diagramma = try? JSONDecoder().decode(Diagramma.self, from: data) {
            updateUI(with: diagramma)
        } else {
            print("Ошибка загрузки данных из кэша. ")
        }
    }
    
    func updateUI(with diagramma: Diagramma) {
        DispatchQueue.main.async {
            self.freeMemory.text = "\(Constants.Text.Profile.diagrammaFree) \(self.toGB(chislo: diagramma.total_space)) \(Constants.Text.Profile.gb)"
            self.occupiedMemory.text = "\(Constants.Text.Profile.diagrammaUsed)\(self.toGB(chislo: diagramma.used_space)) \(Constants.Text.Profile.gb)"
            self.allMemory.text = "\(self.toGB(chislo: diagramma.total_space + diagramma.used_space)) \(Constants.Text.Profile.gb)"
            
            self.diagramCircle.updateCircleChart(usedMemory: CGFloat(diagramma.used_space), totalMemory: CGFloat(diagramma.total_space + diagramma.used_space))
        }
    }
    
    private func toGB(chislo: Int) -> Int {
        return chislo/1024/1024/1024
    }
    
    @objc func tapPublic() {
        let publicFilesController = PublicFilesController()
        let navigationController = UINavigationController(rootViewController: publicFilesController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func tapExit() {
        let alertController = UIAlertController(title: Constants.Text.Profile.alertExit, message: Constants.Text.Profile.alertMessage, preferredStyle: .alert)
       
        let yesButton = UIAlertAction(title: Constants.Text.Profile.alertYes, style: .default) {_ in
            self.request.logOut()
        }
            alertController.addAction(yesButton)
            
            let noButton = UIAlertAction(title: Constants.Text.Profile.alertCancel, style: .cancel, handler: nil)
            alertController.addAction(noButton)
            present(alertController, animated: true, completion: nil)
    }
}
