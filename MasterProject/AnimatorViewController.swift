//
//  CategoryFilterViewController.swift
//  CocoSoftIOSBaseApp
//
//  Created by Michael Rothkegel on 24.03.17.
//  Copyright © 2017 Invers GmbH. All rights reserved.
//

import UIKit

class AnimatorViewController: UIViewController {
    
    var testVar:CGFloat = 0
    
    var contentView:UIView!
    var animatorTableView:UITableView!
    var contentViewHeightConstraint:NSLayoutConstraint!
    var contentBottomConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        addPanToWholeView()
        animateHalfUp()
        
        
        let uiview2 = UIView(frame: CGRect(x: 100, y: -100, width: 300, height: 100))
        uiview2.backgroundColor = UIColor.yellow
        self.animatorTableView.tableHeaderView = uiview2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isDimissed?()
    }
    
    //MARK: VARS
    private var isDimissed: (() ->())?
    private var panGestureIsInUse = false
    
    private var _lastContentOffset: CGFloat = 0
    private var lastContentOffset: CGFloat {
        set {
            _lastContentOffset = newValue
        } get {
            return _lastContentOffset
        }
    }
    
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
        if animatorTableView.contentSize.height > (dynamicHeight-contentView.frame.height) {
            return true
        } else if animatorTableView.contentSize.height > dynamicHeight {
            return true
        }
        return true
    }
    
    
    //MARK: PAN GESTURE LOGIC
    /** add pan gesture to uiView*/
    private func addPanToWholeView() {
        let panRec = UIPanGestureRecognizer()
        panRec.addTarget(self, action: #selector(draggedView(_:)))
        panRec.delegate = self
        contentView.addGestureRecognizer(panRec)
        contentView.isUserInteractionEnabled = true
    }
    
    
    /** handle the drag - yeep */
    @objc func draggedView(_ sender:UIPanGestureRecognizer) {
        
        let relativeMovement = sender.translation(in: self.view)
        //print("relativeMovement.y \(relativeMovement.y)")
        switch sender.state {
            
        case .began: break
        //            print("began")
        case .changed:
            if isUp && screenHeightIsBiggerThanContentView() {
                moveDownFromFullScreenSize(y: relativeMovement.y)
            } else if !isUp && isAllowedToMoveViewUp(y: relativeMovement.y) {
                
                print("relativeMovement.y \(relativeMovement.y)")
                self.animatorTableView.tableHeaderView?.frame = CGRect(x: 0, y: -50, width: 0, height: 50)
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
        
        print("lastContentOffset \(lastContentOffset)")
        //tableView.isScrollEnabled = false
        isUp = false
        contentBottomConstraint.constant = 0
        contentViewHeightConstraint.constant = self.dynamicHeight
        animatorTableView.isScrollEnabled = false
        
        
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
        animatorTableView.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateDown() {
        isUp = false
        contentViewHeightConstraint.constant = self.dynamicHeight
        contentBottomConstraint.constant = -300
        animatorTableView.isScrollEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.hideViewController()
        }
    }
    
    func isTableViewScrollingEnabled() -> Bool {
        return animatorTableView.isScrollEnabled
    }
}


extension AnimatorViewController : UIScrollViewDelegate {
    //MARK: POSSIBLE SCROLLVIEW STATES for tableView
    func isTableViewScrollingAllowed() -> Bool {
        return allowTableViewScrolling
    }
    
    /** when user scroll really fast, y  (scrollView.contentOffset.y) can be really high. The tableView will bounce out of the screen  */
    func isUserScrollToFast(y: CGFloat) -> Bool {
        if (contentBottomConstraint.constant + (y-lastContentOffset)) < self.view.frame.height {
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
    
    //MARK: UISCROLLVIEW DELEGATE FUNCTIONS
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if lastContentOffset > 0 {
            allowTableViewScrolling = false
        } else {
            allowTableViewScrolling = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.contentOffset.y < 0 {
            lastContentOffset = 0
            animateHalfUp()
        }
        isInTableViewScrolling = false
        lastTableViewScrollingAction = ""
    }
}

extension AnimatorViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if lastContentOffset <= 0 {
            return true
        }
        return false
    }
}





