//
//  onBoardingViewController.swift
//  quavi
//
//  Created by Mr Wonderful on 2/21/20.
//  Copyright © 2020 Sunni Tang. All rights reserved.
//

import UIKit

class onBoardingViewController: UIViewController {
    //MARK:-- Objects
    lazy var onBoardingScrollView: OnBoarding = {
        let scrollView = OnBoarding()
        scrollView.backgroundColor = .clear
        scrollView.dataSource = self
        return scrollView
    }()
    
    //MARK:-- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureScrollViewConstraints()
    }
    //MARK: -- private func
    
    private func addSubView(){
        view.addSubview(onBoardingScrollView)
    }
    
    private func configureScrollViewConstraints(){
        onBoardingScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([onBoardingScrollView.topAnchor.constraint(equalTo: view.topAnchor), onBoardingScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor), onBoardingScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor) ,onBoardingScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
}

extension onBoardingViewController: QuaviOnBoardingDataSource{
    func quaviOnboardBackgroundColorFor(_ quickGrubOnBoarding: OnBoarding, atIndex index: Int) -> UIColor? {
        
        //TODO: set background color dynamically
        switch index{
        case 0:
            return .white
        case 1:
            return .blue
        case 2:
            return .yellow
        case 3:
            return .green
        default:
            return .white
        }
    }
    
    func quaviOnboardNumberOfPages(_ quickGrubOnBoarding: OnBoarding) -> Int {
        return 4
    }
    
    func quaviOnboardPageForIndex(_ quickGrubOnBoarding: OnBoarding, index: Int) -> QuaviOnBoardingPage? {
        let page = QuaviOnBoardingPage()
        
        //TODO: Set information to each onboarding page here
        return page
    }
    
}
