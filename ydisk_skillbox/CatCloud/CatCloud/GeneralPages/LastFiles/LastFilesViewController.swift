//
//  LastFilesViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 17.04.2024.
//

import UIKit
import SnapKit
import AlamofireImage

class LastFilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var request = LastFilesRequests()
    var information = [Information]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        title = "Последние файлы"
        setUI()
        request.loadLastFiles(for: self)
    }
    
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateData(_ informationArray: [Information]) {
        information = informationArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        let info = information[indexPath.row]
        print(info.mime_type)
        
        cell.nameLabel.text = info.name
        cell.createdLabel.text = "Создан: \(String(describing: formatDate(info.created)!))"
        cell.sizeLabel.text = "Размер: \((info.size) / 8 / 1024) КБ"
        
        let urlString = info.preview
        guard let url = URL(string: urlString!) else {
            print("Неверный адрес.")
            return cell
        }
        var request = URLRequest(url: url)
        if let accessToken = TokenManager.shared.accessToken {
            request.setValue("OAuth \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                print("Возникла ошибка \(error)")
                return
            }
            guard let data = data else {
                print("Не удалось получить данные")
                return
            }
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    cell.previewImage.image = image }
                print("Удалось установить картинку.")
            } else {
                print ("Что-то пошло не так...")
                let icon: UIImage
                switch info.mime_type {
                case "application/pdf": icon = UIImage(named: "doc_icon")!
                case "image/jpeg": icon = UIImage(named: "image_icon")!
                case "image/png": icon = UIImage(named: "image_icon")!
                case "image/gif": icon = UIImage(named: "image_icon")!
                case "application/msword": icon = UIImage(named: "doc_icon")!
                case "application/vnd.openxmlformats-officedocument.wordprocessingml.document": icon = UIImage(named: "doc_icon")!
                case "application/rtf": icon = UIImage(named: "doc_icon")!
                case "application/vnd.ms-powerpoint": icon = UIImage(named: "doc_icon")!
                case "application/vnd.openxmlformats-officedocument.presentationml.presentation": icon = UIImage(named: "ppt_icon")!
                case "application/vnd.ms-excel": icon = UIImage(named: "doc_icon")!
                case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": icon = UIImage(named: "doc_icon")!
                default: icon = UIImage(named: "unknown_icon")!
                }
                DispatchQueue.main.async {
                    cell.previewImage.image = icon
                }
            }
        }
            task.resume()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return information.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func formatDate(_ dateS: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let date = dateFormatter.date(from: dateS) {
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
}

