//
//  File.swift
//  
//
//  Created by Shotaro Hirano on 2022/09/15.
//

import UIKit

internal class HeaderTabButtonItemView: UIView {
    internal let button: UIButton = {
        let b = UIButton()
        b.backgroundColor = .clear
        return b
    }()
    internal var isSelected: Bool {
        didSet {
            guard (isSelected != oldValue) else {
                return
            }
            button.isSelected = isSelected
            titleLabel.textColor = isSelected ? labelSelectedColor : labelDefaultColor
            titleLabel.font = .systemFont(ofSize: fontSize, weight: isSelected ? .bold : .regular)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: fontSize)
        l.textColor = labelDefaultColor
        l.textAlignment = .center
        return l
    }()
    
    internal var contentWidth: CGFloat!
    
    private let labelDefaultColor: UIColor
    private let labelSelectedColor: UIColor
    private let headerTabViewMargin: CGFloat
    private let fontSize: CGFloat

    internal init(
        title: String,
        isSelected: Bool,
        tag: Int,
        labelDefaultColor: UIColor,
        labelSelectedColor: UIColor,
        headerTabViewMargin: CGFloat,
        fontSize: CGFloat
    ) {
        self.isSelected = isSelected
        self.labelDefaultColor = labelDefaultColor
        self.labelSelectedColor = labelSelectedColor
        self.headerTabViewMargin = headerTabViewMargin
        self.fontSize = fontSize
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.button.tag = tag
        button.isSelected = isSelected
        titleLabel.textColor = isSelected ? labelSelectedColor : labelDefaultColor
        titleLabel.font = .systemFont(ofSize: fontSize, weight: isSelected ? .bold : .regular)
        addSubview(titleLabel)
        addSubview(button)
        
        self.contentWidth = self.titleLabel.intrinsicContentSize.width + headerTabViewMargin
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = self.bounds
        titleLabel.frame = self.bounds
    }
}
