//
//  ExpandableMenuControl.swift
//  itp-mobilelab-week4
//
//  Created by Diego Cruz on 2/17/18.
//  Copyright © 2018 Diego Cruz. All rights reserved.
//

import UIKit

@IBDesignable
class ExpandableMenuView: UIView {

    //MARK: - Properties
    //MARK: Public
    
    //*** General ***
    public enum State {
        case collapsed
        case expanded
    }
    public private(set) var currentState: State = .collapsed {
        didSet{
            didSetCurrentState()
        }
    }
    override var intrinsicContentSize: CGSize{
        switch currentState {
        case .collapsed:
            return collapsedContentSize
        case .expanded:
            return expandedContentSize
        }
    }
    //***************
    
    //*** IBInspectable ***
    @IBInspectable public var expandedRelativeHeight: CGFloat = 0.7 {
        didSet {
            didSetExpandedRelativeHeight()
        }
    }
    @IBInspectable public var expandedBackgroundColor: UIColor = UIColor(white: 0.97, alpha: 1.0)
    //*********************
    
    //MARK: Private
    
    //*** General ***
    private var collapsedContentSize: CGSize {
        return CGSize(width:44.0,height:64.0)
    }
    private var expandedContentSize: CGSize {
        guard let superview = superview else {
            return collapsedContentSize
        }
        
        return CGSize(width: superview.bounds.width, height: superview.bounds.height * expandedRelativeHeight)
    }
    private let collapsedBackgroundColor = UIColor.clear
    //***************
    
    //*** Icon ***
    @IBOutlet private var topLineView: UIView?
    @IBOutlet private var centerLineView: UIView?
    @IBOutlet private var bottomLineView: UIView?
    //************
    
    //MARK: - Public methods
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    //MARK: - Private methods
    //MARK: didSet
    private func didSetCurrentState() {
        refreshUI()
    }
    
    private func didSetExpandedRelativeHeight() {
        expandedRelativeHeight = min(1.0, max(0.0, expandedRelativeHeight))
    }

    //MARK: Init
    private func customInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        initContentView()
    }
    
    private func initContentView() {
        //*** View From Nib ***
        func viewFromNib() -> UIView? {
            return Bundle(for: type(of: self)).loadNibNamed("ExpandableMenuView", owner: self, options: nil)?.first as? UIView
        }
        //*********************
        
        //
        //Init
        guard let contentView = viewFromNib() else {
            return
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView);
        //Constraints
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    //MARK: Actions
    @IBAction private func toggleButtonDidPress(sender: UIControl) {
        toggleState()
    }
    
    //MARK: UI
    private func refreshUI() {
        refreshBackgroundColor()
        refreshLines()
    }
    
    private func refreshBackgroundColor() {
        //*** BackgroundColor ***
        func stateBackgroundColor() -> UIColor {
            switch currentState {
            case .collapsed:
                return collapsedBackgroundColor
            case .expanded:
                return expandedBackgroundColor
            }
        }
        //***********************
        
        //
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
            self.backgroundColor = stateBackgroundColor()
        }, completion: nil)
    }
    
    private func refreshLines() {
        guard let superview = superview else {
            return
        }
        
        //*** TopLine transform ***
        func topLineTransform() -> CGAffineTransform{
            switch currentState {
            case .collapsed:
                return CGAffineTransform.identity
            case .expanded:
                let scaleTransform = CGAffineTransform(rotationAngle: CGFloat.pi/4)
                let traslationTransform = CGAffineTransform(translationX: 0, y: (centerLineView?.frame.maxY ?? 0.0) - (topLineView?.frame.maxY ?? 0.0))
                return scaleTransform.concatenating(traslationTransform)
            }
        }
        //*************************
        
        //*** CenterLine transform ***
        func centerLineTransform() -> CGAffineTransform{
            switch currentState {
            case .collapsed:
                return CGAffineTransform.identity
            case .expanded:
                return CGAffineTransform(rotationAngle: -CGFloat.pi/4)
            }
        }
        //****************************
        
        //*** BottomLine transform ***
        func bottomLineTransform() -> CGAffineTransform{
            switch currentState {
            case .collapsed:
                return CGAffineTransform.identity
            case .expanded:
                let scaleTransform = CGAffineTransform(scaleX: superview.bounds.width/(bottomLineView?.bounds.width ?? 1.0), y: 1)
                let traslationTransform = CGAffineTransform(translationX: 0, y: (intrinsicContentSize.height) - (bottomLineView?.frame.maxY ?? 0.0))
                return scaleTransform.concatenating(traslationTransform)
            }
        }
        //****************************
        
        //
        let damping:CGFloat = currentState == .collapsed ? 0.85 : 0.7
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.topLineView?.transform = topLineTransform()
            self.centerLineView?.transform = centerLineTransform()
            self.bottomLineView?.transform = bottomLineTransform()
            self.invalidateIntrinsicContentSize()
        }, completion: nil)
    }
    
    //MARK: Util
    private func toggleState() {
        switch currentState {
        case .collapsed:
            currentState = .expanded
        case .expanded:
            currentState = .collapsed
        }
    }
}
