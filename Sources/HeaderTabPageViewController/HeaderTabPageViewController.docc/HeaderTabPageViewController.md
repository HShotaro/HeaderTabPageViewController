# ``HeaderTabPageViewController``

this framework provide the viewController with pageViewController and selectable tabs.

## OverView

If you select a tab, the visible viewController will change. and if you scroll a page horizontally, the visible viewConttoller will change.

By customizing initialize parameter of ``HeaderTabPageViewController/HeaderTabPageViewController``, user can change the font size of tab's title and margin between tabs and so on.
## Example

![example_image](example.png)

```swift
import UIKit
import HeaderTabPageViewController

class ViewController: UIViewController {
    
    private var pageVC: HeaderTabPageViewController!
    let colors: [UIColor] = [.systemGray, .systemBlue, .systemYellow, .systemGreen]

    override func viewDidLoad() {
        super.viewDidLoad()
        pageVC = HeaderTabPageViewController()
        let tabGroups: [(vc: UIViewController, tabItem: String)] = [Int](0..<10).map { index  -> (vc: UIViewController, tabItem: String) in
            let vc = UIViewController()
            vc.view.backgroundColor = colors.randomElement()
            let tabItem = "タブ\(index)"
            return (vc: vc, tabItem: tabItem)
        }
        view.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        pageVC.setUp(tabGroups: tabGroups, selectedIndex: 4)
        
        NSLayoutConstraint.activate([
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            pageVC.view.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor, constant: 0),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
}
```
