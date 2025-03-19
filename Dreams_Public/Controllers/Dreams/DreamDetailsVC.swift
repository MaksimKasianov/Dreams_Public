//
//  DreamDetailsVC.swift
//  WeDream
//
//  Created by Kasianov on 18.10.2023.
//

import UIKit
import Combine

class DreamDetailsVC: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dreamTV: StaticTextView!
    
    @IBOutlet weak var noteTV: StaticTextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editDreamBt: UIButton!
    
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewBanner: UIView!
    @IBOutlet weak var reviewBt: LoaderButton!
    
    @IBOutlet weak var pictureBanner: UIStackView!
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var pictureImg: UIImageView!
    @IBOutlet weak var pictureBt: LoaderButton!
    
    var selectedDream: DreamData!
    
    @IBOutlet weak var themesComment: UILabel!
    var themes = [Dream]()
    
    weak var dreamDelegate: NewDreamDelegate?
    
    var dreamReviewProvider = AssistantChatProvider()
    var promptDalleProvider = AssistantChatProvider()
    var imagesProvider = ImagesProvider()
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateLabel.text = selectedDream.date.formatted(dateFormat: "dd MMM yyyy")
        dreamTV.setText(selectedDream.dream)
        
        if let note = selectedDream.note, !note.isEmpty {
            noteTV.setText(note)
        }
        
        if let dreamReview = selectedDream.dreamReview, !dreamReview.isEmpty {
            reviewLabel.text = dreamReview
            reviewLabel.isHidden = false
            reviewBanner.isHidden = true
        } else {
            reviewLabel.isHidden = true
            reviewBanner.isHidden = false
            
            //0reviewBt.processText = "Loading results..."
            
            if let isLoading = selectedDream.loadingReview as? Bool, isLoading {
                reviewBt.isLoading = isLoading
            } else {
                setupReviewProvider()
            }
        }
        
        if let imageData = selectedDream.picture, let image = UIImage(data: imageData) {
            print("imageData \(imageData)")
            pictureImg.image = image
            pictureView.isHidden = false
            pictureBanner.isHidden = true
        } else {
            print("imageData nil")
            pictureView.isHidden = true
            pictureBanner.isHidden = false
            
            //pictureBt.processText = "Progress..."
            
            if let isLoading = selectedDream.loadingImage as? Bool, isLoading {
                pictureBt.isLoading = isLoading
            } else {
                setupPictureProvider()
            }
        }
        
        if let searchDreams = DreamSearch.shared.search(text: selectedDream.dream), !searchDreams.isEmpty {
            themes = searchDreams
            collectionView.isHidden = false
            themesComment.isHidden = true
            
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
        } else {
            collectionView.isHidden = true
            themesComment.isHidden = false
        }
    }

    func setupReviewProvider() {
        dreamReviewProvider.$message
            .sink { [weak self] message in
                if let text = message?.content {
                    DispatchQueue.main.async {
                        if let dream = self?.selectedDream {
                            dream.dreamReview = text
                            DreamBase.shared.editDream(selectedDream: dream)
                        }
                        self?.reviewBt.isLoading = false
                        self?.reviewLabel.text = text
                        self?.reviewLabel.isHidden = false
                        self?.reviewBanner.isHidden = true
                    }
                }
            }
            .store(in: &cancellables)
        
        dreamReviewProvider.$threadId
            .sink { [weak self] threadId in
                if threadId == nil {
                    self?.dreamReviewProvider.createThread()
                }
            }
            .store(in: &cancellables)
    }
    
    func setupPictureProvider() {
        promptDalleProvider.$message
            .sink { [weak self] message in
                if let text = message?.content {
                    DispatchQueue.main.async {
                        Task {
                            do {
                                try await self?.imagesProvider.createImages(prompt: text)
                            } catch {
                                self?.pictureBt.isLoading = false
                                self?.selectedDream.loadingImage = false
                                DreamBase.shared.editDream(selectedDream: self!.selectedDream)
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        promptDalleProvider.$threadId
            .sink { [weak self] threadId in
                if threadId == nil {
                    self?.promptDalleProvider.createThread()
                }
            }
            .store(in: &cancellables)
        
        imagesProvider.$images
            .sink { [weak self] images in
                if let image = images?.first {
                    DispatchQueue.main.async {
                        if let dream = self?.selectedDream {
                            dream.picture = image.pngData()
                            DreamBase.shared.editDream(selectedDream: dream)
                        }
                        
                        self?.pictureImg.image = image
                        self?.pictureView.isHidden = false
                        self?.pictureBanner.isHidden = true
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @IBAction func editDreamBt(_ sender: UIButton) {
        let textEditVC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "textEditVC") as! TextEditVC
        
        textEditVC.notesText = selectedDream.dream
        textEditVC.statusText = "🔒 Your content of your dreams is completely confidential"
        textEditVC.editDelegate = self
        textEditVC.isDream = true
        
        show(textEditVC, sender: self)
    }
    
    @IBAction func getReviewBt(_ sender: LoaderButton) {
        if Shared.shared.isPremium == false {
            let unlockVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "unlockVC") as! UnlockFuncVC
            unlockVC.delegate = self
            unlockVC.unlockedFunc = .reviewDream
            unlockVC.modalTransitionStyle = .crossDissolve
            unlockVC.modalPresentationStyle = .overFullScreen
            
            present(unlockVC, animated: true)
            return
        }
        
        reviewDream()
    }
    
    func reviewDream() {
        
        reviewBt.isLoading = true
        
        self.selectedDream.loadingReview = true
        DreamBase.shared.editDream(selectedDream: self.selectedDream)
        
        if let threadId = dreamReviewProvider.threadId {
            Task {
                do {
                    try await dreamReviewProvider.createMessage(threadID: threadId, content: self.selectedDream.dream)
                    
                    try await dreamReviewProvider.createRunAndStreamMessage(threadId: threadId, parameters: .init(assistantID: Assistant.dreamReview.rawValue))
                } catch {
                    reviewBt.isLoading = false
                    self.selectedDream.loadingReview = false
                    DreamBase.shared.editDream(selectedDream: self.selectedDream)
                }
            }
        }
    }
    
    @IBAction func createPictureBt(_ sender: LoaderButton) {
        if Shared.shared.isPremium == false {
            let unlockVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "unlockVC") as! UnlockFuncVC
            unlockVC.delegate = self
            unlockVC.unlockedFunc = .createPicture
            unlockVC.modalTransitionStyle = .crossDissolve
            unlockVC.modalPresentationStyle = .overFullScreen
            
            present(unlockVC, animated: true)
            return
        }
        
        createPicture()
    }
    
    func createPicture() {
        guard let prompt = selectedDream.dream else { return }
        
        pictureBt.isLoading = true
        self.selectedDream.loadingImage = true
        DreamBase.shared.editDream(selectedDream: self.selectedDream)
        
        if let threadId = promptDalleProvider.threadId {
            Task {
                do {
                    try await promptDalleProvider.createMessage(threadID: threadId, content: prompt)
                    
                    try await promptDalleProvider.createRunAndStreamMessage(threadId: threadId, parameters: .init(assistantID: Assistant.promptDalle.rawValue))
                } catch {
                    pictureBt.isLoading = false
                    self.selectedDream.loadingImage = false
                    DreamBase.shared.editDream(selectedDream: self.selectedDream)
                }
            }
        }
    }
    
    @IBAction func editNotesBt(_ sender: UIButton) {
        let textEditVC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "textEditVC") as! TextEditVC
        
        textEditVC.notesText = selectedDream.note
        textEditVC.statusText = "🔒 Your notes are completely private"
        textEditVC.editDelegate = self
        textEditVC.isNotes = true
        
        show(textEditVC, sender: self)
    }
}

extension DreamDetailsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DreamCell
        
        cell.setup(dream: themes[indexPath.item])
        
        return cell
    }
}

extension DreamDetailsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dream = themes[indexPath.item]
        
        if let interpretationVC = UIStoryboard(name: "Library", bundle: nil).instantiateViewController(withIdentifier: "interpretationVC") as? DreamInterpretationVC {
            interpretationVC.interpretation = dream
            
            show(interpretationVC, sender: self)
        }
    }
}

extension DreamDetailsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size: CGFloat = 235
        
        return CGSize(width: (size / 1.46), height: size)
    }
}

extension DreamDetailsVC: EditDreamDelegate {
    func editDream(dream: String) {
        selectedDream.dream = dream
        dreamTV.setText(dream)
        DreamBase.shared.editDream(selectedDream: selectedDream)
        dreamDelegate?.update()
    }
    
    func editNotes(notes: String) {
        selectedDream.note = notes
        noteTV.setText(notes)
        
        DreamBase.shared.editDream(selectedDream: selectedDream)
        dreamDelegate?.update()
    }
}

extension DreamDetailsVC: UnlockDelegate {
    func unlockFunc(unfunc: UnlockedFunctions) {
        switch unfunc {
        case .createPicture:
            self.createPicture()
        case .reviewDream:
            self.reviewDream()
        case .sound:
            break
        }
    }
    
    func showPremium() {
        self.showPremiumVC()
    }
}
