//
//  LastFilesViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 17.04.2024.
//

import UIKit
import SnapKit

class LastFilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var request = LastFilesRequests()
    var information = [Information]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let info = information[indexPath.row]
        cell.textLabel?.text = info.name
        cell.detailTextLabel?.text = "Создан: \(info.created)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return information.count
    }
}

