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

    var eventModel: EventModel? {
        didSet {
            titleLabel.text = eventModel?.title
            commentLabel.text = eventModel?.comment
            placeLabel.text = eventModel?.place
            startTimeLabel.text = eventModel?.startTime
            endTimeLabel.text = eventModel?.endTime
        }
    }

    @IBOutlet private weak var cellView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var endTimeLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var commentLabel: UILabel!
    @IBOutlet private weak var placeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    private func setupView() {
        cellView.layer.borderWidth = 0.8
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        cellView.layer.cornerRadius = 12.5
        cancelButton.addTarget(self, action: #selector(tappedClearButton), for: .touchUpInside)
    }

    @objc func tappedClearButton() {
        let alert = UIAlertController(title: "アラート表示", message: "本当に削除してもよろしいですか？", preferredStyle: UIAlertController.Style.alert)
        let clearAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default) { [weak self] (_: UIAlertAction) in
            self?.delegate?.notifiCell(eventFromCell: ((self?.eventModel!)!))
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
