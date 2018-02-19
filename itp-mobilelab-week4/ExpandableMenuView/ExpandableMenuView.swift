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
    @IBInspectable public var expandedBackgroundColor:UIColor = UIColor(white: 0, alpha: 1.0)
    @IBInspectable public var collapsedBackgroundColor:UIColor = UIColor.clear {
        didSet {
            didSetCollapsedBackgroundColor()
        }
    }
    @IBInspectable public var expandedLineColor:UIColor = UIColor.white
    @IBInspectable public var collapsedLineColor:UIColor = UIColor.black {
        didSet {
            didSetCollapsedLineColor()
        }
    }
    //*********************
    
    //MARK: Private
    
    //*** General ***
    private var collapsedContentSize: CGSize {
        return CGSize(width:44.0,height:64.0 + safeAreaInsets.top)
    }
    private var expandedContentSize: CGSize {
        guard let superview = superview else {
            return collapsedContentSize
        }
        
        return CGSize(width: superview.bounds.width, height: superview.bounds.height * expandedRelativeHeight)
    }
    //***************
    
    //*** IBOutlets ***
    @IBOutlet weak private var contentStackView: UIStackView?
    //
    @IBOutlet weak private var topLineView: UIView?
    @IBOutlet weak private var centerLineView: UIView?
    @IBOutlet weak private var bottomLineView: UIView?
    //
    @IBOutlet private var bottomLineExpandedWidthConstraint: NSLayoutConstraint?
    @IBOutlet private var bottomLineExpandedBottomConstraint: NSLayoutConstraint?
    //************
    
    private var contentControls: [UIControl] {
        return (contentStackView?.arrangedSubviews as? [UIControl]) ?? []
    }
    
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
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }
    
    //MARK: - Private methods
    //MARK: didSet
    private func didSetCurrentState() {
        refreshUI(animated: true)
    }
    
    private func didSetExpandedRelativeHeight() {
        expandedRelativeHeight = min(1.0, max(0.0, expandedRelativeHeight))
    }
    
    private func didSetCollapsedBackgroundColor() {
        refreshUI()
    }
    
    private func didSetCollapsedLineColor() {
        refreshUI()
    }

    //MARK: Init
    private func customInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = collapsedBackgroundColor
        self.topLineView?.backgroundColor = collapsedLineColor
        self.centerLineView?.backgroundColor = collapsedLineColor
        self.bottomLineView?.backgroundColor = collapsedLineColor
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
    private func refreshUI(animated: Bool = false) {
        refreshColors(animated: animated)
        refreshLines(animated: animated)
    }
    
    private func refreshColors(animated:Bool = false) {
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
        
        //*** LineColor ***
        func stateLineColor() -> UIColor {
            switch currentState {
            case .collapsed:
                return collapsedLineColor
            case .expanded:
                return expandedLineColor
            }
        }
        //***********************
        
        //*** ContentAlpha ***
        func stateContentAlpha() -> CGFloat {
            switch currentState {
            case .collapsed:
                return 0.0
            case .expanded:
                return 1.0
            }
        }
        //********************
        
        //*** Duration ***
        func duration() -> TimeInterval {
            guard animated else {
                return 0.0
            }
            
            switch currentState {
            case .collapsed:
                return 0.2
            case .expanded:
                return 0.5
            }
        }
        //****************
        
        //*** Delay ***
        func delay() -> TimeInterval {
            guard animated else {
                return 0.0
            }
            
            switch currentState {
            case .collapsed:
                return 0
            case .expanded:
                return 0.1
            }
        }
        //****************
        
        //
        UIView.animate(withDuration: duration(), delay: delay(), options: .curveEaseOut, animations: {
            self.backgroundColor = stateBackgroundColor()
            self.topLineView?.backgroundColor = stateLineColor()
            self.centerLineView?.backgroundColor = stateLineColor()
            self.bottomLineView?.backgroundColor = stateLineColor()
        }, completion: nil)
        
        UIView.animate(withDuration: duration()/2, delay: 0.0, options: .curveEaseOut, animations: {
            self.contentStackView?.alpha = stateContentAlpha()
            for control in self.contentControls {
                control.tintColor = stateLineColor()
            }
        }, completion: nil)
    }
    
    private func refreshLines(animated:Bool = false) {
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
        
        //*** Damping ***
        func damping() -> CGFloat {
            switch currentState {
            case .collapsed:
                return 0.85
            case .expanded:
                return 0.77
            }
        }
        //***************
        
        //*** Duration ***
        func duration() -> TimeInterval {
            guard animated else {
                return 0.0
            }
            
            switch currentState {
            case .collapsed:
                return 0.6
            case .expanded:
                return 0.65
            }
        }
        //****************
        
        //
        UIView.animate(withDuration: duration(), delay: 0, usingSpringWithDamping: damping(), initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.topLineView?.transform = topLineTransform()
            self.centerLineView?.transform = centerLineTransform()
            self.bottomLineExpandedWidthConstraint?.isActive = self.currentState == .expanded
            self.bottomLineExpandedBottomConstraint?.isActive = self.currentState == .expanded
            self.invalidateIntrinsicContentSize()
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
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
