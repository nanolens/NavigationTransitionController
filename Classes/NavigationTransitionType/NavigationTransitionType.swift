//
//  NavigationTransitionType.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 11/27/20.
//  Copyright © 2020 Nanolens, Inc. All rights reserved.
//

import UIKit



/**
 Abstract: Enum representing the type of NavigationTransitionType associated with a given view controller
 */
@objc public enum NavigationTransitionType: Int, CaseIterable {
    /// Fades the view controller's view when pushing or popping it from the navigation stack
    case fade = 0
    /// Standard view controller animation for pushing or popping
    case standard = 1
    /// Presents a view controller from the bottom when pushing and dismisses a view controller to the bottom when popping — driven by a vertical pan gesture's translation
    case presentation = 2
    /// Animates a view controller zooming in when pushing and animates a view controller zooming out when popping – similar to a photos gallery transition animation
    case zoom = 3
}
