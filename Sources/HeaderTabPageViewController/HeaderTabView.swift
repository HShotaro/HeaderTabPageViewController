//
//  File.swift
//  
//
//  Created by Shotaro Hirano on 2022/09/14.
//

import UIKit

public class HeaderTabView: UIView {
    private var buttonViews: [HeaderTabButtonItemView] = []
    
    public weak var delegate: HeaderTabViewDelegate?
    
    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.backgroundColor = .clear
        v.isScrollEnabled = true
        return v
    }()
    
    private var scrollViewContentSize: CGSize = .zero
    
    private lazy var indicatorView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = labelSelectedColor
        return v
    }()
    
    private let separatorView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = .systemGray
        return v
    }()
    
    private var currentIndicatorIndex: CGFloat = 0 {
        didSet {
            guard Int(oldValue.rounded()) != Int(currentIndicatorIndex.rounded()) else {
                return
            }
            for i in 0 ..< buttonViews.count {
                buttonViews[i].isSelected = Int(currentIndicatorIndex.rounded()) == buttonViews[i].button.tag
            }
        }
    }
    
    private let labelDefaultColor: UIColor
    private let labelSelectedColor: UIColor
    private let headerTabViewHeight: CGFloat
    private let indicatorViewHeight: CGFloat
    private let headerTabViewMargin: CGFloat
    
    public init(frame: CGRect,
                labelDefaultColor: UIColor,
                labelSelectedColor: UIColor,
                headerTabViewHeight: CGFloat,
                indicatorViewHeight: CGFloat,
                headerTabViewMargin: CGFloat
    ) {
        self.labelDefaultColor = labelDefaultColor
        self.labelSelectedColor = labelSelectedColor
        self.headerTabViewHeight = headerTabViewHeight
        self.indicatorViewHeight = indicatorViewHeight
        self.headerTabViewMargin = headerTabViewMargin
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(separatorView)
        addSubview(scrollView)
        scrollView.addSubview(indicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(items: [String], initialIndex: Int) {
        self.scrollView.subviews.forEach { v in
            if v is HeaderTabButtonItemView {
                v.removeFromSuperview()
            }
        }
        self.buttonViews = {
            return items.enumerated().map { (index, title) in
                let v = HeaderTabButtonItemView(
                    title: title,
                    isSelected: index == initialIndex,
                    tag: index,
                    labelDefaultColor: labelDefaultColor,
                    labelSelectedColor: labelSelectedColor,
                    headerTabViewMargin: headerTabViewMargin
                )
                return v
            }
        }()
        
        for i in 0 ..< buttonViews.count {
            buttonViews[i].button.addTarget(self, action:  #selector(didSelect(_:)), for: .touchUpInside)
            self.scrollView.addSubview(buttonViews[i])
        }
        
        setButtonViewsFrame()
        self.currentIndicatorIndex = CGFloat(initialIndex)
        setIndicatorViewFrame()
        
        let scrollViewContentWidth: CGFloat = buttonViews.reduce(0) { result, buttonView in
            return result + buttonView.contentWidth
        }
        scrollViewContentSize = CGSize(width: scrollViewContentWidth, height: headerTabViewHeight)
        self.scrollView.contentSize = scrollViewContentSize
        self.scrollItemToCenter(animated: false)
        
        layoutIfNeeded()
        setNeedsLayout()
        
    }
    
    @objc func didSelect(_ sender: UIButton) {
        self.delegate?.itemSelected(index: sender.tag)
    }
    
    
    public func move(percent: CGFloat, completion: (() -> ())? = nil) {
        self.currentIndicatorIndex = max(0.0, min(1.0, percent)) * CGFloat(buttonViews.count - 1)
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.setIndicatorViewFrame()
            self?.indicatorView.setNeedsLayout()
            self?.indicatorView.layoutIfNeeded()
        } completion: { [weak self] finished in
            if finished {
                self?.scrollItemToCenter(animated: true)
                completion?()
            }
        }
    }
    
    private func scrollItemToCenter(animated: Bool) {
        var newContentOffsetX: CGFloat = indicatorView.frame.minX - max((self.frame.width - indicatorView.frame.width), 0) / 2
        switch newContentOffsetX {
        case -self.frame.width..<0:
            newContentOffsetX = 0
        case (scrollViewContentSize.width - self.frame.width)..<scrollViewContentSize.width:
            newContentOffsetX = scrollViewContentSize.width - self.frame.width
        default:
            break
        }
        scrollView.setContentOffset(CGPoint(x: newContentOffsetX, y: 0), animated: animated)
    }
    
    private func setButtonViewsFrame() {
        guard !scrollView.subviews.filter({ $0 is HeaderTabButtonItemView }).isEmpty else { return }
        var nextX: CGFloat = 0
        for i in 0 ..< buttonViews.count {
            buttonViews[i].frame = CGRect(x: nextX, y: 0, width: buttonViews[i].contentWidth, height: headerTabViewHeight - indicatorViewHeight)
            nextX += buttonViews[i].contentWidth
        }
    }
    
    private func setIndicatorViewFrame() {
        guard !scrollView.subviews.filter({ $0 is HeaderTabButtonItemView }).isEmpty else { return }
        let buttonLeftX = buttonViews[0..<Int(floor(currentIndicatorIndex))].reduce(0) { result, buttonView in
            return result + buttonView.contentWidth
        }
        let buttonLeft = buttonViews[Int(floor(currentIndicatorIndex))]
        let ratio: CGFloat = currentIndicatorIndex - floor(currentIndicatorIndex)
        let indicatorWidth: CGFloat = {
            guard ratio > 0.01 else {
                return buttonViews[Int(floor(currentIndicatorIndex))].contentWidth
            }
            return ratio * buttonViews[Int(ceil(currentIndicatorIndex))].contentWidth + (1.0 - ratio) * buttonViews[Int(floor(currentIndicatorIndex))].contentWidth
        }()
        let indicatorX: CGFloat = buttonLeftX + buttonLeft.contentWidth * ratio
        
        indicatorView.frame = CGRect(x: indicatorX, y: headerTabViewHeight - indicatorViewHeight, width: indicatorWidth, height: indicatorViewHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        separatorView.frame = CGRect(x: 0, y: headerTabViewHeight - 1, width: bounds.width, height: 1)
        setButtonViewsFrame()
        setIndicatorViewFrame()
    }
}

