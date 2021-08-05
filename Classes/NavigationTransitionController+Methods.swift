//
//  NavigationTransitionController+Methods.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 11/27/20.
//  Copyright © 2020 Nanolens, Inc. All rights reserved.
//

import UIKit



/**
 Abstract: Custom sourcefile used to accomodate the NavigationTransitionController class with key methods
 - updateInitialView
 - updateFinalView
 - handlePanGestureRecognizer
 - applyPresentationTransition
 - applyDismissalTransition
 - transformFromRect
 */
extension NavigationTransitionController {
    /// Updates the NavigationTransitionController's ```initialView``` object to hide/show when presenting or dismissing this navigation controller class
    /// - Parameter view: An optional UIView object
    @objc public func updateInitialView(_ view: UIView?) {
        // Update this class' ```initialView```
        self.initialView = view
    }
    
    /// Updates the NavigationTransitionController's ```finalView``` object to hide/show when presenting or dismissing this navigation controller class
    /// - Parameter view: An optional UIView object
    @objc public func updateFinalView(_ view: UIView?) {
        // Update this class' ```finalView```
        self.finalView = view
    }
    
    /// Handle the pan gesture recognizer for the view controller at the top of the navigation stack
    /// - Parameter gesture: A UIPanGestureRecognzier object that calls this method
    @objc public func handlePanGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        // Update the Boolean to indicate that we're interactively driving the transition animations
        self.isInteractivelyDriven = gesture.state == .began || gesture.state == .changed
        
        // Call the closure to indicate that the transition is changing
        self.interactiveTransitioningObserver?(gesture.state)
        
        // Get the pan gesture's velocity
        let velocity = gesture.velocity(in: nil)
        
        // Get the pan gesture's translation
        let translation = gesture.translation(in: nil)
                
        // CGFloat value representing a gesture's "flick"
        let flickMagnitude: CGFloat = 900.0
        
        // Determine if we're flicking the view
        let isFlick = (velocity.vector.magnitude > flickMagnitude)
        
        // MARK: - NavigationTransitionType
        switch type {
        case .standard:
            switch gesture.state {
            case .began:
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
                rootViewController.navigationTransitionController?.dismissNavigation()
            
            case .changed:
                // Define the percentage by computing the ratio between the gesture's current translation and its maximium allowed translation
                let percentage = translation.x/UIScreen.main.bounds.width
                // MARK: UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.update(percentage)
            default:
                // If we've reached the parameters at which we should cancel the interactive transition driver, then indicate that it's finished and de-allocate the driver object
                guard velocity.x > 0.0 && (translation.x >= UIScreen.main.bounds.width/3.0 || isFlick == true) else {
                    // MARK: - UIPercentDrivenInteractiveTransition
                    percentDrivenInteractiveTransition?.cancel()
                    return
                }
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.finish()
                percentDrivenInteractiveTransition = nil
            }
            
        case .presentation:
            switch gesture.state {
            case .began:
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
                rootViewController.navigationTransitionController?.dismissNavigation()
                
                // MARK: - UIScrollView
                // Disable the scroll view when the gesture begins
                if let scrollView = gesture.view?.subviews.filter({$0.isKind(of: UIScrollView.self) == true}).first as? UIScrollView {
                    scrollView.isScrollEnabled = false
                }
                
            case .changed:
                // Define the percentage by computing the ratio between the gesture's current translation and its maximium allowed translation
                let percentage = translation.y/UIScreen.main.bounds.height
                // MARK: UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.update(percentage)
            default:
                // MARK: - UIScrollView
                // Re-enable the scroll view whens the gesture ends
                if let scrollView = gesture.view?.subviews.filter({$0.isKind(of: UIScrollView.self) == true}).first as? UIScrollView {
                    scrollView.isScrollEnabled = true
                }
                
                // If we've reached the parameters at which we should cancel the interactive transition driver, then indicate that it's finished and de-allocate the driver object
                guard velocity.y > 0.0 && (translation.y >= UIScreen.main.bounds.height/3.0 || isFlick == true) else {
                    // MARK: - UIPercentDrivenInteractiveTransition
                    percentDrivenInteractiveTransition?.cancel()
                    return
                }
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.finish()
                percentDrivenInteractiveTransition = nil
            }
            
        case .zoom:
            switch gesture.state {
            case .began:
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
                rootViewController.navigationTransitionController?.dismissNavigation()

            case .changed:
                // Calculate the percentage by providing the range for how much the translation is allowed
                let percentage = CGFloat.scaleAndShift(value: translation.y, inRange: (min: 0.0, max: 200.0))

                // Calculate the scale of the context view and set its minimum scale to be as as small as 60%
                let scale = 1.0 - (1.0 - CGFloat(0.60)) * percentage

                // MARK: UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.update(percentage)

                // Animate the final view snapshot view
                self.finalViewSnapshotView?.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).translatedBy(x: translation.x, y: translation.y)
                self.initialViewSnapshotView?.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).translatedBy(x: translation.x, y: translation.y)

