//
//  YouBornVC.swift
//  WeDream
//
//  Created by Kasianov on 17.11.2023.
//

import UIKit

class YouBornVC: UIViewController {

    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nextBt: UIButton!
    
    weak var person: PersonData?
    
    var animViews = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.setValue(Colors.shades_gray_900, forKeyPath: "textColor")
        
        datePicker.maximumDate = Date()
        
        if person != nil {
            animViews = true
            nextBt.setTitle("Save", for: .normal)
            navigationItem.rightBarButtonItem = nil
        }
        
        if let born = person?.born {
            datePicker.date = born
            nextBt.setTitle("Save", for: .normal)
        } else {
            if animViews == false {
                animViews = true
                let arrayView: [UIView] = [infoStack, datePicker, nextBt]
                Animations.shared.animateActiveViews(views: arrayView, delayTime: 0.25)
            }
        }
    }

    @IBAction func nextBt(_ sender: UIButton) {
        if let person = person {
            person.born = datePicker.date
            PersonBase.shared.edit(complection: {
                Shared.shared.personData = person
            })
            
            navigationController?.popViewController(animated: true)
        } else {
            Shared.shared.registerData.born = datePicker.date
            
            let yourGenderVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "yourGenderVC")
            show(yourGenderVC, sender: self)
        }
    }
    
    @IBAction func skipBt(_ sender: Any) {
        Shared.shared.registerData.born = nil
        
        let yourGenderVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "yourGenderVC")
        show(yourGenderVC, sender: self)
    }
    
}
