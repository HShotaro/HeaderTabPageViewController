# HeaderTabPageViewController

## Usage

<table>
<tr>
<td> Here's an example </td> <td> In Action </td>
</tr>
<tr>
<td> 
<code>
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
</code>
</td>
<td>
<video controls playsinline autoplay loop muted="true" src="https://user-images.githubusercontent.com/33021078/208803075-4ea9fb47-37d7-4e18-9848-55fb4eb07748.mp4" type="video/mp4" width="100%">
</video>
</td>
</tr>
</table>
