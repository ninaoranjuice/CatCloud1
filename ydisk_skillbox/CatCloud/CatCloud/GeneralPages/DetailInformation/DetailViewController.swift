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
    var onDeleteCompletion: (() -> Void)?
    var onRenameCompletion: (() -> Void)?
    
    var shareElement = ShareElement()
    
    var nameLabel = UILabel()
    var dateLabel = UILabel()
    var imageView = UIImageView()
    var pdfView = PDFView()
    var webView = WKWebView()
    let loader = Loader(style: .large)
    
    let sendButton = UIButton(type: .system)
    let shareButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)
    let renameButton = UIButton(type: .system)
    
    let buttonContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Детальная информация"
        loadData()
        setUI()
        setConstraints()
        
    }
    
    private func setUI() {
        view.backgroundColor = .systemGray
        
        nameLabel.text = "Название файла: "
        nameLabel.font = UIFont(name: "abosanovabold", size: 24)
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.textAlignment = .center
        
        dateLabel.text = "Создан: "
        dateLabel.font = UIFont(name: "abosanova", size: 24)
        
        sendButton.setImage(UIImage(named: "send"), for: .normal)
        shareButton.setImage(UIImage(named: "share"), for: .normal)
        deleteButton.setImage(UIImage(named: "delete"), for: .normal)
        renameButton.setImage(UIImage(named: "rename"), for: .normal)
        
        sendButton.addTarget(self, action: #selector(tapSendButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(tapShareButton), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(tapDeleteButton), for: .touchUpInside)
        renameButton.addTarget(self, action: #selector(tapRenameButton), for: .touchUpInside)
        
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 34)
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 34)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 34)
        renameButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        
        sendButton.tintColor = .white
        shareButton.tintColor = .white
        deleteButton.tintColor = .white
        renameButton.tintColor = .white
        
        imageView.contentMode = .scaleAspectFit
        pdfView.autoScales = true
        pdfView.backgroundColor = .clear
        pdfView.alpha = 1.0
        
        buttonContainer.backgroundColor = .clear
        
        buttonContainer.addSubview(shareButton)
        buttonContainer.addSubview(sendButton)
        buttonContainer.addSubview(deleteButton)
        
        view.addSubview(pdfView)
        view.addSubview(webView)
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(dateLabel)
        view.addSubview(loader)
        view.addSubview(renameButton)
        view.addSubview(buttonContainer)
        view.addSubview(shareElement)
        
        loader.isHidden = true
        imageView.isHidden = true
        pdfView.isHidden = true
        webView.isHidden = true
        buttonContainer.isHidden = true
        renameButton.isHidden = true
        shareElement.isHidden = true
        
    }
    
    private func setConstraints() {
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
        
        pdfView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.bottom.equalTo(buttonContainer.snp.top).offset(-10)
        }
        
        webView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.bottom.equalTo(buttonContainer.snp.top).offset(-10)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.bottom.equalTo(buttonContainer.snp.top).offset(-10)
        }
        
        loader.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        buttonContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(70)
        }
        
        sendButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
        }
        
        shareButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
        }
        
        renameButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(35)
        }
        
        shareElement.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
    }
    
    private func loadData() {
        guard let file = information else {
            print("Ошибка. Не удалось получить информацию о файле.")
            return
        }
        
        if SaveInfo.shared.getFileData(fileName: file.name) != nil {
            let detail = Detail(name: file.name, created: file.created, mime_type: file.mime_type, path: file.path, file: file.file, href: file.href, public_url: file.public_url)
            updateUI(with: detail)
        } else {
            DispatchQueue.main.async {
                self.loader.isHidden = false
                self.loader.startAnimating()
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
        
        DispatchQueue.main.async {
            self.nameLabel.text = detail.name
            let date = detail.created
            self.dateLabel.text = self.request.formatDate(date)
        }
        
        switch detail.mime_type {
        case "image/jpeg", "image/jpg", "image/png", "image/gif":
            if let imageData = SaveInfo.shared.getFileData(fileName: detail.name),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.loader.isHidden = true
                    self.loader.stopAnimating()
                    self.imageView.image = image
                    self.imageView.isHidden = false
                    print("картинка загружена успешно.")
                    self.loadButtons()
                }
            }
        case "application/pdf":
            if let pdfData = SaveInfo.shared.getFileData(fileName: detail.name),
               let document = PDFDocument(data: pdfData) {
                DispatchQueue.main.async {
                    self.loader.isHidden = true
                    self.loader.stopAnimating()
                    self.pdfView.document = document
                    self.pdfView.isHidden = false
                    print("PDF загружен успешно.")
                    self.loadButtons()
                }
            }
        case "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.ms-powerpoint", "application/vnd.openxmlformats-officedocument.presentationml.presentation", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
            if let fileData = SaveInfo.shared.getFileData(fileName: detail.name) {
                let temporaryDirectory = FileManager.default.temporaryDirectory
                let temporaryFile = temporaryDirectory.appendingPathComponent(detail.name)
                try? fileData.write(to: temporaryFile)
                DispatchQueue.main.async {
                    self.loader.isHidden = true
                    self.loader.stopAnimating()
                    self.webView.loadFileURL(temporaryFile, allowingReadAccessTo: temporaryDirectory)
                    self.webView.isHidden = false
                    self.loadButtons()
                }
                print("документ загружен успешно.")
            }
        default:
            print("Неопознанный тип файла.")
            DispatchQueue.main.async {
                self.loader.isHidden = true
                self.loader.stopAnimating()
                self.loadButtons()
            }
        }
    }
    
    private func loadButtons() {
        DispatchQueue.main.async {
            self.buttonContainer.isHidden = false
            self.renameButton.isHidden = false
        }
    }
    
    @objc func tapSendButton() {
        request.getALink(detail: information!) { result in
             DispatchQueue.main.async {
                 switch result {
                 case .success(let publicUrl):
                     self.showShareSheet(with: publicUrl)
                 case .failure(let error):
                     print("Ошибка при получении публичной ссылки: \(error.localizedDescription)")
                 }
             }
         }
     }

     func showShareSheet(with publicUrl: String) {
         let activityViewController = UIActivityViewController(activityItems: [URL(string: publicUrl)!], applicationActivities: nil)
         if let popoverPresentationController = activityViewController.popoverPresentationController {
             popoverPresentationController.sourceView = self.view
             popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
             popoverPresentationController.permittedArrowDirections = []
         }
         present(activityViewController, animated: true, completion: nil)
     }
    
    @objc func tapShareButton() {
        request.getALink(detail: information!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let publicUrl):
                        self.shareElement.setLink(publicUrl)
                        self.shareElement.isHidden = false
                case .failure(let error):
                    print("Ошибка при получении публичной ссылки: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func tapDeleteButton() {
        let alertController = UIAlertController(title: "Внимание!", message: "Вы собираетесь удалить файл.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Oк", style: .default) { [weak self] _ in
            self?.request.deleteFile(detail: self!.information!)
            let secondAlertController = UIAlertController(title: "Успешно.", message: "Файл был успешно удален.", preferredStyle: .alert)
            let okActionSecond = UIAlertAction(title: "OK", style: .default) { _ in
                DispatchQueue.main.async {
                    self?.onDeleteCompletion?()
                    self?.dismiss(animated: true, completion: nil)
                }
            }
            secondAlertController.addAction(okActionSecond)
            DispatchQueue.main.async {
                self?.present(secondAlertController, animated: true, completion: nil)
            }
        }
        alertController.addAction(okAction)
        let noAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func tapRenameButton() {
        let alertController = UIAlertController(title: "Переименовать файл", message: "Введите новое имя файла", preferredStyle: .alert)
        alertController.addTextField { text in
            text.placeholder = "Новое имя"
        }
        let saveButton = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let newName = alertController.textFields?.first?.text, !newName.isEmpty else {
                print("Пользователь не ввел ничего.")
                return
            }
            self?.request.renameFile(detail: (self?.information!)!, name: newName) { success in
                if success {
                    DispatchQueue.main.async {
                        SaveInfo.shared.updateName(oldName: self!.information!.name, newName: newName)
                        self?.onRenameCompletion?()
                        self?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("Возникла ошибка при переименовании файла.")
                }
            }
        }
        alertController.addAction(saveButton)
        
        let cancel = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
}
