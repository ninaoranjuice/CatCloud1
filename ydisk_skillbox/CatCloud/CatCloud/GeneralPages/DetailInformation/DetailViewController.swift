//
//  DetailViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 30.04.2024.
//

import UIKit
import SnapKit
import AlamofireImage
import Alamofire
import PDFKit
import WebKit
import CoreData

class DetailViewController: UIViewController {
    
    var request = DetailViewRequest()
    var information: Detail?
    
    var nameLabel = UILabel()
    var nameField = UILabel()
    var dateLabel = UILabel()
    var dateField = UILabel()
    var imageView = UIImageView()
    var stackView = UIStackView()
    var pdfView = PDFView()
    var webView = WKWebView()
    let loader = Loader(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Детальная информация"
        loadData()
        setUI()
        
    }
    
    private func setUI() {
        view.backgroundColor = .white
        
        nameLabel.text = "Название файла: "
        dateLabel.text = "Создан: "
        
        stackView.axis = .vertical
        
        view.addSubview(stackView)
        view.addSubview(pdfView)
        view.addSubview(webView)
        view.addSubview(imageView)
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(nameField)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(dateField)
        stackView.addArrangedSubview(loader)
        
        loader.isHidden = true
        imageView.isHidden = true
        pdfView.isHidden = true
        webView.isHidden = true
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().offset(10)
        }
        pdfView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(10)
        }
        webView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(10)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func loadData() {
        guard let file = information else {
            print("Ошибка. Не удалось получить информацию о файле.")
            return
        }
        
        request.loadDetailInformation(for: file) { [weak self] result in
            switch result {
            case .success(let (detail, data)):
                DispatchQueue.main.async {
                    SaveInfo.shared.saveFile(data, fileName: detail.name)
                    self?.updateUI(with: detail)
                }
            case .failure(let error):
                print("Ошибка загрузки детальной информации \(error)")
            }
        }
    }
    
    private func updateUI(with detail: Detail) {
        nameField.text = detail.name
        let date = detail.created
        dateField.text = request.formatDate(date)
     
        switch detail.mime_type {
        case "image/jpeg", "image/jpg", "image/png", "image/gif":
            if let imageData = SaveInfo.shared.getFileData(fileName: detail.name),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.imageView.isHidden = false
                    print("картинка загружена успешно.")
                }

            }
        case "application/pdf":
            if let pdfData = SaveInfo.shared.getFileData(fileName: detail.name),
               let document = PDFDocument(data: pdfData) {
                DispatchQueue.main.async {
                    self.pdfView.document = document
                    self.pdfView.isHidden = false
                    print("PDF загружен успешно.")
                }
            }
        case "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.ms-powerpoint", "application/vnd.openxmlformats-officedocument.presentationml.presentation", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
            if let fileData = SaveInfo.shared.getFileData(fileName: detail.name) {
                    let temporaryDirectory = FileManager.default.temporaryDirectory
                    let temporaryFile = temporaryDirectory.appendingPathComponent(detail.name)
                    try? fileData.write(to: temporaryFile)
                    webView.loadFileURL(temporaryFile, allowingReadAccessTo: temporaryDirectory)
                    webView.isHidden = false
                    print("документ загружен успешно.")
                }
        default:
            print("Неопознанный тип файла.")
            }
        loader.stopAnimating()
        loader.isHidden = true
    }
}

