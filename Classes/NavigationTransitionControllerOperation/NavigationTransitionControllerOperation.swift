//
//  NavigationTransitionOperation.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 11/27/20.
//  Copyright © 2020 Nanolens, Inc. All rights reserved.
//

import UIKit



/**
 Abstract: NavigationTransitionOperation enum defines whether a view controller is about to be presented or dismissed
 */
@objc public enum NavigationTransitionOperation: Int, CaseIterable {
    /// Dismisses the view controller
    case dismiss = 0
    /// Presents the view controller
    case present = 1
}
