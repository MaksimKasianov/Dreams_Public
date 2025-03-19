//
//  SoundsVC.swift
//  DreamApp
//
//  Created by Kasianov on 15.04.2024.
//

import UIKit
import Combine

class SoundsVC: UIViewController {

    @IBOutlet weak var collectionView: CustomCollectionView!
    
    let playerManager = AudioPlayerManager.shared
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var mixedBt: UIButton!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    var selectIndexPath = IndexPath()
    
    var mixedCount: Int = 0 {
        didSet {
            countLabel.text = mixedCount.description
            
            if mixedCount == 0 {
                countView.isHidden = true
                mixedBt.borderColor = Colors.secondary_50
                mixedBt.backgroundColor = Colors.secondary_200
                mixedBt.tintColor = Colors.secondary_50
                mixedBt.isEnabled = false
            } else {
                countView.isHidden = false
                mixedBt.borderColor = Colors.primary_500
                mixedBt.backgroundColor = Colors.primary_50
                mixedBt.tintColor = Colors.primary_500
                mixedBt.isEnabled = true
            }
        }
    }
    
    var isSelectedArray: [String:Bool] = [:]
    let array = ["Wind", "Rainy", "Birds", "Sea Waves", "Mountain Stream", "Seagulls", "Underwater", "Restaurant", "Pink Noise", "White Noise", "Forest", "Train", "Sea Ambience", "Fireplace", "Street", "Thunder", "Space", "Clock", "Vinyl", "Night"]
    
    var sectionsData = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        playerManager.$audioPlayers
            .sink { audioPlayers in
                for a in self.array {
                    self.isSelectedArray[a] = false
                }
                
                for players in audioPlayers {
                    self.isSelectedArray[players.key] = true
                }
                
                self.mixedCount = audioPlayers.count
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if sectionsData.isEmpty {
            let containerHeight = collectionView.bounds.height
            
            var numberOfItemsInRow = Int(floor(containerHeight / (105 + 16)))
            
            numberOfItemsInRow = numberOfItemsInRow > 4 ? 4 : numberOfItemsInRow
            
            
            var tempArray = [String]()
            
            for (index, sound) in array.enumerated() {
                tempArray.append(sound)
                if (index + 1) % numberOfItemsInRow == 0 || index == array.count - 1 {
                    sectionsData.append(tempArray)
                    tempArray = [String]()
                }
            }
            
            collectionView.sectionsData = sectionsData
            
            collectionView.collectionViewLayout = createLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        if let button = (tabBarController?.tabBar as? CustomizedTabBar)?.middleBtn {
            button.superview?.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func mixesBt(_ sender: UIBarButtonItem) {
        let myMixesVC = UIStoryboard(name: "Sounds", bundle: nil).instantiateViewController(withIdentifier: "myMixesVC")
        
        myMixesVC.hidesBottomBarWhenPushed = true
        
        if let button = (tabBarController?.tabBar as? CustomizedTabBar)?.middleBtn {
            button.superview?.isUserInteractionEnabled = false
        }
        
        show(myMixesVC, sender: self)
    }
    
    @IBAction func menuBt(_ sender: UIBarButtonItem) {
        self.showSettindsVC()
    }
    
    @IBAction func mixerBt(_ sender: UIButton) {
        let mixedSoundsVC = UIStoryboard(name: "Sounds", bundle: nil).instantiateViewController(identifier: "mixedSoundsVC")
        
        let navVC = UINavigationController(rootViewController: mixedSoundsVC)
        present(navVC, animated: true)
    }
}

extension SoundsVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sectionsData[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SoundCell
        
        let sound = sectionsData[indexPath.section][indexPath.item]
        cell.sound = sound
        cell.isSelect = isSelectedArray[sound] ?? false
        
        return cell
    }
}

extension SoundsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SoundCell
        
        if cell.lockView.isHidden == false {
            selectIndexPath = indexPath
            
            let unlockVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "unlockVC") as! UnlockFuncVC
            unlockVC.delegate = self
            unlockVC.unlockedFunc = .sound
            unlockVC.modalTransitionStyle = .crossDissolve
            unlockVC.modalPresentationStyle = .overFullScreen
            
            present(unlockVC, animated: true)
        } else {
            AudioPlayerManager.shared.checkAudio(fileName: sectionsData[indexPath.section][indexPath.item])
        }
    }
}

extension SoundsVC {
    func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
            config.scrollDirection = .horizontal
        
        let cvLayout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(77), heightDimension: .absolute(105)))
            
            let containerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(77), heightDimension: .fractionalHeight(1)), subitems: [item])
            
            containerGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(16)
            
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = .none
            
            if sectionIndex % 2 == 0 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
            } else {
                section.contentInsets = NSDirectionalEdgeInsets(top: 44, leading: 16, bottom: 0, trailing: 16)
            }
            
            return section
        }
        
        cvLayout.configuration = config
        return cvLayout
    }
}

extension SoundsVC: UnlockDelegate {
    func unlockFunc(unfunc: UnlockedFunctions) {
        AudioPlayerManager.shared.checkAudio(fileName: sectionsData[selectIndexPath.section][selectIndexPath.item])
    }
    
    func showPremium() {
        self.showPremiumVC()
    }
}
