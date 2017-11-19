//
//  CategoryFilterViewController.swift
//  CocoSoftIOSBaseApp
//
//  Created by Michael Rothkegel on 24.03.17.
//  Copyright © 2017 Invers GmbH. All rights reserved.
//

import UIKit

class AnimatorViewController: UIViewController {
    
    
    var contentViewHeightConstraint:NSLayoutConstraint!
    var contentView:UIView!
    var contentBottomConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        addPanToWholeView()
        animateHalfUp()
     }
    
    override func viewWillDisappear(_ animated: Bool) {
        isDimissed?()
    }
    
    override func viewDidLoad() {
     //   initTableView()
     //   addTableViewCells()
    }
    
    
    //MARK: VARS
    private var isDimissed: (() ->())?
    private var panGestureIsInUse = false
    
    private var lastContentOffset: CGFloat = 0
    private var dynamicHeight:CGFloat = 280.0
    private var heightOfFuelLevelFilter:CGFloat = 90.0
    
    var isUp = false
    var allowTableViewScrolling = false
    var isInTableViewScrolling = false
    var lastTableViewScrollingAction = ""
    
    //MARK: SOME INNER LOGIC
    private func hideViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func controllerNeedPanGesture() -> Bool {
//        if Model.sharedInstance().isFreeFloatingOnly() && tableView.contentSize.height > (defaultHeight-fuelLevelView.frame.height) {
//            return true
//        } else if tableView.contentSize.height > defaultHeight {
//            return true
//        }
        return true
    }
    
    
    //MARK: PAN GESTURE LOGIC
    /** add pan gesture to uiView*/
    private func addPanToWholeView() {
        let panRec = UIPanGestureRecognizer()
        panRec.addTarget(self, action: #selector(draggedView(_:)))
        contentView.addGestureRecognizer(panRec)
        contentView.isUserInteractionEnabled = true
    }
    
    
    /** handle the drag - yeep */
    @objc func draggedView(_ sender:UIPanGestureRecognizer) {
        
        let relativeMovement = sender.translation(in: self.view)
        print("relativeMovement.y \(relativeMovement.y)")
        switch sender.state {
            
        case .began: break
        //            print("began")
        case .changed:
            if isUp && screenHeightIsBiggerThanContentView() {
                moveDownFromFullScreenSize(y: relativeMovement.y)
            } else if !isUp && isAllowedToMoveViewUp(y: relativeMovement.y) {
                moveUp(y: relativeMovement.y)
            } else if isAllowedToMoveViewDown(y: relativeMovement.y)  {
                moveDownFromHalfScreenSize(y: relativeMovement.y)
            } else if isUp && gestureIsDown(y: relativeMovement.y) {
                moveDown(y: relativeMovement.y)
            }
            
        case .cancelled: break
        //            print("caneled")
        case .ended:
            //            print("is up is \(isUp)")
            
            if isUp {
                if isScreenUpAndUserPanOverOneQuarterScreenSizeDown(y: relativeMovement.y) {
                    animateDown()
                } else if isScreenUpAndUserScrollDownButNotEnoughToMakeDownAnimation(y: relativeMovement.y) {
                    animateUp()
                } else {
                    animateHalfUp()
                }
            } else {
                if isScreenHalfUpAndUserPanOverTheHalfOfScreenSizeUp() && controllerNeedPanGesture() {
                    animateUp()
                } else if isScreenHalfUpAndUserScrollUpButNotEnoughToMakeAUpAnimation(y: relativeMovement.y) {
                    animateHalfUp()
                }else if isScreenHalfUpAndUserPanGestureIsDown(y: relativeMovement.y) {
                    animateDown()
                } else {
                    animateHalfUp()
                }
            }
        //            print("ended")
        default:
            break
        }
    }
    
    private func screenHeightIsBiggerThanContentView() -> Bool {
        return contentViewHeightConstraint.constant < self.view.frame.height
    }
    
    private func gestureIsDown(y: CGFloat) -> Bool {
        return y > 0
    }
    
    //MARK: PAN VIEW REACTIONS
    private func moveUp(y: CGFloat) {
        contentViewHeightConstraint.constant = dynamicHeight - y
    }
    
    private func moveDown(y: CGFloat) {
        contentViewHeightConstraint.constant = self.view.frame.height - y
    }
    
    private func moveDownFromFullScreenSize(y: CGFloat) {
        contentViewHeightConstraint.constant = self.view.frame.height - y
    }
    
    private func moveDownFromHalfScreenSize(y: CGFloat) {
        contentViewHeightConstraint.constant = dynamicHeight - y
    }
    
    //MARK: POSSIBLE PAN STATES
    private func isAllowedToMoveViewDown(y: CGFloat) -> Bool {
        return y > 0 && contentViewHeightConstraint.constant < self.view.frame.height
    }
    
    private func isAllowedToMoveViewUp(y: CGFloat) -> Bool {
        return y < 0 && controllerNeedPanGesture()
    }
    
    private func isScreenHalfUpAndUserPanGestureIsDown(y: CGFloat) -> Bool {
        if y > dynamicHeight / 4 {
            return true
        }
        return false
    }
    
    private func isScreenHalfUpAndUserScrollUpButNotEnoughToMakeAUpAnimation(y: CGFloat) -> Bool {
        return y < 0 && y > -100 //TODO: sollte vllt kalkuliert werden aus Bildschirmgrößen - oder mit Stufen, sensitiv, mittel, sehr heftig
    }
    
    private func isScreenUpAndUserScrollDownButNotEnoughToMakeDownAnimation(y:CGFloat) -> Bool {
        return isUp && y < 100 //TODO: sollte vllt kalkuliert werden aus Bildschirmgrößen
    }
    
    private func isScreenUpAndUserPanOverOneQuarterScreenSizeDown(y: CGFloat) -> Bool {
        return y > self.view.frame.height / 2.5 && isUp
    }
    
    private func isScreenHalfUpAndUserPanOverTheHalfOfScreenSizeUp() -> Bool {
        return contentViewHeightConstraint.constant > self.view.frame.height / 2
    }
    
    
    //MARK: concret animation actions
    private func animateHalfUp() {
        
        //tableView.isScrollEnabled = false
        isUp = false
        contentBottomConstraint.constant = 0
        contentViewHeightConstraint.constant = self.dynamicHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            //            self.mapItemContentisDown = false
            //            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    private func animateUp() {
        isUp = true
        contentBottomConstraint.constant = 0
        contentViewHeightConstraint.constant = self.view.frame.height
        // tableView.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateDown() {
        isUp = false
        contentViewHeightConstraint.constant = self.dynamicHeight
        contentBottomConstraint.constant = -300
        //tableView.isScrollEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.hideViewController()
        }
    }
}
/*
extension CategoryFilterViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func isTableViewScrollingEnabled() -> Bool {
        return tableView.isScrollEnabled
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryCells.count
    }
    
    func sendPiwikTrackEvent(cell: CategoryCell, isSelected: Bool) {
        
        guard let id = cell.itemCategory?.categoryId else {
            return
        }
        
        guard let name = cell.itemCategory?.getName() else {
            return
        }
        
        if isSelected {
            Model.sharedInstance().piwikAnalyticsTrackEvent(.UX, action: .MapFilterChanged, label: "show \(id) \(name)", value: Constants.Analytics.number)
        } else {
            Model.sharedInstance().piwikAnalyticsTrackEvent(.UX, action: .MapFilterChanged, label: "hide \(id) \(name)", value: Constants.Analytics.number)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageLabelSwitchTableViewCell") as? ImageLabelSwitchTableViewCell {
            
            if indexPath.row < categoryCells.count {
                
                if let isSelected = categoryCells[indexPath.row].isSelected {
                    cell.switchUISwitch.isOn = isSelected
                    
                }
                
                
                
                if  let category = categoryCells[indexPath.row].itemCategory {
                    
                    Model.sharedInstance().getImageFromObject(object: category, imageView: cell.imageImageView, placeholder: R.image.ic_item_dummy())
                    
                    if let name = category.name {
                        cell.titleLabel.text = name
                    }
                    
                    var invisible = true
                    if let remark = self.categoryCells[indexPath.row].itemCategory?.remark {
                        if let name = self.categoryCells[indexPath.row].itemCategory?.name {
                            if !name.isEmpty && !remark.isEmpty {
                                invisible = false
                            }
                        }
                    }
                    cell.remarkButton.isHidden = invisible
                    
                    cell.callbackInfoButton = {
                        
                        if let remark = self.categoryCells[indexPath.row].itemCategory?.remark {
                            if let name = self.categoryCells[indexPath.row].itemCategory?.name {
                                Model.sharedInstance().showSimpleAlertWithTextNew(name, message: remark)
                            }
                        }
                    }
                    
                    
                    cell.callback = { bool in
                        
                        
                        if indexPath.row < self.categoryCells.count {
                            self.sendPiwikTrackEvent(cell: self.categoryCells[indexPath.row], isSelected: bool)
                            self.categoryCells[indexPath.row].isSelected = bool
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                            self.tableView.endUpdates()
                        }
                        
                        if let categoryId = category.categoryId {
                            if bool {
                                if !Model.sharedInstance().categoryIDsInFilter.contains(categoryId) {
                                    Model.sharedInstance().categoryIDsInFilter.append(categoryId)
                                }
                            } else {
                                if Model.sharedInstance().categoryIDsInFilter.contains(categoryId) {
                                    _ = Model.sharedInstance().categoryIDsInFilter.removeObject(categoryId)
                                }
                            }
                            self.refreshMapViewCallback?()
                            
                        }
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
}*/

