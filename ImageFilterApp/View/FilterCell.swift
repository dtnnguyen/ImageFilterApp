//
//  FilterCell.swift
//  ImageFilterApp
//
//  Created by Trang Nguyen on 2017-05-09.
//  Copyright © 2017 Trang Nguyen. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
