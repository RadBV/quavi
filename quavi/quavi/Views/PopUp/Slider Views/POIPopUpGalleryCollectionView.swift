//
//  POIPopUpGalleryCollectionView.swift
//  quavi
//
//  Created by Alex 6.1 on 3/3/20.
//  Copyright © 2020 Sunni Tang. All rights reserved.
//

import UIKit

class POIPopUpGalleryCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        register(POIPopUpGalleryCollectionViewCell.self, forCellWithReuseIdentifier: POIPopUpGalleryCollectionViewCell.reuseID)
        backgroundColor = .clear
    }
    
}
