//
//  EventTableViewCell.swift
//  CalendarApp
//
//  Created by 大谷空 on 2021/10/25.
//

import UIKit

protocol EventTableViewCellDelegate: AnyObject {
    func notifiCell(eventFromCell: EventModel)
}

class EventTableViewCell: UITableViewCell {
    
    weak var delegate: EventTableViewCellDelegate?
    weak var alertDelegate: CalendarViewController?
    
    var eventModels = [EventModel]()
    var eventModel: EventModel? {
        didSet {
            titleLabel.text = eventModel?.title
            commentLabel.text = eventModel?.comment
            placeLabel.text = eventModel?.place
            startTimeLabel.text = eventModel?.startTime
            endTimeLabel.text = eventModel?.endTime
        }
    }
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    private func setupView() {
        cellView.layer.borderWidth = 0.5
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        cancelButton.addTarget(self, action: #selector(tappedClearButton), for: .touchUpInside)
    }
    
    @objc func tappedClearButton() {
        let alert = UIAlertController(title: "アラート表示", message: "本当に削除しても良いですか？", preferredStyle: UIAlertController.Style.alert)
        let clearAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default) { [weak self] (action: UIAlertAction) in
            self?.delegate?.notifiCell(eventFromCell: (self?.eventModel!)!)
        }
        alert.addAction(clearAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancelAction)
        alertDelegate?.present(alert, animated: true, completion: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
