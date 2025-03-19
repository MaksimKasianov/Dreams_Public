import UIKit

class MyTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let newDreamNC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "newDreamNC") as? NewDreamNC {
            delegate = self
            newDreamNC.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
            self.viewControllers?.insert(newDreamNC, at: 2)
        }
        
        (tabBar as? CustomizedTabBar)?.setupCenterButton()
        
        self.selectedIndex = UserDefaults.standard.integer(forKey: "OpenView")
    }
}

extension MyTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            
            return true
        }
        
        if selectedIndex == 2 {
            return false
        }
        
        return true
    }
}