            default:
                // Rest the gesture's translation
                gesture.setTranslation(.zero, in: nil)

                // If we've reached the parameters at which we should cancel the interactive transition driver, then indicate that it's finished and de-allocate the driver object
                switch velocity.y > 0.0 && (translation.y >= UIScreen.main.bounds.height/3.0 || isFlick == true) {
                case true:
                    // Calculate the initial view's frame for the transition
                    let initialViewFrame = self.initialView?.superview?.convert(self.initialView?.frame ?? .zero, to: transitionContext.containerView) ?? .zero

                    // Apply the animations
                    UIView.animate(withDuration: animationDuration) {
                        self.finalViewSnapshotView?.alpha = 0.0
                        self.finalViewSnapshotView?.frame = initialViewFrame
                        self.initialViewSnapshotView?.alpha = 1.0
                        self.initialViewSnapshotView?.frame = initialViewFrame
                    } completion: { (success: Bool) in
                        // MARK: - UIPercentDrivenInteractiveTransition
                        self.percentDrivenInteractiveTransition?.finish()
                        self.percentDrivenInteractiveTransition = nil
                    }

                case false:
                    // Calculate the final view's frame
                    let finalViewFrame = self.finalView?.superview?.convert(self.finalView?.frame ?? .zero, to: transitionContext.containerView) ?? .zero

                    // Reset the context view to match that of the final view's frame
                    UIView.animate(withDuration: animationDuration) {
                        self.finalViewSnapshotView?.frame = finalViewFrame
                    } completion: { (success: Bool) in
                        // MARK: - UIPercentDrivenInteractiveTransition
                        self.percentDrivenInteractiveTransition?.cancel()
                    }
                }
            }

        default: break;
        }
    }
    
    /// Apply the presentation animation transition
    /// - Parameter transitionContext: A UIViewControllerContextTransitioning object
    public func applyPresentationTransition(transitionContext: UIViewControllerContextTransitioning) {
        // MARK: - UIViewController
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            print("\(#file)/\(#line) - Couldn't unwrap the transition context's UIViewControllers")
            // Indicate that the transition context wasn't completed
            transitionContext.completeTransition(false)
            return
        }
        
        // MARK: - NavigationTransitionType
        switch type {
        case .fade:
            // Add the to view controller's view to the transition context's container view
            transitionContext.containerView.addSubview(toViewController.view)
            // Setup the initial states
            toViewController.view.alpha = 0.0
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                toViewController.view.alpha = 1.0
            } completion: { (success: Bool) in
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        
        case .standard:
            // Add the to view controller's view to the transition context's container view
            transitionContext.containerView.addSubview(toViewController.view)
            // Setup the views' initial states
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            transitionContext.containerView.insertSubview(backgroundView, belowSubview: toViewController.view)
            toViewController.view.frame.origin.x = UIScreen.main.bounds.width
            
            // MARK: - CAShapeLayer
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = toViewController.view.bounds
            shapeLayer.path = UIBezierPath(roundedRect: toViewController.view.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 30.0, height: 30.0)).cgPath
            toViewController.view.layer.mask = shapeLayer
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.10)
                toViewController.view.frame.origin.x = 0.0
            } completion: { (success: Bool) in
                // Reset the views' states
                self.backgroundView.removeFromSuperview()
                toViewController.view.layer.mask = nil
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        case .presentation:
            // Add the to view controller's view to the transition context's container view
            transitionContext.containerView.addSubview(toViewController.view)
            // Setup the views' initial states
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            transitionContext.containerView.insertSubview(backgroundView, belowSubview: toViewController.view)
            toViewController.view.frame.origin.y = UIScreen.main.bounds.height
            
            // MARK: - CAShapeLayer
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = toViewController.view.bounds
            shapeLayer.path = UIBezierPath(roundedRect: toViewController.view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 30.0, height: 30.0)).cgPath
            toViewController.view.layer.mask = shapeLayer
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.10)
                toViewController.view.frame.origin.y = 0.0
            } completion: { (success: Bool) in
                // Reset the views' states
                self.backgroundView.removeFromSuperview()
                toViewController.view.layer.mask = nil
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        case .zoom:
            // Compute the to view controller view's frame relative to the transition context's container view
            let toViewControllerViewFrame: CGRect = transitionContext.finalFrame(for: toViewController)
            
            // Compute the initial view's frame relative to the transition context's container view
            let initialViewFrame: CGRect = self.initialView?.superview?.convert(self.initialView?.frame ?? .zero, to: transitionContext.containerView) ?? .zero
            
            // Compute the final view's frame by preserving the initial view's frame
            let finalViewFrame: CGRect = TransitionRatio.preservedPresentationFrame(viewController: transitionContext.viewController(forKey: .from) ?? toViewController, size: initialViewFrame.size)

            // MARK: - UIView
            self.initialViewSnapshotView = self.initialView?.snapshotView(afterScreenUpdates: false)
            if self.initialViewSnapshotView != nil {
                transitionContext.containerView.addSubview(self.initialViewSnapshotView!)
                self.initialViewSnapshotView?.frame = initialViewFrame
            }
            
            // Hide the initial view
            self.initialView?.alpha = 0.0

            // Transform the to view controller's view relative to the final view controller's frame and the initial view frame while preserving its aspect ratio
            toViewController.view.transform = CGAffineTransform(sourceRect: toViewControllerViewFrame, finalRect: initialViewFrame, preservingAspectRatio: true)
            toViewController.view.alpha = 0.0
            transitionContext.containerView.addSubview(toViewController.view)

            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.initialViewSnapshotView?.frame = finalViewFrame
                toViewController.view.alpha = 1.0
                toViewController.view.transform = CGAffineTransform.identity
            } completion: { (success: Bool) in
                // Show the initial view
                self.initialView?.alpha = 1.0
                self.initialViewSnapshotView?.removeFromSuperview()
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        default: break;
        }
    }
    
    /// Apply the dismissal animation transition by removing the fromViewController's view from the transition context's container view
    /// - Parameter transitionContext: A UIViewControllerContextTransitioning object
    public func applyDismissalTransition(transitionContext: UIViewControllerContextTransitioning) {
        // MARK: - UIViewController
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            print("\(#file)/\(#line) - Couldn't unwrap the transition context's UIViewControllers")
            // Indicate that the transition context wasn't completed
            transitionContext.completeTransition(false)
            return
        }
        
        // MARK: - NavigationTransitionType
        switch type {
        case .fade:
            // Setup the views' initial states
            fromViewController.view.alpha = 1.0
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                fromViewController.view.alpha = 0.0
            } completion: { (success: Bool) in
                // Only remove the fromViewController's view from its superview when the transition context was cancelled
                if !transitionContext.transitionWasCancelled {
                    fromViewController.view.removeFromSuperview()
                }
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        
        case .standard:
            // Setup the views' initial states
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.10)
            transitionContext.containerView.insertSubview(backgroundView, belowSubview: fromViewController.view)
            fromViewController.view.frame.origin.x = 0.0
            
            // MARK: - CAShapeLayer
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = fromViewController.view.bounds
            shapeLayer.path = UIBezierPath(roundedRect: fromViewController.view.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 30.0, height: 30.0)).cgPath
            fromViewController.view.layer.mask = shapeLayer
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                fromViewController.view.frame.origin.x = UIScreen.main.bounds.width
            } completion: { (success: Bool) in
                // Only execute the following codeblock if the transition wasn't cancelled
                if !transitionContext.transitionWasCancelled {
                    // Reset the views' states
                    self.backgroundView.removeFromSuperview()
                    fromViewController.view.removeFromSuperview()
                } else {
                    // Reset the views' states
                    fromViewController.view.layer.mask = nil
                }
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

        case .presentation:
            // Setup the views' initial states
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.10)
            transitionContext.containerView.insertSubview(backgroundView, belowSubview: fromViewController.view)
            fromViewController.view.frame.origin.y = 0.0
            
            // MARK: - CAShapeLayer
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = fromViewController.view.bounds
            shapeLayer.path = UIBezierPath(roundedRect: fromViewController.view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 30.0, height: 30.0)).cgPath
            fromViewController.view.layer.mask = shapeLayer
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                fromViewController.view.frame.origin.y = UIScreen.main.bounds.height
            } completion: { (success: Bool) in
                // Only execute the following codeblock if the transition wasn't cancelled
                if !transitionContext.transitionWasCancelled {
                    // Reset the views' states
                    self.backgroundView.removeFromSuperview()
                    fromViewController.view.removeFromSuperview()
                } else {
                    // Reset the views' states
                    fromViewController.view.layer.mask = nil
                }
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        case .zoom:
            // Compute the initial view's frame relative to the transition context's container view
            let initialViewFrame: CGRect = self.initialView?.superview?.convert(self.initialView?.frame ?? .zero, to: transitionContext.containerView) ?? .zero

            // Compute the final view's frame relative to the transition context's container view
            let finalViewFrame: CGRect = self.finalView?.superview?.convert(self.finalView?.frame ?? .zero, to: transitionContext.containerView) ?? .zero
        
            // Setup the initial state of the background view
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(1.0)
            transitionContext.containerView.addSubview(self.backgroundView)
            
            // MARK: - UIView
            // Create a snapshot of the initial view
            self.initialViewSnapshotView = self.initialView?.snapshotView(afterScreenUpdates: false)
            if self.initialViewSnapshotView != nil {
                transitionContext.containerView.insertSubview(self.initialViewSnapshotView!, aboveSubview: self.backgroundView)
                self.initialViewSnapshotView!.frame = finalViewFrame
                self.initialViewSnapshotView!.alpha = 0.0
            }
            
            // MARK: - UIView
            // Create a snapshot of the final view
            self.finalViewSnapshotView = self.finalView?.snapshotView(afterScreenUpdates: true)
            if self.finalViewSnapshotView != nil {
                transitionContext.containerView.insertSubview(self.finalViewSnapshotView!, aboveSubview: self.backgroundView)
                self.finalViewSnapshotView!.frame = finalViewFrame
                self.finalViewSnapshotView!.alpha = 1.0
            }
            
            // Initially hide the initialView and the fromViewController's view
            self.initialView?.alpha = 0.0
            fromViewController.view.alpha = 0.0

            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.initialViewSnapshotView?.frame = self.isInteractivelyDriven ? self.finalViewSnapshotView?.frame ?? finalViewFrame : initialViewFrame
                self.initialViewSnapshotView?.alpha = self.isInteractivelyDriven ? 0.0 : 1.0
                self.finalViewSnapshotView?.frame = self.isInteractivelyDriven ? self.finalViewSnapshotView?.frame ?? finalViewFrame : initialViewFrame
                self.finalViewSnapshotView?.alpha = self.isInteractivelyDriven ? 1.0 : 0.0
                
            } completion: { (success: Bool) in
                // Show the initial view and remove the background view, final snapshot view, and intial snapshot view
                self.initialView?.alpha = 1.0
                self.backgroundView.removeFromSuperview()
                self.finalViewSnapshotView?.removeFromSuperview()
                self.initialViewSnapshotView?.removeFromSuperview()
                // Only remove the fromViewController's view from its superview when the transition context was cancelled — otherwise, show the from view controller's view
                if !transitionContext.transitionWasCancelled {
                    fromViewController.view.removeFromSuperview()
                } else {
                    fromViewController.view.alpha = 1.0
                }
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        default: break;
        }
    }
}
