//
//  PaddingLabel.swift
//  ThirdMission
//
//  Created by Rafael on 10/11/23.
//

import UIKit

class PaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        
        return contentSize
    }
}