/*
extension CategoryFilterViewController : UIScrollViewDelegate {
    //MARK: POSSIBLE SCROLLVIEW STATES for tableView
    func isTableViewScrollingAllowed() -> Bool {
        return allowTableViewScrolling
    }
    
    
    func isTouchingTheTopOfScreen() -> Bool {
        
        if filterViewHeightConstraint.constant >= self.view.frame.height {
            return true
        }
        
        return false
    }
    
    func isScrollingUp(y: CGFloat) -> Bool {
        if y-lastContentOffset > 0 {
            return true
        }
        return false
    }
    
    
    /** when user scroll really fast, y  (scrollView.contentOffset.y) can be really high. The tableView will bounce out of the screen  */
    func isUserScrollToFast(y: CGFloat) -> Bool {
        if (filterViewHeightConstraint.constant + (y-lastContentOffset)) < self.view.frame.height {
            return false
        }
        return true
    }
    
    func isScrollingDown(y: CGFloat) -> Bool {
        if y < 0 || lastContentOffset < 0 {
            return true
        }
        
        return false
    }
    
    
    //MARK: SCROLL VIEW REACTIONS
    func moveUpByTableViewScrolling(y: CGFloat) {
        filterViewHeightConstraint.constant = filterViewHeightConstraint.constant + (y-lastContentOffset)
    }
    
    func moveDownByTableViewScrolling(y: CGFloat) {
        filterViewHeightConstraint.constant = filterViewHeightConstraint.constant + y
    }
    
    
    
    //MARK: UISCROLLVIEW DELEGATE FUNCTIONS
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if lastContentOffset > 0 {
            allowTableViewScrolling = false
        } else {
            allowTableViewScrolling = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTableViewScrollingEnabled() && isTableViewScrollingAllowed() {
            if scrollView.contentOffset.y < 0 || isInTableViewScrolling {
                
                if isUp  {
                    if isScrollingDown(y: scrollView.contentOffset.y) {
                        lastTableViewScrollingAction = "down"
                        moveDownByTableViewScrolling(y: scrollView.contentOffset.y)
                    } else {
                        if isScrollingUp(y: scrollView.contentOffset.y) && !isTouchingTheTopOfScreen() {
                            if !isUserScrollToFast(y: scrollView.contentOffset.y) {
                                lastTableViewScrollingAction = "up"
                                moveUpByTableViewScrolling(y: scrollView.contentOffset.y)
                            }
                        }
                    }
                    isInTableViewScrolling = true
                }
            }
        }
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        //Das darf nur ausgeführt werden, wenn direkt von oben auf null gescrollt wurde
        if filterViewHeightConstraint.constant < self.view.frame.height-self.view.frame.height/3 {
            if lastTableViewScrollingAction == "up" {
                animateUp()
            } else {
                animateDown()
            }
        } else if filterViewHeightConstraint.constant < self.view.frame.height-85 {
            if lastTableViewScrollingAction == "up" {
                animateUp()
            } else {
                animateHalfUp()
            }
            
        } else {
            animateUp()
        }
        isInTableViewScrolling = false
        lastTableViewScrollingAction = ""
    }
}*/





