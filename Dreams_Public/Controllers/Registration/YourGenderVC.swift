//
//  YourGenderVC.swift
//  WeDream
//
//  Created by Kasianov on 17.11.2023.
//

import UIKit

class YourGenderVC: UIViewController {

    @IBOutlet weak var maleBt: UIButton!
    @IBOutlet weak var femaleBt: UIButton!
    @IBOutlet weak var otherBt: UIButton!
    @IBOutlet weak var nextBt: UIButton!
    
    var selected: String? = nil
    var animViews = false
    
    weak var person: PersonData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if person != nil {
            animViews = true
            nextBt.setTitle("Save", for: .normal)
            navigationItem.rightBarButtonItem = nil
        }
        if let gender = person?.gender {
            switch gender {
            case "Male":
                maleBt.setTitleColor(Colors.primary_500, for: .normal)
                maleBt.backgroundColor = Colors.primary_50
                maleBt.layer.borderColor = Colors.primary_500.cgColor
            case "Female":
                femaleBt.setTitleColor(Colors.primary_500, for: .normal)
                femaleBt.backgroundColor = Colors.primary_50
                femaleBt.layer.borderColor = Colors.primary_500.cgColor
            default:
                otherBt.setTitleColor(Colors.primary_500, for: .normal)
                otherBt.backgroundColor = Colors.primary_50
                otherBt.layer.borderColor = Colors.primary_500.cgColor
            }
            
            nextBt.setTitle("Save", for: .normal)
        } else {
            if animViews == false {
                animViews = true
                let arrayView: [UIView] = [maleBt, femaleBt, otherBt, nextBt]
                Animations.shared.animateActiveViews(views: arrayView, delayTime: 0.25)
            }
            
            nextBt.isEnabled = false
            nextBt.alpha = 0.5
        }
    }
    
    @IBAction func selectGender(_ sender: UIButton) {
        nextBt.isEnabled = true
        nextBt.alpha = 1
        
        selected = sender.titleLabel?.text ?? "Other"
        
        maleBt.setTitleColor(Colors.surface_600, for: .normal)
        femaleBt.setTitleColor(Colors.surface_600, for: .normal)
        otherBt.setTitleColor(Colors.surface_600, for: .normal)
        
        maleBt.backgroundColor = Colors.surface_100
        femaleBt.backgroundColor = Colors.surface_100
        otherBt.backgroundColor = Colors.surface_100
        
        maleBt.layer.borderColor = Colors.surface_600.cgColor
        femaleBt.layer.borderColor = Colors.surface_600.cgColor
        otherBt.layer.borderColor = Colors.surface_600.cgColor
        
        
        switch selected {
        case "Male":
            maleBt.setTitleColor(Colors.primary_500, for: .normal)
            maleBt.backgroundColor = Colors.primary_50
            maleBt.layer.borderColor = Colors.primary_500.cgColor
        case "Female":
            femaleBt.setTitleColor(Colors.primary_500, for: .normal)
            femaleBt.backgroundColor = Colors.primary_50
            femaleBt.layer.borderColor = Colors.primary_500.cgColor
        default:
            otherBt.setTitleColor(Colors.primary_500, for: .normal)
            otherBt.backgroundColor = Colors.primary_50
            otherBt.layer.borderColor = Colors.primary_500.cgColor
        }
    }
    
    @IBAction func nextBt(_ sender: UIButton) {
        guard let gender = selected else {
            return
        }
        
        if let person = person {
            person.gender = gender
            PersonBase.shared.edit(complection: {
                Shared.shared.personData = person
            })
            
            navigationController?.popViewController(animated: true)
        } else {
            Shared.shared.registerData.gender = gender
            
            let yourStatusVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "yourStatusVC")
            show(yourStatusVC, sender: self)
        }
    }
    
    @IBAction func skipBt(_ sender: Any) {
        Shared.shared.registerData.gender = nil
        
        let yourStatusVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "yourStatusVC")
        show(yourStatusVC, sender: self)
    }
    
}
