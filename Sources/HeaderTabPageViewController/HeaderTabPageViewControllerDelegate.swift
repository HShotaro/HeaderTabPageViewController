//
//  File.swift
//  
//
//  Created by Shotaro Hirano on 2022/09/14.
//

import UIKit

public protocol HeaderTabPageViewControllerDelegate: AnyObject {
    func didSelectTab(index: Int)
    func didChangeVisuableViewController(to viewController: UIViewController)
}
