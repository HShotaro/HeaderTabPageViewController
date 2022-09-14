import UIKit

open class HeaderTabPageViewController: UIViewController {
    static var labelDefaultColor: UIColor = .label
    static var labelSelectedColor: UIColor = .systemRed
    static var headerTabViewHeight: CGFloat = 50
    static var headerTabItemWidth: CGFloat = 100
    
    private let pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var viewControllers: [UIViewController] = []
    private var tabView: HeaderTabView = HeaderTabView(frame: .zero)
    
    public weak var delegate: HeaderTabPageViewControllerDelegate?
    
    public init(
        labelDefaultColor: UIColor? = nil,
        labelSelectedColor: UIColor? = nil,
        headerTabViewHeight: CGFloat? = nil,
        headerTabItemWidth: CGFloat? = nil
    ) {
        super.init(nibName: nil, bundle: nil)
        if let labelDefaultColor = labelDefaultColor {
            HeaderTabPageViewController.labelDefaultColor = labelDefaultColor
        }
        if let labelSelectedColor = labelSelectedColor {
            HeaderTabPageViewController.labelSelectedColor = labelSelectedColor
        }
        if let headerTabViewHeight = headerTabViewHeight {
            HeaderTabPageViewController.headerTabViewHeight = headerTabViewHeight
        }
        if let headerTabItemWidth = headerTabItemWidth {
            HeaderTabPageViewController.headerTabItemWidth = headerTabItemWidth
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tabView)
        view.addSubview(pageViewController.view)
        
        self.tabView.delegate = self
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let statusBarHeight: CGFloat = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let navigationBarHeight: CGFloat = self.navigationController?.navigationBar.frame.height ?? 0
        let tabViewY = statusBarHeight + navigationBarHeight
        tabView.frame = CGRect(x: 0, y: tabViewY, width: self.view.frame.width, height: HeaderTabPageViewController.headerTabViewHeight)
        let pageVCY = tabView.frame.origin.y + tabView.frame.height
        pageViewController.view.frame = CGRect(x: 0, y: pageVCY, width: view.frame.width, height: self.view.frame.height - pageVCY)
    }
    
    public func setUp(tabGroups: [(vc: UIViewController, tabItem: HeaderTabView.Item)], selectedIndex: Int = 0) {
        self.tabView.setUp(items: tabGroups.map { $0.tabItem })
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
        if let newVC = pageViewController.viewControllers?.first,
           let newIndex =  self.viewControllers.firstIndex(of: newVC) {
            self.tabView.move(to: newIndex)
            self.delegate?.didChangeVisuableViewController(to: newVC)
        }
        self.tabView.isUserInteractionEnabled = true
    }
}

extension HeaderTabPageViewController: HeaderTabViewDelegate {
    public func itemSelected(index: Int) {
        guard let currentIndex =  self.currentChildVCIndex(),
              currentIndex != index
        else { return }
        delegate?.didSelectTab(index: index)
        self.view.isUserInteractionEnabled = false
        self.tabView.move(to: index)
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
