//
//  AllFilesViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 17.04.2024.
//

import UIKit
import SnapKit
import AlamofireImage

class AllFilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        title = "Все файлы"
        setUI()
        loadPage(offset: offset)
    }

    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.tableFooterView = loadButton
        loadButton.setTitle("Загрузить еще", for: .normal)
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadPage(offset: Int) {
        request.loadAllFiles(for: self, offset: offset)
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
        cell.createdLabel.text = "Создан: \(String(describing: request.formatDate(info.created)!))"
        cell.sizeLabel.text = "Размер: \((info.size) / 8 / 1024) КБ"
        
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
        print("ПОЛУЧИЛОСЬ СДЕЛАТЬ ЗАПРОС.")
        present(detailViewController, animated: true, completion: nil)
    }
}


