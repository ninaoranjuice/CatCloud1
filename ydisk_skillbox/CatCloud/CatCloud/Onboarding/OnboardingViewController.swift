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
        OnboardingPage(image: UIImage(named: "Onboarding1"), title: "Храни", description: "Теперь можно хранить все свои документы в одном месте"),
        OnboardingPage(image: UIImage(named: "Onboarding2"), title: "Открывай", description: "Доступ к файлам останется даже без интернета"),
        OnboardingPage(image: UIImage(named: "Onboarding3"), title: "Делись", description: "Делитесь вашими файлами с другими"),
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
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.center.equalToSuperview()
        }
    }
    
    private func addPages() {
        for (index, page) in pages.enumerated() {
            let pageView = PageView(frame: CGRect(x: view.frame.width * CGFloat(index), y: 0, width: view.frame.width, height: view.frame.height), page: page)
            pageView.delegate = self
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
}
