//
//  PhotoViewController.swift
//  NavigationTransitionController_Example
//
//  Created by Joshua Choi on 8/4/21.
//  Copyright (c) 2021 Nanolens, Inc. All rights reserved.
//

import UIKit
import NavigationTransitionController

class PhotoViewController: UIViewController {
    
    var imageView: UIImageView!
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let exitItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(exitViewController(_:)))
        navigationItem.setLeftBarButton(exitItem, animated: false)

        tapGestureRecognizer.addTarget(self, action: #selector(exitViewController(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let image = UIImage(named: "image")!
        let scaledHeight: CGFloat = (image.size.height * UIScreen.main.bounds.width)/image.size.width
        
        // Setup the image view with full width and scaled height aspect ratio — al photo/video transitions should be in this format
        imageView = UIImageView(frame: .zero)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: scaledHeight).isActive = true
        imageView.image = image
        imageView.contentMode = .scaleAspectFill

        // MARK: - NavigationTransitionController
        // Update the navigation controller's ```finalView``` with the updated image view to persist interactive transitions for photos
        self.navigationTransitionController?.updateFinalView(imageView)
    }

    @objc fileprivate func exitViewController(_ sender: Any) {
        // MARK: - NavigationTransitionController
        // Dismiss the navigation transition view controller by accessing it (it's a UINavigationController subclass so you can also use ```.navigationController```) — also call a completion if needed
        self.navigationTransitionController?.dismissNavigation(animated: true, completion: { (dismissed: Bool) in
            // Closure executed here
        })
    }
}
