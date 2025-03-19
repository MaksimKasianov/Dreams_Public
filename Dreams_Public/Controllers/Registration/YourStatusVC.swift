//
//  YourStatusVC.swift
//  WeDream
//
//  Created by Kasianov on 17.11.2023.
//

import UIKit

class YourStatusVC: UIViewController {

    @IBOutlet weak var relBt: UIButton!
    @IBOutlet weak var sin: UIButton!
    @IBOutlet weak var comBt: UIButton!
    @IBOutlet weak var nextBt: UIButton!
    
    @IBOutlet weak var skipBt: UIBarButtonItem!
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
        
        if let status = person?.status {
            switch status {
            case "In a relationship":
                relBt.setTitleColor(Colors.primary_500, for: .normal)
                relBt.backgroundColor = Colors.primary_50
                relBt.layer.borderColor = Colors.primary_500.cgColor
            case "It’s complicated":
                comBt.setTitleColor(Colors.primary_500, for: .normal)
                comBt.backgroundColor = Colors.primary_50
                comBt.layer.borderColor = Colors.primary_500.cgColor
            default:
                sin.setTitleColor(Colors.primary_500, for: .normal)
                sin.backgroundColor = Colors.primary_50
                sin.layer.borderColor = Colors.primary_500.cgColor
            }
        } else {
            if animViews == false {
                animViews = true
                let arrayView: [UIView] = [relBt, sin, comBt, nextBt]
                Animations.shared.animateActiveViews(views: arrayView, delayTime: 0.25)
            }
            nextBt.isEnabled = false
            nextBt.alpha = 0.5
        }
    }
    
    @IBAction func selectGender(_ sender: UIButton) {
        nextBt.isEnabled = true
        nextBt.alpha = 1
        
        selected = sender.titleLabel?.text ?? "Single"
        
        relBt.setTitleColor(Colors.surface_600, for: .normal)
        sin.setTitleColor(Colors.surface_600, for: .normal)
        comBt.setTitleColor(Colors.surface_600, for: .normal)
        
        relBt.backgroundColor = Colors.surface_100
        sin.backgroundColor = Colors.surface_100
        comBt.backgroundColor = Colors.surface_100
        
        relBt.layer.borderColor = Colors.surface_600.cgColor
        sin.layer.borderColor = Colors.surface_600.cgColor
        comBt.layer.borderColor = Colors.surface_600.cgColor
        
        
        switch selected {
        case "In a relationship":
            relBt.setTitleColor(Colors.primary_500, for: .normal)
            relBt.backgroundColor = Colors.primary_50
            relBt.layer.borderColor = Colors.primary_500.cgColor
        case "It’s complicated":
            comBt.setTitleColor(Colors.primary_500, for: .normal)
            comBt.backgroundColor = Colors.primary_50
            comBt.layer.borderColor = Colors.primary_500.cgColor
        default:
            sin.setTitleColor(Colors.primary_500, for: .normal)
            sin.backgroundColor = Colors.primary_50
            sin.layer.borderColor = Colors.primary_500.cgColor
        }
    }
    
    @IBAction func nextBt(_ sender: UIButton) {
        guard let status = selected else {
            return
        }
        
        if let person = person {
            person.status = status
            PersonBase.shared.edit(complection: {
                Shared.shared.personData = person
            })
            
            navigationController?.popViewController(animated: true)
        } else {
            Shared.shared.registerData.status = status
            
            PersonBase.shared.add(data: Shared.shared.registerData)
            
            Shared.shared.registerData = PersonRegister()
            
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            
            let newDreamVC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "newDreamVC") as! NewDreamVC
            newDreamVC.isFirstDream = true
            
            show(newDreamVC, sender: self)
        }
    }
    
    @IBAction func skipBt(_ sender: Any) {
        Shared.shared.registerData.status = nil
        
//        print(Shared.shared.registerData.name)
//        print(Shared.shared.registerData.born)
//        print(Shared.shared.registerData.gender)
//        print(Shared.shared.registerData.status)
        
        PersonBase.shared.add(data: Shared.shared.registerData)
        Shared.shared.registerData = PersonRegister()
        UserDefaults.standard.set(true, forKey: "isFirstLaunch")
        
        let newDreamVC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "newDreamVC") as! NewDreamVC
        newDreamVC.isFirstDream = true
        
        show(newDreamVC, sender: self)
    }
    
}
