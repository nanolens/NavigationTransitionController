# NavigationTransitionController
[![CI Status](https://img.shields.io/travis/HackShitUp/NavigationTransitionController.svg?style=flat)](https://travis-ci.org/HackShitUp/NavigationTransitionController)
[![Version](https://img.shields.io/cocoapods/v/NavigationTransitionController.svg?style=flat)](https://cocoapods.org/pods/NavigationTransitionController)
[![License](https://img.shields.io/cocoapods/l/NavigationTransitionController.svg?style=flat)](https://cocoapods.org/pods/NavigationTransitionController)
[![Platform](https://img.shields.io/cocoapods/p/NavigationTransitionController.svg?style=flat)](https://cocoapods.org/pods/NavigationTransitionController)

## About
```NavigationTransitionController``` is a ```UINavigationController``` that lets you implement interactive view controller transitions. It
manages the ```UIViewControllerInteractiveTransitioning```, ```UIViewControllerAnimatedTransitioning```, and ```UIViewControllerTransitioningDelegate``` protocols for 4 unique transition types.  
The current state of ```UIKit``` requires a ```UIViewController``` to conform to several protocols to implement a simple view controller transition. Not only that, but it also persists the standard ```UINavigationBar``` transition when pushing or popping a view controller onto a navigation stack.
![WWDC](/Documentation/Images/WWDC.png?raw=true)
```NavigationTransitionController``` solves the complexity of this implementation by wrapping all of the setup in a ```UINavigationController``` so that each ```UIViewController``` can interface with interactive, animated transitions with its own persisting ```UINavigationBar```.

## Usage
To simulate a view controller being "pushed" onto a standard navigation controller:
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // Initialize your view controller
    let myVC = UIViewController()
    // Pass it as a root view controller with the specified NavigationTransitionType
    let navigationTransitionController = NavigationTransitionController(rootViewController: myVC, type: .standard)
    navigationTransitionController.presentNavigation(self)
}
```

## Presenting With Transition Types
The ```NavigationTransitionController``` comes out-of-the-box with 4 unique custom interactive animated transitions, accessible via the ```NavigationTransitionType``` enums:
## NavigationTransitionType.Standard
This simulates a view controller being "pushed" onto a standard navigation controller:  
![NavigationTransitionType.Standard](/Documentation/Gif/Standard.gif?raw=true)

## NavigationTransitionType.Presentation
This simulates a view controller being "presented" from the bottom up. It restricts the root view controller's first scroll view subview without interfering its expected scrolling behavior (aka enable the transition to occur only when the ```UIScrollView```'s ```contentOffset``` reaches the top):  
![NavigationTransitionType.Presentation](/Documentation/Gif/Presentation.gif?raw=true)

## NavigationTransitionType.Fade
This simulates a view controller "fading-in" to the screen:  
![NavigationTransitionType.Fade](/Documentation/Gif/Fade.gif?raw=true)

## NavigationTransitionType.Zoom
This simulates the iOS photos library transition. Unlike other dependencies, the setup and teardown is incredibly simple:  
![NavigationTransitionType.Zoom](/Documentation/Gif/Zoom.gif?raw=true)
  
To configure the initial view transition:
```swift
// Define your image view for the initial view transition
let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))

override func viewDidLoad() {
    super.viewDidLoad()
    // Setup
    view.addSubview(imageView)
    imageView.center = view.center

    // Initialize your view controller
    let photoVC = UIViewController()
    // MARK: - NavigationTransitionController
    // Pass it as a root view controller with the specified NavigationTransitionType — here, we specify the initial view as the imageView
    let navigationTransitionController = NavigationTransitionController(rootViewController: photoVC, type: .zoom, initialView: imageView)
    navigationTransitionController.presentNavigation(self)
}
```
If the view ever changes, (i.e, you're displaying multiple photos in a horizontally scrolling ```UICollectionView```) update the ```NavigationTransitionController```'s ```finalView``` to persist the transitioning images to and from view controllers:
```swift
// Get the cell with the new image after we've scrolled and update the final view for the navigation transition controller's transition
if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
    self.navigationTransitionController?.updateFinalView(cell.imageView)
}
```

## Dismissing With Animation
You can access the ```NavigationTransitionController``` from within an arbitrary ```UIViewController``` that's presented with it as you would with the standard ```UINavigationController```:
```swift
@objc func dismissViewController(_ sender: Any) {
    // Dismiss the navigation transition view controller by accessing it (it's a UINavigationController subclass so you can also use ```.navigationController``` and cast it) — also call a completion if needed
    self.navigationTransitionController?.dismissNavigation(animated: true, completion: { (dismissed: Bool) in
        // Closure executed here
    })
}
```
## Observing Gesture-Driven Transitions
There are use-cases when one might need to observe a ```NavigationTransitionController```'s gesture-driven transitions. For instance, when we want to disable the scroll view from scrolling with a ```NavigationTransitionType.presentation``` transition:
```swift
    // Enable or disable the scroll view based on the UIGestureRecognizer.State
    self.navigationTransitionController?.interactiveTransitioningObserver = { (state: UIGestureRecognizer.State) in
        let isScrollEnabled = (state == .began || state == .changed) ? false : true
        self.scrollView.isScrollEnabled = isScrollEnabled
    }
```

## Disabling the Gesture
To disable the gesture entirely:
```swift
    // Disable the gesture
    self.navigationTransitionController?.panGestureRecognizer.isEnabled = false
```

## Requirements
- iOS 13+

## Installation
To run the example project, clone the repo, and run `pod install` from the Example directory first.
  
NavigationTransitionController is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'NavigationTransitionController'
```

## Author

[HackShitUp](https://github.com/HackShitUp), josh.m.choi@gmail.com  
[Nanolens, Inc.](https://nanolens.co)

## License

NavigationTransitionController is available under the MIT license. See the LICENSE file for more info.
