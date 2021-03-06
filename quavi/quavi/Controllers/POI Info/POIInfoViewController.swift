//
//  POIInfoViewController.swift
//  quavi
//
//  Created by Mr Wonderful on 2/11/20.
//  Copyright © 2020 Sunni Tang. All rights reserved.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Kingfisher

class POIInfoViewController: UIViewController {
    
    //MARK: -- UI Properties
    lazy var continueButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.borderColor = UIColor.black.cgColor
        button.backgroundColor = .systemGreen
        button.layer.borderWidth = 3
        return button
    }()
    
    lazy var containerView: UIScrollView = {
        print("\n Frame Width: \(self.view.frame.width)")
        print("\n Scroll View Width: \(self.view.frame.width * 0.95) \n")
        let view = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.95, height: self.view.frame.height * 0.65))
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.isPagingEnabled = true
        view.isScrollEnabled = true
        view.backgroundColor = .clear
        view.bounces = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        return view
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setImage(UIImage(named: "duck_icon_hallow"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIDesign.quaviOrange
        button.layer.borderWidth = 3
        button.addTarget(self, action: #selector(handleShowingAlert), for: .touchUpInside)
        return button
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.hidesForSinglePage = true
        pc.pageIndicatorTintColor = UIDesign.quaviLightGrey
        pc.currentPageIndicatorTintColor = .red
        pc.addTarget(self, action: #selector(handlePageControllerTapped(_:)), for: .allTouchEvents)
        return pc
    }()
    
    lazy var presentModesOfTransport:UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = button.frame.height / 2
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIDesign.quaviYellow.cgColor
        button.backgroundColor = UIDesign.quaviLightGrey
        button.tintColor = .black
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(handlePresentingButton), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelTourButton:UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = button.frame.height / 2
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIDesign.quaviLightGrey
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(handleCancelButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var bikeButton:UIButton = {
        let button = UIButton(image: UIImage(named: "bike")!, borderWidth: 2, tag: 1)
        button.alpha = 0
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(handleSelectingModeOfTransportation(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var carButton:UIButton = {
        let button = UIButton(image: UIImage(named: "car")!, borderWidth: 2, tag: 0)
        button.alpha = 0
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(handleSelectingModeOfTransportation(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var walkButton:UIButton = {
        let button = UIButton(image: UIImage(named: "walk")!, borderWidth: 2, tag: 2)
        button.alpha = 0
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(handleSelectingModeOfTransportation(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var quaviLogo: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Quavi_Logo_White")
        image.tintColor = UIDesign.quaviYellow
        return image
    }()
    
    lazy var leftChevron: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.left")
        image.tintColor = .red
        return image
    }()
    
    lazy var rightChevron: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.right")
        image.tintColor = .red
        return image
    }()
    
    lazy var view4 = MapView(frame: view.bounds)
    
    var viewArray: [UIView]!
    let shapeLayer = CAShapeLayer()
    var showButtons:Enums.presentModeOfTransport = .hide
    var bikeButtonTopConstraint: NSLayoutConstraint?
    var carButtonTopConstraint: NSLayoutConstraint?
    var walkButtonTopConstraint: NSLayoutConstraint?
    var newBikeButtonTopConstraint: NSLayoutConstraint?
    var newCarButtonTopConstraint: NSLayoutConstraint?
    var newWalkButtonTopConstraint: NSLayoutConstraint?
    
    //MARK:-- Internal Properties
    var poiForTour = [POI]() {
        didSet {
            setUpPageViews()
        }
    }
    
    var selectedTour: Tour?
    var selectedRoute: Route?
    var currentLegRoute: Route?
    
    //MARK: -- Computed properties
    var currentPage:Int {
        return Int(calculateCurrentPosition())
    }
    
    var nextStopIndex = 0 {
        didSet{
            guard poiForTour.count > 0 else {return}
            guard nextStopIndex > 0 else {return}
            setUpPageViews()
            
        }
    }
    
    var modeOfTransit:MBDirectionsProfileIdentifier = .automobile{
        didSet{
            getSelectedRoute(navigationType: modeOfTransit)
            switchTransitBackgroundButton()
        }
    }
    
    var waypointCount:Int! {
        didSet{
            presentModesOfTransportCurrentState()
        }
    }
    
    var showMapView:Bool = false {
        didSet{
            if showMapView == true {
                let lastPage = CGFloat(viewArray.count - 1)
                containerView.setContentOffset(CGPoint(x: lastPage * containerView.frame.width, y: 0), animated: true)
                pageControl.currentPage = Int(lastPage)
                
            }
        }
    }
    
    var isAtLastLeg: Bool? = false{
        didSet {
            guard let isAtLastLeg = isAtLastLeg else {return}
            
            switch isAtLastLeg{
            case false:
                goToNextLeg()
            case true:
                presentConfettiVC()
            }
        }
    }
    
    //TODO: For Testing... Refactor with initalLocation from user!
    var userLocation = CLLocationCoordinate2D(latitude: 40.747034, longitude: -73.985096)
    
    
    //MARK:-- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackgroundColor()
        continueButtonConstraints()
       // quaviLogoButtonConstraints()
        containerViewConstraints()
        pageControlConstraints()
        likeButtonConstraints()
        presentModesOfTransportConstraints()
        cancelTourButtonConstraints()
        bikeButtonConstraints()
        carButtonConstraints()
        walkButtonConstraints()
        rightChevronConstraint()
        leftChevronConstraint()
        bringPresentModesOfTransportToFront()
        getSelectedRoute(navigationType: modeOfTransit)
    }
    
    //MARK:-- Private func
    private func setUpPageViews() {
        let currentPOI = poiForTour[nextStopIndex - 1]
        
        let view1 = POIPopUpAboutView()
        view1.poiName.text = currentPOI.name
        view1.descriptionTextView.text = currentPOI.longDesc
        view1.imageView.kf.indicatorType = .activity
        view1.imageView.kf.setImage(with: URL(string: currentPOI.tableViewImage), placeholder: UIDesign.placeholderImage, options: [.transition(.fade(0.2))])
        
        let view2 = POIPopUpGallery()
        view2.poiImageUrls = currentPOI.poiImages
        view2.poiGalleryCollectionView.alwaysBounceHorizontal = true
        
        viewArray = [view1, view2, view4]
        populateContainerView()
    }
    
    private func switchTransitBackgroundButton() {
        carButton.backgroundColor = modeOfTransit == .automobile ? UIDesign.quaviYellow : .white
        walkButton.backgroundColor = modeOfTransit == .walking ? UIDesign.quaviYellow : .white
        bikeButton.backgroundColor = modeOfTransit == .cycling ? UIDesign.quaviYellow : .white
    }
    
    private func presentModesOfTransportCurrentState() {
        presentModesOfTransport.isEnabled = nextStopIndex == waypointCount ? false : true
        presentModesOfTransport.layer.borderColor = nextStopIndex == waypointCount ? UIColor.lightGray.cgColor : UIColor.black.cgColor
    }
    
    private func bringPresentModesOfTransportToFront() {
        view.bringSubviewToFront(presentModesOfTransport)
    }
    
    private func goToNextLeg(){
        continueButton.setTitle("Next", for: .normal)
        continueButton.addTarget(self, action: #selector(continueButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func presentConfettiVC(){
        continueButton.removeTarget(self, action: #selector(continueButtonPressed(_:)), for: .touchUpInside)
        continueButton.setTitle("Finish", for: .normal)
        continueButton.layoutIfNeeded()
        continueButton.addTarget(self, action: #selector(handleFinishButtonPressed(_:)), for: .touchUpInside)
    }
    private func setBackgroundColor(){
        UIDesign.styleBackgroundColor(self.view)
    }
    
    func goToPage(index: Int, animated:Bool) {
        let index = CGFloat(index)
        containerView.setContentOffset(CGPoint(x: index * containerView.frame.width, y: 0), animated: animated)
    }
    
    // func to calculate current position of scrollview
    private func calculateCurrentPosition()-> CGFloat {
        let width = containerView.frame.width
        let contentOffSet = containerView.contentOffset.x
        return contentOffSet / width
    }
    
    private func populateContainerView() {
        if let viewArray = viewArray{
            pageControl.numberOfPages = viewArray.count
            for (index, view) in viewArray.enumerated(){
                let xPosition:CGFloat = self.containerView.frame.width * CGFloat(index)
                view.frame = CGRect(x: xPosition, y: 0, width: containerView.frame.width, height: containerView.frame.height)
                
                containerView.contentSize.width = containerView.frame.width * CGFloat(index + 1)
                containerView.addSubview(view)
            }
        }
    }
    
    //MARK: -- Objc func
    @objc func handlePageControllerTapped(_ sender: UIPageControl) {
        let pageIndex = sender.currentPage
        // calls the goToPage func to animate and present the appropriate view by internally incrementing and decrimenting index
        goToPage(index: pageIndex, animated: true)
        
    }
    
    @objc func handleCancelButtonPressed(sender:UIButton) {
        self.cancelAlert(title: "Caution", message: "Are you sure you want to cancel the tour", actionOneTitle: "Yes") { (action) in
            self.nextStopIndex = 0
            let viewController =  self.presentingViewController?.presentingViewController
            viewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleSelectingModeOfTransportation(sender:UIButton) {
        switch sender.tag{
        case 0:
            modeOfTransit = .automobile
        case 1:
            modeOfTransit = .cycling
        case 2:
            modeOfTransit = .walking
        default :
            return
        }
    }
    
    
    #warning("delete this and use a delegate to like a POI")
    
    @objc func handleShowingAlert() {
        self.showAlert(title: "Quack!", message: "The like feature is in working progress. Please continue to enjoy all the other features of the app ")
    }
}

extension POIInfoViewController: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(page)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        rightChevron.isHidden =  currentPage == viewArray.count - 1 ? true : false
        leftChevron.isHidden = currentPage == 0 ? true : false
    }
}
