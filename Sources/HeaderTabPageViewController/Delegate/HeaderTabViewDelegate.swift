//
//  File.swift
//  
//
//  Created by Shotaro Hirano on 2022/09/14.
//

import Foundation
/// The methods adopted by the object you use to manage HeaderTabView  status
public protocol HeaderTabViewDelegate: AnyObject {
    /// Tells the delegate that  user selected the specified tab
    func itemSelected(index : Int)
}
