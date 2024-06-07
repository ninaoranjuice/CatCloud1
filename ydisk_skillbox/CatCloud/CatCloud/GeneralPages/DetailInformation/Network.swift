//
//  Network.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 02.06.2024.
//

import Foundation
import UIKit
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private var monitor: NWPathMonitor?
    private var isMonitoring = false
    var isConnected: Bool {
        return monitor?.currentPath.status == .satisfied
    }
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        monitor?.pathUpdateHandler = { path in
            if path.status == .unsatisfied {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: queue)
        isMonitoring = true
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        monitor?.cancel()
        isMonitoring = false
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
