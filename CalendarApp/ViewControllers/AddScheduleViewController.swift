//
//  AddScheduleViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2021/10/09.
//

import UIKit
import TextFieldEffects

class AddScheduleViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleTextField: HoshiTextField!
    @IBOutlet weak var placeTextField: HoshiTextField!
    @IBOutlet weak var commentTextField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        
        cancelButton.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        
        placeTextField.delegate = self
        commentTextField.delegate = self
        titleTextField.delegate = self
        
        titleTextField.placeholderColor = .darkGray
        titleTextField.borderActiveColor = .systemGreen
        placeTextField.placeholderColor = .darkGray
        placeTextField.borderActiveColor = .systemGreen
        commentTextField.placeholderColor = .darkGray
        commentTextField.borderActiveColor = .systemGreen
        
    }
    
    @objc private func tappedCancelButton() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
}

extension AddScheduleViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        placeTextField.resignFirstResponder()
        commentTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        
        return true
    }
    
    
}
