//
//  File.swift
//  
//
//  Created by Shotaro Hirano on 2022/09/15.
//

import UIKit

public class HeaderTabButtonItemView: UIView {
    public let button: UIButton = {
        let b = UIButton()
        b.backgroundColor = .clear
        return b
    }()
    public var isSelected: Bool {
        didSet {
            guard (isSelected != oldValue) else {
                return
            }
            button.isSelected = isSelected
            titleLabel.textColor = isSelected ? labelSelectedColor : labelDefaultColor
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = labelDefaultColor
        l.textAlignment = .center
        return l
    }()
    
    public var contentWidth: CGFloat!
    
    private let labelDefaultColor: UIColor
    private let labelSelectedColor: UIColor
    private let headerTabViewMargin: CGFloat
    
    public init(
        title: String,
        isSelected: Bool,
        tag: Int,
        labelDefaultColor: UIColor,
        labelSelectedColor: UIColor,
        headerTabViewMargin: CGFloat
    ) {
        self.isSelected = isSelected
        self.labelDefaultColor = labelDefaultColor
        self.labelSelectedColor = labelSelectedColor
        self.headerTabViewMargin = headerTabViewMargin
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.button.tag = tag
        button.isSelected = isSelected
        titleLabel.textColor = isSelected ? labelSelectedColor : labelDefaultColor
        addSubview(titleLabel)
        addSubview(button)
        
        self.contentWidth = self.titleLabel.intrinsicContentSize.width + headerTabViewMargin
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = self.bounds
        titleLabel.frame = self.bounds
    }
}
