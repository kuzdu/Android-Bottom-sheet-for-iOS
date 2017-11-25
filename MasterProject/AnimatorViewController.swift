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
    
    var withImageView = true
    
    
    private var headerViewTopConstraint: NSLayoutConstraint!
    private var uiview2: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        addPanToWholeView()
        initImageView()
        animateToHalf()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isDimissed?()
    }
    
    override func viewDidLoad() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func initImageView() {
        
        if withImageView {
            print("self.view.frame.height-theConstantHeight \(self.view.frame.height-dynamicHeight)")
            uiview2 = UIView() //UIView(frame: CGRect(x: 0, y: self.view.frame.height-theConstantHeight, width: self.view.frame.width, height: theConstantHeight))
            uiview2.backgroundColor = UIColor.yellow
            //        let imageView = UIImageView(frame: CGRect(x: uiview2.frame.minX, y: uiview2.frame.minY, width: uiview2.frame.width, height: uiview2.frame.height))
            //        imageView.image = UIImage(named: "restaurant")
            //        imageView.contentMode = .scaleAspectFill
            //        //imageView.sizeToFit()
            //        imageView.clipsToBounds = true
            //        uiview2.addSubview(imageView)s
            uiview2.translatesAutoresizingMaskIntoConstraints = false
            
            
            self.view.addSubview(uiview2)
            
            let trailingConstraint = NSLayoutConstraint(item: uiview2, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
            let leadingConstraint = NSLayoutConstraint(item: uiview2, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
            headerViewTopConstraint = NSLayoutConstraint(item: uiview2, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: uiview2, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: imageHeight)
            view.addConstraints([trailingConstraint, leadingConstraint, headerViewTopConstraint,heightConstraint])
        }
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
    
    var dynamicHeight:CGFloat = 280.0
    var imageHeight:CGFloat = 200
    private var heightOfFuelLevelFilter:CGFloat = 90.0
    
    var isUp = false
    var isUpWithImage = false
    
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
    
    
    func moveUpOverImageView(y: CGFloat) {
        contentViewHeightConstraint.constant = self.view.frame.height - dynamicHeight - y
    }
    //TODO: moveDownWithImageView und moveUpOverImageView kann evtl. zusammengefasst werden
    func moveDownWithImageView(y: CGFloat) {
        headerViewTopConstraint.constant = y * 2
        contentViewHeightConstraint.constant = self.view.frame.height - dynamicHeight - y
    }
    
    /** handle the drag - yeep */
    @objc func draggedView(_ sender:UIPanGestureRecognizer) {
        
        let relativeMovement = sender.translation(in: self.view)
        //print("relativeMovement.y \(relativeMovement.y)")
        switch sender.state {
            
        case .began: break
        //            print("began")
        case .changed:
            
            if isUpWithImage && screenHeightIsBiggerThanContentView() && !gestureIsDown(y: relativeMovement.y) {
                moveUpOverImageView(y: relativeMovement.y)
            } else if isUpWithImage && gestureIsDown(y: relativeMovement.y) {
                moveDownWithImageView(y: relativeMovement.y)
            } else if isUp && screenHeightIsBiggerThanContentView() {
                moveDownFromFullScreenSize(y: relativeMovement.y)
            } else if !isUp && isAllowedToMoveViewUp(y: relativeMovement.y) {
                animatorTableView.reloadData()
                moveUp(y: relativeMovement.y)
            } else if isAllowedToMoveViewDown(y: relativeMovement.y) && !isUpWithImage  {
                moveDownFromHalfScreenSize(y: relativeMovement.y)
            } else if isUp && gestureIsDown(y: relativeMovement.y) {
                moveDown(y: relativeMovement.y)
            }
            
        case .cancelled: break
        case .ended:
            if isUp {
                if isScreenUpAndUserPanOverOneQuarterScreenSizeDown(y: relativeMovement.y) {
                    animateDown()
                } else if isScreenUpAndUserScrollDownButNotEnoughToMakeDownAnimation(y: relativeMovement.y) {
                    animateUpAction()
                } else {
                    animateToHalf()
                }
            } else {
                if isScreenHalfUpAndUserPanOverTheHalfOfScreenSizeUp() && controllerNeedPanGesture() {
                    animateUpAction()
                } else if isScreenHalfUpAndUserScrollUpButNotEnoughToMakeAUpAnimation(y: relativeMovement.y) {
                    animateToHalf()
                }else if isScreenHalfUpAndUserPanGestureIsDown(y: relativeMovement.y) {
                    animateDown()
                } else {
                    animateToHalf()
                }
            }
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

        //TODO: wenn es zu klein ist geht es drüber hinweg
        
        if withImageView {
            if headerViewTopConstraint.constant < 0 {
                headerViewTopConstraint.constant = 0
            } else {
                headerViewTopConstraint.constant = self.view.frame.height - dynamicHeight + (y*(self.view.frame.height / dynamicHeight))
            }
        }
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
    private func animateToHalf() {
        
        print("lastContentOffset \(lastContentOffset)")
        
        isUpWithImage = false
        isUp = false
        contentBottomConstraint.constant = 0
        contentViewHeightConstraint.constant = dynamicHeight
        
        if withImageView {
            headerViewTopConstraint.constant = self.view.frame.height-dynamicHeight
        }
        
        animatorTableView.isScrollEnabled = false
        
        
       
        UIView.animate(withDuration: 0.3, animations: {
            
//        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
           
            self.view.bringSubview(toFront: self.animatorTableView)
            if self.withImageView {
                self.view.sendSubview(toBack: self.uiview2)
            }
        }
    }
    
    
    private func animateUpImageIsVisible() {
        contentViewHeightConstraint.constant = self.view.frame.height - dynamicHeight
        animatorTableView.isScrollEnabled = false
        headerViewTopConstraint.constant = 0 //emptySpaceInScreen
        isUpWithImage = true
    }
    
    private func animateUpImageIsInvisible() {
        isUp = true
        contentViewHeightConstraint.constant = self.view.frame.height
        animatorTableView.isScrollEnabled = true
    }
    
    private func animateUpAction() {
        
        contentBottomConstraint.constant = 0
     
        if withImageView {
            animateUpImageIsVisible()
        } else {
            animateUpImageIsInvisible()
        }
        animatorTableView.reloadData()
        
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
        print("end dragging")
        if scrollView.contentOffset.y < 0 {
            lastContentOffset = 0
            animateToHalf()
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





