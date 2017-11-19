//
//  TestViewController.swift
//  MasterProject
//
//  Created by Michael Rothkegel on 17.11.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit

class TestViewController: AnimatorViewController {

   
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var customContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customContentViewBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.contentView = customContentView
        self.contentBottomConstraint = customContentViewBottomConstraint
        self.contentViewHeightConstraint = customContentViewHeightConstraint
        
        
    }

    

}
