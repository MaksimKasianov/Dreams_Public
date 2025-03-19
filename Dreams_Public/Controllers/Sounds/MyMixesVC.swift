//
//  MyMixesVC.swift
//  DreamApp
//
//  Created by Kasianov on 26.04.2024.
//

import UIKit
import Combine

class MyMixesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var mixes = [SoundsMixEntity]()
    let audioPlayer = AudioPlayerManager.shared
    
    var selectedMix: SoundsMixEntity? = nil
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer.$isSoundsMix
            .sink { isSoundsMix in
                self.selectedMix = isSoundsMix
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        
        mixes = SoundsMixBase.shared.mixList
    }
}

extension MyMixesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mixes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SoundsMixCell
        
        if selectedMix == mixes[indexPath.row] {
            cell.isSelect = true
        } else {
            cell.isSelect = false
        }
        
        cell.setup(mix: mixes[indexPath.row])
        
        return cell
    }
}

extension MyMixesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AudioPlayerManager.shared.checkMix(mix: mixes[indexPath.item])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            if audioPlayer.isSoundsMix != nil {
                audioPlayer.stopAllAudio()
            }
            
            SoundsMixBase.shared.delete(mix: mixes[indexPath.row])
            self.mixes.remove(at: indexPath.row)
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
