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
            loadCachedData()
        } else {
            loadDataFromNet()
        }
    }
    
    func loadDataFromNet() {
    }
    
    func loadCachedData() {
    }
}
