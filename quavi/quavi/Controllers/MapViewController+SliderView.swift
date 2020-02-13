//
//  MapViewController+SliderView.swift
//  quavi
//
//  Created by Alex 6.1 on 2/11/20.
//  Copyright © 2020 Sunni Tang. All rights reserved.
//

import UIKit

extension MapViewController {
    
    func handleCollectionViewCellPressed(item: Int) {
        if item == 0 {
            currentSelectedCategory = Enums.categories.History.rawValue
        } else if item == 1 {
            currentSelectedCategory = Enums.categories.Art.rawValue
        } else if item == 2 {
            currentSelectedCategory = Enums.categories.Science.rawValue
        } else if item == 3 {
            currentSelectedCategory = Enums.categories.Religion.rawValue
        } else if item == 4 {
            currentSelectedCategory = Enums.categories.Yeet.rawValue
        }
    }
    
    func loadGestures() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeDown.direction = .down
        self.sliderView.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.sliderView.addGestureRecognizer(swipeUp)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        self.chevronArrows.addGestureRecognizer(tap)
    }
    
    func directionOfChevron(state: Enums.sliderViewStates) {
        
        switch state {
        case .halfOpen:
            self.chevronArrows.image = UIImage(systemName: "minus")
        case .fullOpen:
            self.chevronArrows.image = UIImage(systemName: "chevron.compact.down")
        case .closed:
            self.chevronArrows.image = UIImage(systemName: "chevron.compact.up")
        }
    }
    
    
    //MARK: -OBJ-C FUNCTIONS
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        print(gesture)
        
        if let tapGesture = gesture as? UITapGestureRecognizer {
            print("tapped")
            switch tapGesture.numberOfTouches {
            case 1:
                sliderViewState = .halfOpen
                
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.80, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [weak self] in
                    self?.setHalfOpenSliderViewConstraints()
                    self?.directionOfChevron(state: .halfOpen)
                    self?.view.layoutIfNeeded()
                    self?.sliderView.alpha = 1.0
                    self?.poiTableView.alpha = 1.0
                    self?.categoriesCollectionView.alpha = 1.0
                    }, completion: nil)
            default:
                print("dunno know")
            }
            
        }
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
                
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.80, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [weak self] in
                    
                    switch self?.sliderViewState {
                    case .fullOpen:
                        self?.setHalfOpenSliderViewConstraints()
                        self?.sliderViewState = .halfOpen
                    case .halfOpen:
                        self?.setClosedSliderViewConstraints()
                        self?.sliderViewState = .closed
                    case .closed:
                        print("it's already closed")
                    case .none:
                        return
                    }
                    
                    if self?.sliderViewState == .closed {
                        self?.directionOfChevron(state: .closed)
                    } else if self?.sliderViewState == .halfOpen {
                        self?.directionOfChevron(state: .halfOpen)
                    } else if self?.sliderViewState == .fullOpen {
                        self?.directionOfChevron(state: .fullOpen)
                    }
                    self?.view.layoutIfNeeded()
                    
                    if self?.sliderViewState == .closed {
                        self?.poiTableView.alpha = 0
                    }
                    
                    }, completion: nil)
                
            case UISwipeGestureRecognizer.Direction.up:
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.80, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [weak self] in
                    
                    switch self?.sliderViewState {
                    case .fullOpen:
                        print("it's fully opened")
                    case .halfOpen:
                        self?.setFullOpenSliderViewConstraints()
                        self?.sliderViewState = .fullOpen
                    case .closed:
                        self?.setHalfOpenSliderViewConstraints()
                        self?.sliderViewState = .halfOpen
                    case .none:
                        return
                    }
                    
                    if self?.sliderViewState == .closed {
                        self?.directionOfChevron(state: .closed)
                    } else if self?.sliderViewState == .halfOpen {
                        self?.directionOfChevron(state: .halfOpen)
                    } else if self?.sliderViewState == .fullOpen {
                        self?.directionOfChevron(state: .fullOpen)
                    }
                    self?.view.layoutIfNeeded()
                    
                    self?.sliderView.alpha = 1.0
                    self?.poiTableView.alpha = 1.0
                    self?.categoriesCollectionView.alpha = 1.0
                    }, completion: nil)
                
            default:
                break
            }
        }
    }
    
    @objc func tvCellSectionButtonPressed(sender: UIButton) {
        print(sender.tag)
        if sampleData[sender.tag].isCellExpanded {
            sampleData[sender.tag].isCellExpanded = false
        } else {
            sampleData[sender.tag].isCellExpanded = true
        }
        let incides: IndexSet = [sender.tag]
        poiTableView.reloadSections(incides, with: .fade)
    }
}

//MARK: -EXT. TABLEVIEW DELEGATE & DATASOURCE
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sampleData[section].isCellExpanded == false { return 0 } else { return 1 }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return sampleData.count }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if currentSelectedCategory == Enums.categories.History.rawValue {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
            
            //TO-DO: SEPERATE INTO IT'S OWN FILE
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
            button.setTitle(sampleData[section].name, for: .normal)
            button.backgroundColor = .yellow
            button.addTarget(self, action: #selector(tvCellSectionButtonPressed(sender:)), for: .touchDown)
            button.setTitleColor(.black, for: .normal)
            button.tag = section
            view.addSubview(button)
            
            view.backgroundColor = .gray
            return view
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 50 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stop = sampleData[indexPath.section]
        
        guard let cell = poiTableView.dequeueReusableCell(withIdentifier: Enums.cellIdentifiers.StopCell.rawValue, for: indexPath) as? StopsTableViewCell else { return UITableViewCell() }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
        
        cell.stopImage.image = stop.tableViewImage
        cell.stopLabel.text = sampleData[indexPath.section].shortDesc
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    
}
