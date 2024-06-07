//
//  AllFilesViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 17.04.2024.
//

import UIKit
import SnapKit
import AlamofireImage

class AllFilesViewController: NetworkController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    var request = AllFilesRequests()
    var information = [Info]()
    var loadButton = UIButton(type: .infoLight)
    var offset = 0
    var refreshControl = UIRefreshControl()
    
    var onDeleteCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        title = Constants.Text.TapBarController.allFile
        setUI()
        loadPage(offset: offset)
    }
    
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.tableFooterView = loadButton
        loadButton.setTitle(Constants.Text.Profile.loadMore, for: .normal)
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadPage(offset: Int) {
        if NetworkMonitor.shared.isConnected {
            loadDataFromNet()
        } else {
            loadCachedData()
        }
    }
    
    override func loadDataFromNet() {
        request.loadAllFiles(offset: offset) { [weak self] (result: Result<[Info], Error>) in
            switch result {
            case .success (let items):
                self?.updateData(items)
                if let data = try? JSONEncoder().encode(items) {
                    SaveInfo.shared.saveFile(data, fileName: "allFiles_offset_\(self?.offset ?? 0)")
                }
            case .failure(let error): print("Ошибка загрузки публичных файлов \(error.localizedDescription)")
            }
        }
    }
    
    override func loadCachedData() {
        let cacheKey = "allFiles_offset_\(offset)"
        if let cachedData = SaveInfo.shared.getFileData(fileName: cacheKey),
           let items = try? JSONDecoder().decode([Info].self, from: cachedData) {
            updateData(items)
            print("Получены данные из кэша, успешно.")
        } else {
            print("Ошибка. Отсутствуют данные для данного запроса в кэше.")
        }
    }
    
    @objc func loadButtonTapped() {
        self.offset += 10
        loadPage(offset: self.offset)
    }
    
    func updateData(_ informationArray: [Info]) {
        information.append(contentsOf: informationArray)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func refreshData() {
        information.removeAll()
        loadPage(offset: 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        guard indexPath.row < information.count else {
            print("Индекс за пределами.")
            return cell
        }
        let info = information[indexPath.row]
        print(info.mime_type)
        cell.loader.startAnimating()
        
        cell.nameLabel.text = info.name
        cell.createdLabel.text = "\(Constants.Text.Profile.create) \(String(describing: request.formatDate(info.created)!))"
        cell.sizeLabel.text = "\(Constants.Text.Profile.size) \((info.size) / 8 / 1024) \(Constants.Text.Profile.kb)"
        
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
        print("Selected row at index: \(indexPath.row)")
        guard indexPath.row < information.count else {
            print("Ошибка, файл по индексу не найден.")
            return
        }
        let selectedFile = information[indexPath.row]
        
        if selectedFile.type == "dir" {
            
            request.loadContentsOfFolder(path: selectedFile.path, for: self) { [weak self] items in
                if let items = items, !items.isEmpty {
                    DispatchQueue.main.async {
                        self?.information = items
                        self?.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Пустая папка", message: "В выбранной папке нет файлов.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let selectedDetail = Detail(name: selectedFile.name, created: selectedFile.created, mime_type: selectedFile.mime_type, path: selectedFile.path, file: selectedFile.file, href: selectedFile.href, public_url: selectedFile.public_url)
            let detailViewController = DetailViewController()
            detailViewController.information = selectedDetail
            detailViewController.onDeleteCompletion = { [weak self] in
                DispatchQueue.main.async {
                    self?.refreshData()
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
}

