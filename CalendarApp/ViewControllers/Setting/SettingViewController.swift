//
//  SettingTableViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2022/01/27.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet private weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
    }

    @objc private func tappedBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
