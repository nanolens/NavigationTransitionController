//
//  TransitionRatio.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 2/17/21.
//  Copyright (c) 2021 Nanolens, Inc. All rights reserved.
//

import UIKit



/**
 Abstract: Class that represents a view's leading, top, trailing, and bottom constraints or frame by preserving a media content's aspect ratio
 */
class TransitionRatio {
    /// Returns a CGRect value representing the appropriate frame for a given media's content size while preserving the aspect ratio that's compatible and persistent throughout the entire application when presenting content full screen
    /// - Parameter viewController: A UIViewController object used to reference its top bar height
    /// - Parameter size: A CGSize value representing the size of the media content
    static func preservedPresentationFrame(viewController: UIViewController, size: CGSize) -> CGRect {
        // Define the safe area insets
        let safeAreaInsets: UIEdgeInsets = viewController.view.window?.safeAreaInsets ?? UIEdgeInsets.zero
        // Get the top bar height
        let topBarHeight: CGFloat = (UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) + (viewController.navigationController?.navigationBar.frame.height ?? 0.0)
        // Calculate the screen height by subtracting its top and bottom insets accordingly if it has a notch; otherwise, display the content in full screen
        let screenHeight = safeAreaInsets.bottom > 0.0 ? ((UIScreen.main.bounds.width * 16.0)/9.0).rounded(.up) : UIScreen.main.bounds.height
        // Compute the status bar's height and the top and bottom padding
        let topPadding = safeAreaInsets.bottom > 0.0 ? topBarHeight : 0.0
        let bottomPadding = safeAreaInsets.bottom > 0.0 ? (UIScreen.main.bounds.height - topPadding - screenHeight).rounded(.up) : 0.0
        // Calculate the content and preserve its aspect ratio
        let aspectHeight = (UIScreen.main.bounds.width * size.height)/size.width
        // Check if the scaled content size is larger than the screen's height
        switch aspectHeight >= screenHeight {
        case true:
            // Compute the top and bottom constraints — if the device has a notch, then set the top constraint to be the status bar's height and the bottom constraint to be the safe area's bottom inset
            let topConstraint: CGFloat = topPadding
            let bottomConstraint: CGFloat = bottomPadding
            // Compute the mutated height - after getting the difference with the top/bottom constraints if the device has a notch
            let mutatedHeight = safeAreaInsets.bottom > 0.0 ? UIScreen.main.bounds.height - topConstraint - bottomConstraint : UIScreen.main.bounds.height
            // Compute the aspect width — if the device has a notch, subtract the device's screen height by the top/bottom constraints we've previously computed
            let aspectWidth = ((mutatedHeight * size.width)/size.height).rounded(.up)
            // Compute the leading and trailing padding values by subtracting the device's screen width by the aspect width and dividing it by 2 for leading/trailing
            let leadingAndTrailingPadding = ((UIScreen.main.bounds.width - aspectWidth)/2.0).rounded(.up)
            // Compute the leading and trailing constraints — we noticed that if the leading and trailing padding values are greater than 0.0, we need to update it
            let leadingAndTrailingConstraint = leadingAndTrailingPadding > 0.0 ? leadingAndTrailingPadding : 0.0
            // MARK: - CGRect
            return CGRect(x: leadingAndTrailingConstraint, y: topConstraint, width: aspectWidth, height: UIScreen.main.bounds.height - topConstraint - bottomConstraint)
        case false:
            // Calculate the top and bottom constraints by getting the difference between the screen height and the scaled asset height then dividing that value by 2 for both the top and bottom constraints
            let topAndBottomConstraints = (screenHeight - aspectHeight)/2.0
            // Set the top constraint by offsetting the top padding with and calculated constraint
            let topConstraint = (topPadding + topAndBottomConstraints).rounded(.up)
            // Set the bottom constraint by offsetting the bottom padding and the calculated constraint
            let bottomConstraint = (bottomPadding + topAndBottomConstraints).rounded(.up)
            // MARK: - CGRect
            return CGRect(x: 0.0, y: topConstraint, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - topConstraint - bottomConstraint)
        }
    }
}



// MARK: - CGAffineTransform
extension CGAffineTransform {
    /// MARK: - Init
    /// - Parameter sourceRect: A CGRect value representing the source frame
    /// - Parameter finalRect: A CGRect value representing the final frame
    /// - Parameter preservingAspectRatio: A Boolean value used to determine as to whether we should preserve the aspect ratio
    init(sourceRect: CGRect, finalRect: CGRect, preservingAspectRatio: Bool) {
        self = CGAffineTransform.identity
        self = self.translatedBy(x: -(sourceRect.midX - finalRect.midX), y: -(sourceRect.midY - finalRect.midY))
        if preservingAspectRatio {
            let sourceAspectRatio = sourceRect.size.width/sourceRect.size.height
            let finalAspectRatio = finalRect.size.width/finalRect.size.height
            if sourceAspectRatio > finalAspectRatio {
                self = self.scaledBy(x: finalRect.size.height/sourceRect.size.height, y: finalRect.size.height/sourceRect.size.height)
            } else {
                self = self.scaledBy(x: finalRect.size.width/sourceRect.size.width, y: finalRect.size.width/sourceRect.size.width)
            }
        } else {
            self = self.scaledBy(x: finalRect.size.width/sourceRect.size.width, y: finalRect.size.height/sourceRect.size.height)
        }
    }
}
