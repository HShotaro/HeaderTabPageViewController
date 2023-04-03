//
//  File.swift
//  
//
//  Created by Shotaro Hirano on 2022/09/14.
//

import UIKit
/// The methods adopted by the object you use to manage HeaderTabPageViewController status
public protocol HeaderTabPageViewControllerDelegate: AnyObject {
    /// Tells the delegate that  user selected the specified tab
    func didSelectTab(index: Int)
    /// Tells the delegate that  visibleViewController changed
    func didChangeVisuableViewController(to viewController: UIViewController)
}
