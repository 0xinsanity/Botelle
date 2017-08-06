//
//  TableViewCell.swift
//  Botelle
//
//  Created by Noah Hanover on 8/6/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    var primaryLabel: UILabel!
    var secondaryLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        primaryLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 0, height: 0))
        primaryLabel.textAlignment = .left
        
        secondaryLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 0, height: 0))
        secondaryLabel.textAlignment = .right
        
        primaryLabel.font = UIFont(name: "ProximaNova-Light", size: 17)
        secondaryLabel.font = UIFont(name: "ProximaNovaT-Thin", size: 17)
        primaryLabel.textColor = UIColor(rgb: 0x444444)
        secondaryLabel.textColor = UIColor(rgb: 0x8C8C8C)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(primaryLabel)
        self.addSubview(secondaryLabel)
        primaryLabel.autoPinEdge(.left, to: .left, of: self, withOffset: 15)
        secondaryLabel.autoPinEdge(.right, to: .right, of: self, withOffset: -15)
        primaryLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        secondaryLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        self.tintColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
