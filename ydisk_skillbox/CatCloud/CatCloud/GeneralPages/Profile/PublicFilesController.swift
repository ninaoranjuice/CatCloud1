//
//  PublicFilesController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 23.05.2024.
//

import Foundation
import UIKit
import SnapKit
import AlamofireImage
import Toast_Swift


class PublicFilesController: NetworkController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    var request = PublicFilesRequests()
    var information: [PublicFiles] = []
    var refreshControl = UIRefreshControl()
    var loadButton = UIButton(type: .infoLight)
    var offset = 0
    
    var onDeleteCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        title = Constants.Text.Profile.publicButtonHeader
        closeButton()
        setUI()
        loadPage(offset: offset)
    }
    
    private func closeButton() {
        let closeButton = UIBarButtonItem(title: Constants.Text.Profile.back, style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.tableFooterView = loadButton
        loadButton.setTitle(Constants.Text.Profile.loadMore, for: .normal)
        loadButton.setTitleColor(Constants.Colors.button, for: .normal)
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadPage(offset: Int) {
        if !NetworkMonitor.shared.isConnected {
            self.view.makeToast(Constants.Text.Elements.noNetwork)
            loadCachedData()
        } else {
            loadDataFromNet()
        }
    }
    
    @objc func loadButtonTapped() {
        self.offset += 10
        loadPage(offset: self.offset)
    }
    
    override func loadDataFromNet() {
        request.loadPublicFiles(offset: offset) { [weak self] (result: Result<[PublicFiles], Error>) in
            switch result {
            case .success (let items):
                self?.updateData(items)
                if let data = try? JSONEncoder().encode(items) {
                    SaveInfo.shared.saveFile(data, fileName: "publicFiles_offset_\(self?.offset ?? 0)")
                }
            case .failure(let error): print("Ошибка загрузки опубликованных файлов \(error.localizedDescription)")
            }
        }
    }
    
    override func loadCachedData() {
        let cacheKey = "publicFiles_offset_\(offset)"
        if let cachedData = SaveInfo.shared.getFileData(fileName: cacheKey),
           let items = try? JSONDecoder().decode([PublicFiles].self, from: cachedData) {
            updateData(items)
            print("Получены данные из кэша, успешно.")
        } else {
            print("Ошибка. Отсутствуют данные для данного запроса в кэше.")
        }
    }
    
    func updateData(_ items: [PublicFiles]) {
        print("Количество элементов в массиве information до обновления: \(information.count)")
        information.append(contentsOf: items)
        print("Количество элементов в массиве information после обновления: \(information.count)")
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func refreshData() {
        information.removeAll()
        offset = 0
        loadPage(offset: offset)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        guard indexPath.row < information.count else {
            print("Индекс за пределами.")
            return cell
        }
        let info = information[indexPath.row]
        cell.loader.startAnimating()
        
        cell.nameLabel.text = info.name
        cell.createdLabel.text = "\(Constants.Text.Profile.create) \(String(describing: request.formatDate(info.created)!))"
        cell.sizeLabel.text = "\(Constants.Text.Profile.size) \((info.size ?? 1) / 1024) \(Constants.Text.Profile.kb)"
        
        if let urlString = info.preview,
           let url = URL(string: urlString) {
            
            request.loadPreview(url: url, mime_type: info.mime_type) { image in
                DispatchQueue.main.async {
                    if let image = image {
                        cell.previewImage.image = image
                    } else {
                        cell.previewImage.image = UIImage(named: "unknown_icon")
                    }
                    cell.loader.stopAnimating()
                }
            }
        } else {
            print("Неверный адрес.")
            cell.previewImage.image = UIImage(named: "unknown_icon")
            cell.loader.stopAnimating()
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return information.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < information.count else {
            print("Ошибка, файл по индексу не найден.")
            return
        }
        
        let selectedFile = information[indexPath.row]
        
        if selectedFile.type == "dir" {
            guard let publicKey = selectedFile.public_key, let path = selectedFile.path else {
                print("Нет ключа для публикации или пути для выбранной папки.")
                return
            }
            request.loadContentsOfFolder(publicKey: publicKey, path: path, for: self) { [weak self] items in
                if let items = items, !items.isEmpty {
                    DispatchQueue.main.async {
                        self?.updateData(items)
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: Constants.Text.Profile.empty, message: Constants.Text.Profile.emptyMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: Constants.Text.Profile.ok, style: .default, handler: nil))
                        self!.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let selectedDetail = Detail(name: selectedFile.name, created: selectedFile.created, mime_type: selectedFile.mime_type ?? "unknown/unknown", path: selectedFile.path ?? "", file: selectedFile.file, href: selectedFile.href, public_url: selectedFile.public_url)
            let detailViewController = DetailViewController()
            detailViewController.information = selectedDetail
            detailViewController.onDeleteCompletion = { [weak self] in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            detailViewController.onRenameCompletion = { [weak self] in
                DispatchQueue.main.async {
                    self?.refreshData()
                    self?.tableView.reloadData()
                }
            }
            present(detailViewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedFile = information[indexPath.row]
            guard let path = selectedFile.path else {
                print("Нет пути для выбранного файла.")
                return
            }
            request.unpublic(path: path) { [weak self] error in
                if let error = error {
                    print("Ошибка \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self?.information.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
}
