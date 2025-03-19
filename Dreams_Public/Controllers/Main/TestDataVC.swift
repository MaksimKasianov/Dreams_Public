//
//  TestDataVC.swift
//  DreamApp
//
//  Created by Kasianov on 26.12.2023.
//

import UIKit

class TestDataVC: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func titleBt(_ sender: Any) {
        textField.text = UIPasteboard.general.string
    }
    
    @IBAction func descbt(_ sender: Any) {
        textView.text = UIPasteboard.general.string
    }
    
    
    @IBAction func addDataBt(_ sender: UIButton) {
        
        let request = AWSLambda()
        request.sendAWSLambda(text: "Please rewrite this content for better flow, rephrase it to be more reader-friendly and use straightforward and easy-to-understand language:\n\n" + textView.text) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let output):
                    if output.isEmpty {
                        print("Error")
                    } else {
                        DreamSearch.shared.encodePlist(title: self.textField.text ?? "", detailed: output)
                        self.textField.text = nil
                        self.textView.text = nil
                        self.textField.becomeFirstResponder()
                    }
                case .failure(_):
                    print("Error")
                }
                
            }
        }
        
    }
}
