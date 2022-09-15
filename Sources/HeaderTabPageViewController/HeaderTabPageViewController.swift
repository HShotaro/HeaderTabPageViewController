import UIKit

open class HeaderTabPageViewController: UIViewController {
    private let labelDefaultColor: UIColor
    private let labelSelectedColor: UIColor
    private let headerTabViewHeight: CGFloat
    private let indicatorViewHeight: CGFloat
    private let headerTabViewMargin: CGFloat
    private let headerTabViewBgColor: UIColor
    
    private lazy var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var viewControllers: [UIViewController] = []
    private var tabView: HeaderTabView!
    
    public weak var delegate: HeaderTabPageViewControllerDelegate?
    
    public init(
        labelDefaultColor: UIColor = .label,
        labelSelectedColor: UIColor = .systemRed,
        headerTabViewHeight: CGFloat = 50,
        indicatorViewHeight: CGFloat = 2,
        headerTabViewMargin: CGFloat = 20,
        headerTabViewBgColor: UIColor = .systemBackground
    ) {
        self.labelDefaultColor = labelDefaultColor
        self.labelSelectedColor = labelSelectedColor
        self.headerTabViewHeight = headerTabViewHeight
        self.indicatorViewHeight = indicatorViewHeight
        self.headerTabViewMargin = headerTabViewMargin
        self.headerTabViewBgColor = headerTabViewBgColor
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tabView = HeaderTabView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: headerTabViewHeight)),
                                labelDefaultColor: labelDefaultColor,
                                labelSelectedColor: labelSelectedColor,
                                headerTabViewHeight: headerTabViewHeight,
                                indicatorViewHeight: indicatorViewHeight,
                                headerTabViewMargin: headerTabViewMargin,
                                headerTabViewBgColor: headerTabViewBgColor
        )
        view.addSubview(tabView)
        view.addSubview(pageViewController.view)
        
        self.tabView.delegate = self
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.subviews.compactMap { $0 as? UIScrollView }.first?.delegate = self
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabView.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.frame.width, height: headerTabViewHeight)
        pageViewController.view.frame = CGRect(x: 0, y: tabView.frame.maxY, width: view.frame.width, height: self.view.frame.height - tabView.frame.maxY)
    }
    
    public func setUp(tabGroups: [(vc: UIViewController, tabItem: String)], selectedIndex: Int = 0) {
        self.tabView.setUp(items: tabGroups.map { $0.tabItem }, initialIndex: selectedIndex)
        self.viewControllers = tabGroups.map { $0.vc }
        self.pageViewController.setViewControllers([viewControllers[selectedIndex]], direction: .forward, animated: false)
    }
    
    private func currentChildVCIndex() -> Int? {
        guard
            let currentVC = self.pageViewController.viewControllers?.first,
            let currentIndex =  self.viewControllers.firstIndex(of: currentVC)
        else { return nil }
        return currentIndex
    }
    
    private var initialDragModel: (pageIndex: Int, scrollViewOffSetX: CGFloat)?
    private var isMovingBySelecteingTabView = false
}

extension HeaderTabPageViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let currentIndex =  self.currentChildVCIndex(),
            currentIndex != 0
        else { return nil }
        return self.viewControllers[currentIndex - 1]
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let currentIndex =  self.currentChildVCIndex(),
            currentIndex != self.viewControllers.count - 1
        else { return nil }
        return self.viewControllers[currentIndex + 1]
    }
}

extension HeaderTabPageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.tabView.isUserInteractionEnabled = false
    }
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.initialDragModel = nil
        if finished,
           let newVC = pageViewController.viewControllers?.first,
           let newIndex =  self.viewControllers.firstIndex(of: newVC) {
            self.tabView.move(percent: CGFloat(newIndex) / max(1, CGFloat(viewControllers.count - 1)))
            self.delegate?.didChangeVisuableViewController(to: newVC)
        }
        self.tabView.isUserInteractionEnabled = true
    }
}

extension HeaderTabPageViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let pageIndex =  self.currentChildVCIndex() else { return }
        self.initialDragModel = (pageIndex: pageIndex, scrollViewOffSetX: scrollView.contentOffset.x)
    }
       
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isMovingBySelecteingTabView {
            self.initialDragModel = nil
        }
        guard let initialDragModel = self.initialDragModel else { return }
        let draggingX = scrollView.contentOffset.x - initialDragModel.scrollViewOffSetX
        let pageWidth = scrollView.frame.width
        let contentOffsetX = CGFloat(initialDragModel.pageIndex) * pageWidth + draggingX
        let percent =  contentOffsetX / ( pageWidth * CGFloat(viewControllers.count) - pageWidth)
        self.tabView.move(percent: percent)
    }
}

extension HeaderTabPageViewController: HeaderTabViewDelegate {
    public func itemSelected(index: Int) {
        guard let currentIndex =  self.currentChildVCIndex(),
              currentIndex != index
        else { return }
        delegate?.didSelectTab(index: index)
        self.view.isUserInteractionEnabled = false
        self.isMovingBySelecteingTabView = true
        self.tabView.move(percent: CGFloat(index) / max(1, CGFloat(viewControllers.count - 1))) { [weak self] in
            self?.isMovingBySelecteingTabView = false
        }
        let newVC = self.viewControllers[index]
        self.pageViewController.setViewControllers([newVC],
                                                   direction: currentIndex < index ? .forward : .reverse,
                                                   animated: true,
                                                   completion: { [weak self] _ in
            self?.view.isUserInteractionEnabled = true
            self?.delegate?.didChangeVisuableViewController(to: newVC)
        }
        )
    }
}

