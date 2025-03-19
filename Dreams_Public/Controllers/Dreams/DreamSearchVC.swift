//
//  DreanSearchVC.swift
//  WeDream
//
//  Created by Kasianov on 24.07.2023.
//

import UIKit

class DreamSearchVC: UIInputViewController {
    
    @IBOutlet weak var dreamLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!
    var text: String = ""
    var AllDreams: [Dream]? = nil
    var themes = [Dream]()
    
    var isFirstDream = false
    
    var openDream: DreamData!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AllDreams = DreamSearch.shared.dreamsInterpretation
        
        if isFirstDream {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.navigationBar.backgroundColor = .clear
            self.navigationController?.navigationBar.layer.shadowOpacity = 0
        }
        
        navigationItem.hidesBackButton = true
        
        dreamLabel.text = text
        
        let nib: UINib = UINib(nibName: "DreamCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        
        if let searchDreams = DreamSearch.shared.search(text: text) {
            var themes = ""
            if !searchDreams.isEmpty {
                showDreams(searchDreams: searchDreams)
                
                for dream in searchDreams {
                    AmplitudeManager.shared.eventTrack(type: "Finding dreams", properties: ["dream": dream.title])
                    themes.append("\(dream.title), ")
                }
            }
            
            DreamBase.shared.add(dream: text, themes: themes) { [self] dream in
                (self.navigationController as? NewDreamNC)?.newDreamDelegate?.update()
                self.openDream = dream
            }
        }
    }
    
    func showDreams(searchDreams: [Dream]) {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: dreamLabel.text ?? "")
        
        for (i, dream) in searchDreams.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(1 + i)) { [self] in
                attributedString.setColorForText(textToFind: dream.title, withColor: Colors.secondary_500)
                dreamLabel.attributedText = attributedString
                dreamLabel.tintColor = .gray
                
                themes.append(dream)
                
                countLabel.text = "Themes found: \(themes.count)"
                
                let indexPath = IndexPath(item: themes.count - 1, section: 0)

                collectionView.performBatchUpdates({
                    collectionView.insertItems(at: [indexPath])
                }, completion: nil)
                
                collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            }
        }
    }
    
    @IBAction func closeBt(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension DreamSearchVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DreamCell
        
        let dream = themes[indexPath.item]
        cell.setup(dream: dream)
        
        return cell
    }
}

extension DreamSearchVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dream = themes[indexPath.item]
        
        if let interpretationVC = UIStoryboard(name: "Library", bundle: nil).instantiateViewController(withIdentifier: "interpretationVC") as? DreamInterpretationVC {
            interpretationVC.interpretation = dream
            
            present(interpretationVC, animated: true)
        }
    }
}

extension DreamSearchVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size: CGFloat = 235
        
        return CGSize(width: (size / 1.46), height: size)
    }
}

