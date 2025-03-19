//
//  HomeVC.swift
//  WeDream
//
//  Created by Kasianov on 16.10.2023.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var dreamsCount: UILabel!
    @IBOutlet weak var dreamDate: UILabel!
    @IBOutlet weak var dreamStoryView: UIStackView!
    @IBOutlet weak var dreamsAllBt: UIButton!
    
    @IBOutlet weak var moodsCount: UILabel!
    
    @IBOutlet weak var visitsLabel: UILabel!
    @IBOutlet weak var visitsStack: UIStackView!
    
    @IBOutlet weak var newDreamBt: UIButton!
    @IBOutlet weak var newDreamLabel: UILabel!
    
    @IBOutlet weak var moodsView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var dreamsList = [DreamData]()
    var moodsList = [MoodData]()
    var storyList = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DreamBase.shared.loadAll()
        MoodBase.shared.loadAll()
        VisitsBase.shared.loadVisits()
        HelpfulBase.shared.loadAll()
        
        let nib: UINib = UINib(nibName: "DreamDescriptionCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "descriptionCell")
        
        let nib1: UINib = UINib(nibName: "MoodCell", bundle: nil)
        collectionView.register(nib1, forCellWithReuseIdentifier: "moodCell")
        
        updateDreamStory()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 32
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        
        updateVisits()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.layer.shadowOpacity = 0.24
        
        if let name = Shared.shared.personData?.name {
            navigationItem.title = "Hi \(name)"
        } else {
            navigationItem.title = "Hi"
        }
        
        if let button = (tabBarController?.tabBar as? CustomizedTabBar)?.middleBtn {
            button.superview?.isUserInteractionEnabled = true
            
            button.removeTarget(nil, action: nil, for: .allEvents)
            button.addTarget(self, action: #selector(newDreamBt(_:)), for: .touchUpInside)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    func updateDreamStory() {
        moodsList = MoodBase.shared.moodsList
        moodsCount.text = moodsList.count.description
        
        dreamsList = DreamBase.shared.dreamsList
        dreamsCount.text = dreamsList.count.description
        
        storyList.removeAll()
        storyList = moodsList + dreamsList
        storyList.sort { (object1, object2) -> Bool in
            if let date1 = (object1 as? DreamData)?.date, let date2 = (object2 as? DreamData)?.date {
                return date1 > date2
            } else if let date1 = (object1 as? MoodData)?.date, let date2 = (object2 as? MoodData)?.date {
                return date1 > date2
            } else if let date1 = (object1 as? DreamData)?.date, let date2 = (object2 as? MoodData)?.date {
                return date1 > date2
            } else if let date1 = (object1 as? MoodData)?.date, let date2 = (object2 as? DreamData)?.date {
                return date1 > date2
            } else {
                return false
            }
        }
        
        if storyList.isEmpty {
            dreamStoryView.isHidden = true
        } else {
            dreamStoryView.isHidden = false
            DispatchQueue.main.async { [self] in
                updateDateStory()
            }
        }
        collectionView.reloadData()
    }
    
    func updateDateStory() {
        if let visibleIndexPaths = collectionView.indexPathsForVisibleItems.first {
            //print("update date")
            let index = visibleIndexPaths.item
            
            var date = Date()
            if let dream = storyList[index] as? DreamData {
                date = dream.date
            } else if let mood = storyList[index] as? MoodData {
                date = mood.date
            }
            
            let formattedDate = date.formatted(dateFormat: "d MMM")
            
            if formattedDate != dreamDate.text {
                dreamDate.text = formattedDate
            }
        }
    }
    
    func updateVisits() {
        var visits = VisitsBase.shared.visitsList.first!
        
        let calendar = Calendar.current
        
        let oldVisit = calendar.dateComponents([.weekday, .weekOfYear, .year],from: visits.date)
        
        let newVisit = calendar.dateComponents([.weekday, .weekOfYear, .year],from: Date())
        
        if (newVisit.year! > oldVisit.year!) || (newVisit.weekOfYear! > oldVisit.weekOfYear!) {
            
            VisitsBase.shared.reloadVisits(visits: visits)
        }
        
        visits = VisitsBase.shared.visitsList.first!
        switch newVisit.weekday {
        case 2: visits.monday = true
        case 3: visits.tuesday = true
        case 4: visits.wednesday = true
        case 5: visits.thursday = true
        case 6: visits.friday = true
        case 7: visits.saturday = true
        default: visits.sunday = true
        }
        VisitsBase.shared.editVisits(visit: visits)
        
        let images = visitsStack.arrangedSubviews as! [UIImageView]
        
        let days = [visits.monday, visits.tuesday, visits.wednesday, visits.thursday, visits.friday, visits.saturday, visits.sunday]
        
        for (i, day) in days.enumerated() {
            if day == true {
                images[i].image = UIImage(named: "active")
            }
        }
    }
    
    @IBAction func diaryBt(_ sender: UIButton) {
        let dreamReportsVC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "dreamReportsVC") as! DreamReportsVC
        dreamReportsVC.newDreamDelegate = self
        dreamReportsVC.hidesBottomBarWhenPushed = true
        
        if let button = (tabBarController?.tabBar as? CustomizedTabBar)?.middleBtn {
            button.superview?.isUserInteractionEnabled = false
        }
        
        show(dreamReportsVC, sender: self)
    }
    
    @IBAction func visitsBt(_ sender: UIButton) {
        
    }
    
    @IBAction func newDreamBt(_ sender: UIButton) {
        if let newDreamNC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "newDreamNC") as? NewDreamNC {
            newDreamNC.newDreamDelegate = self
            
            present(newDreamNC, animated: true)
        }
    }
    
    @IBAction func newMoodBt(_ sender: UIButton) {
        if let newMoodVC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "newMoodVC") as? NewMoodNC {
            newMoodVC.newMoodDelegate = self
            newMoodVC.selectedMood = sender.tag
            
            present(newMoodVC, animated: true)
        }
    }
    
    @IBAction func menuBt(_ sender: UIBarButtonItem) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        
        self.showSettindsVC()
    }
}

extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let dream = storyList[indexPath.item] as? DreamData {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath) as! DreamDescriptionCell
            
            cell.setup(dream: dream, delegate: self, parent: self)
            return cell
        } 
        
        if let mood = storyList[indexPath.item] as? MoodData {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moodCell", for: indexPath) as! MoodCell
            
            cell.setup(mood: mood, delegate: self, parent: self)
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let dream = storyList[indexPath.item] as? DreamData {
            let dreamDetailsVC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "dreamDetailsVC") as! DreamDetailsVC
            dreamDetailsVC.selectedDream = dream
            dreamDetailsVC.dreamDelegate = self
            dreamDetailsVC.hidesBottomBarWhenPushed = true
            
            if let button = (tabBarController?.tabBar as? CustomizedTabBar)?.middleBtn {
                button.superview?.isUserInteractionEnabled = false
            }
            
            show(dreamDetailsVC, sender: self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateDateStory()
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 16 + 16
        let size: CGFloat = (collectionView.frame.size.width - space)
        
        return CGSize(width: size, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

extension HomeVC: NewDreamDelegate {
    func delete(dream: DreamData) {
        if let index = storyList.firstIndex(where: { element in
            if let dreamData = element as? DreamData {
                return dreamData == dream
            }
            return false
        }) {
            storyList.remove(at: index)
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
            }, completion: {_ in 
                DreamBase.shared.deleteDream(selected: dream)
                self.updateDreamStory()
            })
        }
    }
    
    func update() {
        print("Add dream")
        updateDreamStory()
    }
}

extension HomeVC: NewMoodDelegate {
    func delete(mood: MoodData) {
        if let index = storyList.firstIndex(where: { element in
            if let moodData = element as? MoodData {
                return moodData == mood
            }
            return false
        }) {
            storyList.remove(at: index)
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
            }, completion: {_ in
                MoodBase.shared.delete(selected: mood)
                self.updateDreamStory()
            })
        }
    }
    
    func newMood() {
        print("Add Mood")
        updateDreamStory()
        moodsView.isHidden = true
    }
}
