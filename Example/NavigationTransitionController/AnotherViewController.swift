//
//  AnotherViewController.swift
//  NavigationTransitionController_Example
//
//  Created by Joshua Choi on 8/4/21.
//  Copyright (c) 2021 Nanolens, Inc. All rights reserved.
//

import UIKit
import NavigationTransitionController


class AnotherViewController: UIViewController {
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.lightGray
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let exitItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(exitViewController(_:)))
        navigationItem.setLeftBarButton(exitItem, animated: false)
        
        tapGestureRecognizer.addTarget(self, action: #selector(exitViewController(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc fileprivate func exitViewController(_ sender: Any) {
        // MARK: - NavigationTransitionController
        // Dismiss the navigation transition view controller by accessing it (it's a UINavigationController subclass so you can also use ```.navigationController```) — also call a completion if needed
        self.navigationTransitionController?.dismissNavigation(animated: true, completion: { (dismissed: Bool) in
            // Closure executed here
        })
    }
}
