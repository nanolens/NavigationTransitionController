//
//  NavigationTransitionController+Delegate.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 11/27/20.
//  Copyright © 2020 Nanolens, Inc. All rights reserved.
//

import UIKit



// MARK: - UIGestureRecognizerDelegate
extension NavigationTransitionController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // MARK: - NavigationTransitionType
        switch type {
        case .standard:
            // Disable the pan gesture from moving to the left along the x-axis
            return gestureRecognizer == panGestureRecognizer && panGestureRecognizer.velocity(in: nil).x > 0.0
        case .zoom, .presentation:
            // Disable the pan gesture from moving up along the y-axis or x-axis
            return gestureRecognizer == panGestureRecognizer && (panGestureRecognizer.velocity(in: nil).y > 0.0 || abs(panGestureRecognizer.velocity(in: nil).x) > abs(panGestureRecognizer.velocity(in: nil).x))
        default:
            // By default, allow the pan gesture to begin
            return true
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // MARK: - UIScrollView
        if let scrollView = (gestureRecognizer == panGestureRecognizer ? otherGestureRecognizer : panGestureRecognizer).view as? UIScrollView, type == .presentation {
            // Allow the gesture recognizer to work simultaneously with the scroll view only if the scroll view has reached the top-edge
            return scrollView.contentOffset.y <= scrollView.contentInset.top
        } else if type == .fade {
            // If the NavigationTransitionType is fade, allow it to begin
            return true
        } else {
            return false
        }
    }
}



// MARK: - UIViewControllerTransitioningDelegate
extension NavigationTransitionController: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isInteractivelyDriven ? percentDrivenInteractiveTransition : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isInteractivelyDriven ? percentDrivenInteractiveTransition : nil
    }
}



// MARK: - UIViewControllerAnimatedTransitioning
extension NavigationTransitionController: UIViewControllerInteractiveTransitioning {
    public var wantsInteractiveStart: Bool {
        return false
    }

    public var completionSpeed: CGFloat {
        return 0.0
    }
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        // Only forward calls to this class' UIViewControllerAnimatedTransitioning protocol if we're not interactively driving the transition
        guard isInteractivelyDriven == false else {
            return
        }
        print("\(#file)/\(#line) - \(classForCoder) forwarding interactive transition to animated transitioning delegate")
        // Call the UIViewControllerAnimatedTransitioning
        self.animateTransition(using: transitionContext)
    }
}



// MARK: - UIViewControllerAnimatedTransitioning
extension NavigationTransitionController: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // MARK: - TransitionContext
        self.transitionContext = transitionContext
        
        // MARK: - NavigationTransitionOperation
        switch navigationTransitionOperation {
        case .present:
            // Apply the presentation animation transition
            applyPresentationTransition(transitionContext: transitionContext)
            
        case .dismiss:
            // Apply the dismissal animation transition
            applyDismissalTransition(transitionContext: transitionContext)
            
        }
    }
}


