//
//  DreamReportsVC.swift
//  WeDream
//
//  Created by Kasianov on 17.10.2023.
//

import UIKit

class DreamReportsVC: UIViewController {
    
    weak var newDreamDelegate: NewDreamDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dreamsList = [DreamData]()
    var sections: [String: [DreamData]] = [:]
    var sortedSectionKeys: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDreamReports()
        
        let nib: UINib = UINib(nibName: "DreamDescriptionCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "descriptionCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        collectionView.clipsToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func loadDreamReports() {
        dreamsList.removeAll()
        sections.removeAll()
        sortedSectionKeys.removeAll()
        
        dreamsList = DreamBase.shared.dreamsList
        
        for data in dreamsList {
            let sectionKey = data.date.formatted(dateFormat: "dd MMMM yyyy")
            
            if sections[sectionKey] == nil {
                sections[sectionKey] = [data]
            } else {
                sections[sectionKey]?.append(data)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        sortedSectionKeys = Array(sections.keys).sorted { (dateStr1, dateStr2) -> Bool in
            if let date1 = dateFormatter.date(from: dateStr1),
               let date2 = dateFormatter.date(from: dateStr2) {
                return date1 > date2
            }
            return false
        }
    }
}

extension DreamReportsVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sortedSectionKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionKey = sortedSectionKeys[section]
        return sections[sectionKey]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath) as! DreamDescriptionCell
        
        let sectionKey = sortedSectionKeys[indexPath.section]

        if let data = sections[sectionKey]?[indexPath.item] {
            cell.setup(dream: data, delegate: self, parent: self)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "dateReusableView", for: indexPath) as! DateReusableView
            let sectionKey = sortedSectionKeys[indexPath.section]
            headerView.dateLabel.text = sectionKey
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
    
}

extension DreamReportsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! DreamDescriptionCell
        
        let dreamDetailsVC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "dreamDetailsVC") as! DreamDetailsVC
        dreamDetailsVC.selectedDream = cell.dream
        dreamDetailsVC.dreamDelegate = self
        show(dreamDetailsVC, sender: self)
    }
}

extension DreamReportsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 16 + 16
        let size: CGFloat = (collectionView.frame.size.width - space)
        
        return CGSize(width: size, height: 160)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

extension DreamReportsVC: NewDreamDelegate {
    func delete(dream: DreamData) {
        for (sectionKey, dreamsInSection) in sections {
            if let index = dreamsInSection.firstIndex(of: dream) {
                print("\(sectionKey): \(index)")
                
                sections[sectionKey]?.remove(at: index)
                if sections[sectionKey]?.isEmpty == true {
                    sections.removeValue(forKey: sectionKey)
                    
                    sortedSectionKeys = sortedSectionKeys.filter { $0 != sectionKey }
                }
                
                self.collectionView.reloadData()
                
                DreamBase.shared.deleteDream(selected: dream)
                
                self.newDreamDelegate?.update()
                
                return
            }
        }
    }
    
    func update() {
        loadDreamReports()
        collectionView.reloadData()
        
        newDreamDelegate?.update()
    }
}


