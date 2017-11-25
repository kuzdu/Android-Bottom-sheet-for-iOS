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
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView = customContentView
        self.contentBottomConstraint = customContentViewBottomConstraint
        self.contentViewHeightConstraint = customContentViewHeightConstraint
        self.animatorTableView = tableView
        self.dynamicHeight = 80
        self.imageHeight = 80
        initTableView()
    }
    
}

extension TestViewController : UITableViewDelegate, UITableViewDataSource {

    
    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 66
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TestIdent") as? ExampleInputTableViewCell {
            return cell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    
}
