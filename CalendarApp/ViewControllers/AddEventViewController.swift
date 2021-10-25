//
//  AddScheduleViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2021/10/09.
//

import UIKit
import TextFieldEffects
import RealmSwift

protocol AddEventViewControllerDelegate: class {
    
    func event(addEvent: EventModel)
    
}

class AddEventViewController: UIViewController {
    
    weak var delegate: AddEventViewControllerDelegate?
    var eventModel: EventModel?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleTextField: HoshiTextField!
    @IBOutlet weak var placeTextField: HoshiTextField!
    @IBOutlet weak var commentTextField: HoshiTextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        setupView()
    }
    
    private func setupView() {
        
        cancelButton.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(tappedSaveButton), for: .touchUpInside)
        
        placeTextField.delegate = self
        commentTextField.delegate = self
        titleTextField.delegate = self
        
        titleTextField.placeholderColor = .darkGray
        titleTextField.borderInactiveColor = .darkGray
        titleTextField.borderActiveColor = .systemGreen
        titleTextField.placeholderFontScale = 1
        placeTextField.placeholderColor = .darkGray
        placeTextField.borderActiveColor = .systemGreen
        placeTextField.borderInactiveColor = .darkGray
        placeTextField.placeholderFontScale = 1
        commentTextField.placeholderColor = .darkGray
        commentTextField.borderActiveColor = .systemGreen
        commentTextField.borderInactiveColor = .darkGray
        commentTextField.placeholderFontScale = 1
        
    }
    
    @objc private func tappedSaveButton() {
        
        createEvent()
        
        delegate?.event(addEvent: eventModel!)
        dismiss(animated: true, completion: nil)
        
        
    }
    
    private func createEvent() {
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy/MM/dd HH:mm"
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH"
        
        guard let title = titleTextField.text else { return }
        guard let comment = commentTextField.text else { return }
        guard let place = placeTextField.text else { return }
        
        do {
            
            let realm = try Realm()
            eventModel?.title = title
            eventModel?.comment = comment
            eventModel?.place = place
            eventModel?.date = "\(dateFormat.string(from: startDatePicker.date))"
            eventModel?.startTime = "\(timeFormat.string(from: startDatePicker.date))"
            eventModel?.endTime = "\(timeFormat.string(from: endDatePicker.date))"
            
            try realm.write {
                realm.add(eventModel!)
                
            }
        } catch {
            print("create todo error.")
        }
    }
    
    @objc private func tappedCancelButton() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
}

extension AddEventViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        placeTextField.resignFirstResponder()
        commentTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        
        return true
    }
    
    
}
