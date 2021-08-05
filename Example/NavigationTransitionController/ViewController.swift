//
//  ViewController.swift
//  NavigationTransitionController
//
//  Created by HackShitUp on 08/04/2021.
//  Copyright (c) 2021 Nanolens, Inc. All rights reserved.
//

import UIKit
import NavigationTransitionController



class Cell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "Cell"
    static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 60.0)
    var imageView: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    fileprivate func setup() {
        frame = bounds
        backgroundColor = UIColor.white

        imageView = UIImageView(frame: .zero)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.contentMode = .scaleAspectFill
        
        label = UILabel(frame: .zero)
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
    }
    
    /// Update this cell's interface with the NavigationTransitionType
    /// - Parameter type: 
    func updateContent(type: NavigationTransitionType) {
        switch type {
        case .fade:
            label.text = "Fade"
        
        case .presentation:
            label.text = "Presentation"
        
        case .standard:
            label.text = "Standard"
        
        case .zoom:
            label.text = "Zoom"
            imageView.image = UIImage(named: "image")
        }
    }
}



class ViewController: UIViewController {
    
    var types = NavigationTransitionType.allCases
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = Cell.size
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
}



extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Cell.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        cell.updateContent(type: types[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch types[indexPath.item] {
        case .zoom:
            // MARK: - Cell
            // Unwrap the cell so we can access the initial image view for the zoom transition
            guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else {
                return
            }
            
            // MARK: - PhotoViewController
            // Dismiss this view controller with a tap when it's presented
            let photoVC = PhotoViewController()
            
            // MARK: - NavigationTransitionController
            // Present the navigation transition controller with the view controller and the specified type
            let navigationTransitionController = NavigationTransitionController(rootViewController: photoVC, type: types[indexPath.item], initialView: cell.imageView)
            navigationTransitionController.presentNavigation(self)
            
        default:
            // MARK: - AnotherViewController
            // Dismiss this view controller with a tap when it's presented
            let anotherVC = AnotherViewController()
            
            // MARK: - NavigationTransitionController
            // Present the navigation transition controller with the view controller and the specified type
            let navigationTransitionController = NavigationTransitionController(rootViewController: anotherVC, type: types[indexPath.item])
            navigationTransitionController.presentNavigation(self)
        }
    }
}
