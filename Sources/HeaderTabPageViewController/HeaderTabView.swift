//
//  File.swift
//  
//
//  Created by Shotaro Hirano on 2022/09/14.
//

import UIKit

public class HeaderTabView: UIView {
    public struct Item {
        public let name: String
        public init(name: String) {
            self.name = name
        }
    }
    
    private var items: [Item] = []
        
    public weak var delegate: HeaderTabViewDelegate?
        
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: HeaderTabPageViewController.headerTabItemWidth, height: HeaderTabPageViewController.headerTabViewHeight)
        layout.itemSize = CGSize(width: HeaderTabPageViewController.headerTabItemWidth, height: HeaderTabPageViewController.headerTabViewHeight)
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.register(HeaderTabViewCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        v.showsHorizontalScrollIndicator = false
        v.backgroundColor = .clear
        return v
    }()
        
        private let indicatorView: UIView = {
            let v = UIView()
            v.backgroundColor = HeaderTabPageViewController.labelSelectedColor
            v.frame = CGRect(x: 0, y: HeaderTabPageViewController.headerTabViewHeight - 2, width: HeaderTabPageViewController.headerTabItemWidth, height: 2)
            return v
        }()
        
        private let separatorView: UIView = {
            let v = UIView()
            v.backgroundColor = .systemGray
            return v
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .systemBackground
            addSubview(separatorView)
            addSubview(collectionView)
            collectionView.addSubview(indicatorView)
            collectionView.dataSource = self
            collectionView.delegate = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setUp(items: [Item]) {
            self.items = items
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
                self?.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
        
        func move(to index: Int) {
            let indexPath = IndexPath(row: index, section: 0)
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            UIView.animate(withDuration: 0.1) {
                self.indicatorView.frame = CGRect(x: HeaderTabPageViewController.headerTabItemWidth * CGFloat(index), y: HeaderTabPageViewController.headerTabViewHeight - 2, width: HeaderTabPageViewController.headerTabItemWidth, height: 2)
            }
            self.indicatorView.setNeedsLayout()
            self.indicatorView.layoutIfNeeded()
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            collectionView.frame = bounds
            separatorView.frame = CGRect(x: 0, y: HeaderTabPageViewController.headerTabViewHeight - 1, width: bounds.width, height: 1)
        }
}

extension HeaderTabView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HeaderTabViewCollectionViewCell
        cell.configureCell(text: items[indexPath.row].name)
        return cell
    }
}

extension HeaderTabView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.itemSelected(index: indexPath.row)
    }
}
