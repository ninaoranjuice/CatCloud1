//
//  NetworkConroller.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 07.06.2024.
//

import Foundation
import UIKit

class NetworkController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNetworkMonitoring()
    }
    
    func setupNetworkMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: .networkStatusChanged, object: nil)
        NetworkMonitor.shared.startMonitoring()
    }
    
    @objc func networkStatusChanged() {
        if !NetworkMonitor.shared.isConnected {
            showNetworkAlert()
            loadCachedData()
        } else {
            loadDataFromNet()
        }
    }
    
    func showNetworkAlert() {
        let alert = UIAlertController(title: "Network Status", message: "No internet connection", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadDataFromNet() {
    }
    
    func loadCachedData() {
    }
}
