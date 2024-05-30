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

class PublicFilesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        request.loadPublicFiles(for: self, offset: offset)
    }
    
    @objc func loadButtonTapped() {
        self.offset += 10
        loadPage(offset: self.offset)
    }
    
    func updateData(_ items: [PublicFiles]) {
        information.append(contentsOf: items)
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
                print("НЕТ КЛЮЧА публикации или пути для выбранной папки.")
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
}
