//
//  ContainerTableViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2022/01/27.
//

import UIKit

class ContainerTableViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // アプリのバージョン
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = version
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            if let url = URL(string: "https://itunes.apple.com/app/ido.s110507@icloud.com?action=write-review") {
                UIApplication.shared.open(url)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case 3:
            guard let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSdkKuELsVccoESxOyN0F8Br4nw8k5Mh4V-6_qzToiGa2SYrsA/viewform?usp=sf_link") else { return }
            if UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        default:
            break
        }
    }
}
