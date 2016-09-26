//
//  RootViewController.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 24.09.16.
//
//

import UIKit
import RxSwift

class RootViewController: UISplitViewController, UISplitViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool{
        return true
    }
    
    

}
