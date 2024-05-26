//
//  MyCollectionViewCell.swift
//  hye_eum
//
//  Created by mobicom on 5/25/24.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.layer.cornerRadius = 16.0
        contentView.layer.masksToBounds = true
    
    }

}
