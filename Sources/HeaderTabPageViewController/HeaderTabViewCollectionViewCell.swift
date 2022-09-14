//
//  File.swift
//  
//
//  Created by Shotaro Hirano on 2022/09/14.
//

import UIKit

public class HeaderTabViewCollectionViewCell: UICollectionViewCell {
    private lazy var label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = HeaderTabPageViewController.labelDefaultColor
        l.textAlignment = .center
        return l
    }()
    
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? HeaderTabPageViewController.labelSelectedColor : HeaderTabPageViewController.labelDefaultColor
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    public func configureCell(text: String) {
        self.label.text = text
    }
}
