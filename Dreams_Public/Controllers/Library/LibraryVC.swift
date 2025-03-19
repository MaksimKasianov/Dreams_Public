import UIKit
import FirebaseStorage

class LibraryVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var dataSourse = [Dream]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSearchBar()
        
        let nib: UINib = UINib(nibName: "DreamCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
    }
    
    func addSearchBar() {
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        searchController.searchBar.delegate = self
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            
            textfield.tintColor = Colors.shades_gray_500
            textfield.font = .SourceSansPro_Regular(16)
            textfield.textColor = Colors.shades_gray_800
           
            textfield.backgroundColor = Colors.surface_50
            textfield.borderStyle = .none
            textfield.layer.cornerRadius = 8
            
        print(textfield.frame.height)
            
            textfield.attributedPlaceholder = NSAttributedString(string: "Enter topic keywords ...", attributes: [NSAttributedString.Key.foregroundColor : Colors.shades_gray_500])
           
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = Colors.shades_gray_500
                leftView.image = UIImage(named: "sarch-icon")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.layer.shadowOpacity = 0.24
        
        if let searchText = searchController.searchBar.text {
            dataSourse = searchText.isEmpty ? DreamSearch.shared.dreamsIcons : DreamSearch.shared.dreamsInterpretation.filter { $0.title.lowercased().contains(searchText.lowercased())
            }
        } else {
            dataSourse = DreamSearch.shared.dreamsIcons
        }
        
        if let button = (tabBarController?.tabBar as? CustomizedTabBar)?.middleBtn {
            button.superview?.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func menuBt(_ sender: UIBarButtonItem) {
        self.showSettindsVC()
    }
}

extension LibraryVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourse.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DreamCell
        
        let dream = dataSourse[indexPath.item]
        cell.setup(dream: dream)
        
        return cell
    }
}

extension LibraryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dream = dataSourse[indexPath.item]
        
        if let interpretationVC = UIStoryboard(name: "Library", bundle: nil).instantiateViewController(withIdentifier: "interpretationVC") as? DreamInterpretationVC {
            interpretationVC.interpretation = dream
            interpretationVC.hidesBottomBarWhenPushed = true
            
            if let button = (tabBarController?.tabBar as? CustomizedTabBar)?.middleBtn {
                button.superview?.isUserInteractionEnabled = false
            }
            
            show(interpretationVC, sender: self)
        }
    }
}

extension LibraryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + 16 + 16
        let size: CGFloat = (collectionView.frame.size.width - space) / 2.0
        
        return CGSize(width: size, height: (size * 1.46))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 56, right: 16)
    }
}

extension LibraryVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dataSourse = DreamSearch.shared.dreamsIcons
        self.collectionView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSourse = searchText.isEmpty ? DreamSearch.shared.dreamsIcons : DreamSearch.shared.dreamsInterpretation.filter { $0.title.lowercased().contains(searchText.lowercased())
        }

        self.collectionView.reloadData()
    }
}
