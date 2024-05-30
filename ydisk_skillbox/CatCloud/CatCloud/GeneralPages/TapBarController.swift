//
//  TapBarController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 17.04.2024.
//

import UIKit

class TapBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstVC = ProfileViewController()
        firstVC.tabBarItem = UITabBarItem(title: Constants.Text.TapBarController.profile, image: UIImage(systemName: "person"), tag: 0)
        let secondVC = LastFilesViewController()
        secondVC.tabBarItem = UITabBarItem(title: Constants.Text.TapBarController.lastFile, image: UIImage(systemName: "doc"), tag: 1)
        let thirdVC = AllFilesViewController()
        thirdVC.tabBarItem = UITabBarItem(title: Constants.Text.TapBarController.allFile, image: UIImage(systemName: "tray.full"), tag: 2)
        
        viewControllers = [firstVC, secondVC, thirdVC]
    }
}
