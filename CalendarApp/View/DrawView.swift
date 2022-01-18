//
//  Extension-DrawView.swift
//  CalendarApp
//
//  Created by 大谷空 on 2022/01/05.
//

import Foundation
import UIKit

class DrawView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let line = UIBezierPath()
        line.move(to: CGPoint(x: 10, y: 125))
        line.addLine(to: CGPoint(x: 750, y: 125))
        line.close()
        UIColor.lightGray.setStroke()
        line.lineWidth = 1.2
        line.stroke()
        line.lineCapStyle = .round
    }
}
