//
//  CategorySelectionViewController.swift
//  quavi
//
//  Created by Mr Wonderful on 2/24/20.
//  Copyright © 2020 Sunni Tang. All rights reserved.
//

import UIKit

class CategorySelectionViewController: UIViewController {
    

    //MARK: -- Objects
    lazy var categoryCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView.register(CatergoryCollectionViewCell.self, forCellWithReuseIdentifier: Identifier.categoryCell.rawValue)
        collectionView.backgroundColor = UIDesign.quaviDarkGrey
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    //MARK: -- Internal Properties
//    let categories = Category.allCases
    var allTours = [Tour]() {
        didSet {
            categories = Array(Set(allTours.compactMap { (tour) -> String? in
                tour.category
                })).sorted()
        }
    }
    
    var categories = [String]() {
        didSet {
            // Better approach than reloading?
            categoryCollectionView.reloadData()
        }
    }
    
//    var categoryCount = [String:Int]()
    
    var layout = UICollectionViewFlowLayout.init()
    
    //MARK: -- LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAllTours()
        
    }
    //MARK: -- Private Methods
    private func loadAllTours() {
        DispatchQueue.main.async {
            FirestoreService.manager.getAllTours { (result) in
                switch result {
                case .failure(let error):
                    //TODO: Handle error
                    print(error)
                case .success(let allTours):
                    self.allTours = allTours
                    print("Number of tours loaded: \(allTours.count)")
                }
            }
        }
    }
    
    
    private func addSubviews(){
        view.addSubview(categoryCollectionView)
    }
    
    private func setupNavBar(){
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = UIDesign.quaviDarkGrey
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = "Tour Categories"
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIDesign.quaviWhite]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes

    }
}
