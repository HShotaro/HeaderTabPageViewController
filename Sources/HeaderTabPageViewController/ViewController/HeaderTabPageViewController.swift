import UIKit

/// subclass of UIViewControoler with pageViewController and selectable tabs which can change the current page.
open class HeaderTabPageViewController: UIViewController {
    private let labelDefaultColor: UIColor
    private let labelSelectedColor: UIColor
    private let headerTabViewHeight: CGFloat
    private let indicatorViewHeight: CGFloat
    private let headerTabViewMargin: CGFloat
    private let headerTabViewBgColor: UIColor
    private let fontSize: CGFloat
    
    private lazy var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var tabView: HeaderTabView!

    private var visibleVCForDelegateEvent: UIViewController? {
        didSet {
            guard let visibleVCForDelegateEvent = visibleVCForDelegateEvent,
                  visibleVCForDelegateEvent != oldValue else {
                return
            }
            delegate?.didChangeVisuableViewController(to: visibleVCForDelegateEvent)
        }
    }
    
    internal weak var delegate: HeaderTabPageViewControllerDelegate?

    /// - Parameters:
    ///   - labelDefaultColor: The color which is used when isSelcted status of tabItemView equal false
    ///   - labelSelectedColor:  The color which is used when isSelcted status of tabItemView equal true
    ///   - headerTabViewHeight:  The height of tab view
    ///   - indicatorViewHeight:  The height of indicator
    ///   - headerTabViewMargin:  The margin between a tab item view and net tab item view
    ///   - headerTabViewBgColor: The background color of tab view
    ///   - fontSize: the font size of title
    public init(
        labelDefaultColor: UIColor = .label,
        labelSelectedColor: UIColor = .systemRed,
        headerTabViewHeight: CGFloat = 50,
        indicatorViewHeight: CGFloat = 2,
        headerTabViewMargin: CGFloat = 20,
        headerTabViewBgColor: UIColor = .systemBackground,
        fontSize: CGFloat = 14
    ) {
        self.labelDefaultColor = labelDefaultColor
        self.labelSelectedColor = labelSelectedColor
        self.headerTabViewHeight = headerTabViewHeight
        self.indicatorViewHeight = indicatorViewHeight
        self.headerTabViewMargin = headerTabViewMargin
        self.headerTabViewBgColor = headerTabViewBgColor
        self.fontSize = fontSize
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
                                headerTabViewBgColor: headerTabViewBgColor,
                                fontSize: fontSize
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
    
    private func currentChildVCIndex() -> Int? {
        guard
            let currentVC = self.pageViewController.viewControllers?.first,
            let currentIndex =  self.viewControllers.firstIndex(of: currentVC)
        else { return nil }
        return currentIndex
    }

    private func setVisuableViewController(index: Int) {
        guard let currentIndex =  self.currentChildVCIndex(),
              currentIndex != index
        else { return }
        delegate?.didSelectTab(index: index)
        self.view.isUserInteractionEnabled = false
        self.isPageVCMovingBySelecteingTab = true
        self.tabView.move(percent: CGFloat(index) / max(1, CGFloat(viewControllers.count - 1))) { [weak self] in
            self?.isPageVCMovingBySelecteingTab = false
        }
        let newVC = self.viewControllers[index]
        self.pageViewController.setViewControllers([newVC],
                                                   direction: currentIndex < index ? .forward : .reverse,
                                                   animated: true,
                                                   completion: { [weak self] _ in
            self?.view.isUserInteractionEnabled = true
            self?.visibleVCForDelegateEvent = newVC
        }
        )
    }
    
    private var initialDragModel: (pageIndex: Int, scrollViewOffSetX: CGFloat)?
    private var isPageVCMovingBySelecteingTab = false


    // MARK: Public
    /// viewControllers which pageViewController contains
    public var viewControllers: [UIViewController] = []

    /// set the list of viewController and tab title.
    /// then display viewController which matches the selectedIndex
    /// - Parameters:
    ///   - tabGroups: tuple of viewController and tab title of corresponding viewController
    ///   - selectedIndex: the index of first visible viewController
    public func setUp(tabGroups: [(vc: UIViewController, tabItem: String)], selectedIndex: Int = 0) {
        self.tabView.setUp(items: tabGroups.map { $0.tabItem }, initialIndex: selectedIndex)
        self.viewControllers = tabGroups.map { $0.vc }
        self.pageViewController.setViewControllers([viewControllers[selectedIndex]], direction: .forward, animated: false)
    }

    /// viewController which is displayed
    public var currentViewController: UIViewController? {
        pageViewController.viewControllers?.first
    }
    /// the index of viewController which is displayed
    public var currentIndex: Int? {
        currentChildVCIndex()
    }
    /// move to viewController which matches the specified index
    /// - Parameters:
    ///   - index: index matching viewController which will display 
    public func move(to index: Int) {
        self.setVisuableViewController(index: index)
    }
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
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.initialDragModel = nil
        if completed,
           let newVC = pageViewController.viewControllers?.first,
           let newIndex =  self.viewControllers.firstIndex(of: newVC) {
            self.tabView.move(percent: CGFloat(newIndex) / max(1, CGFloat(viewControllers.count - 1)))
            self.visibleVCForDelegateEvent = newVC
        }
    }
}

extension HeaderTabPageViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let pageIndex =  self.currentChildVCIndex() else { return }
        self.initialDragModel = (pageIndex: pageIndex, scrollViewOffSetX: scrollView.contentOffset.x)
        self.tabView.isUserInteractionEnabled = false
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.tabView.isUserInteractionEnabled = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isPageVCMovingBySelecteingTab {
            self.initialDragModel = nil
        }
        guard let initialDragModel = self.initialDragModel else { return }
        let draggingX = scrollView.contentOffset.x - initialDragModel.scrollViewOffSetX
        let pageWidth = scrollView.frame.width
        let contentOffsetX = CGFloat(initialDragModel.pageIndex) * pageWidth + draggingX
        let percent =  contentOffsetX / ( pageWidth * CGFloat(viewControllers.count) - pageWidth)
        if percent < 0.0 || percent > 1.0 {
            self.initialDragModel = nil
            self.tabView.move(percent: floor(percent))
            return
        }
        self.tabView.move(percent: percent)
    }
}

extension HeaderTabPageViewController: HeaderTabViewDelegate {
    public func itemSelected(index: Int) {
        self.setVisuableViewController(index: index)
    }
}

