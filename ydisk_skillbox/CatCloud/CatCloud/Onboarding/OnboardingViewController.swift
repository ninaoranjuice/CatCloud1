//
//  OnboardingViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 01.04.2024.
//

import Foundation
import UIKit

class OnboardingViewController: UIViewController {
    let scrollView = UIScrollView()
    let pageControl = UIPageControl()
    
    let pages = [
        OnboardingPage(image: UIImage(named: "Onboarding1"), title: Constants.Text.Onboarding.firstName, description: Constants.Text.Onboarding.firstMessage),
        OnboardingPage(image: UIImage(named: "Onboarding2"), title: Constants.Text.Onboarding.secondName, description: Constants.Text.Onboarding.secondMessage),
        OnboardingPage(image: UIImage(named: "Onboarding3"), title: Constants.Text.Onboarding.thirdName, description: Constants.Text.Onboarding.thirdMessage),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupPageControl()
        addPages()
    }
    
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(pages.count), height: view.frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        view.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    private func addPages() {
        for (index, page) in pages.enumerated() {
            let pageView = PageView(frame: CGRect(x: scrollView.bounds.width * CGFloat(index), y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height), page: page)
            pageView.delegate = self
            pageView.index = index
            pageView.totalPages = pages.count
            scrollView.addSubview(pageView)
        }
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}

extension OnboardingViewController: PageViewDelegate {
    func buttonTapped() {
        let nextPage = min(pageControl.currentPage + 1, pages.count - 1)
        let xOffset = CGFloat(nextPage) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
    }
    
    func closeTapped() {
    sleep(1)
       let mainViewController = MainViewController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainViewController
        }
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
