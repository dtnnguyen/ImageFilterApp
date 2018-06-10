//
//  FilterContrast.swift
//  ImageFilterApp
//
//  Created by Trang Nguyen on 2017-04-13.
//  Copyright © 2017 Trang Nguyen. All rights reserved.
//

import Foundation

open class ContrastFilter : Filter {
    
    public override init()
    {
        super.init()
    }
    
    public override init(inFilterType: Filters_Enum, inFactor: Double) {
        super.init(inFilterType: inFilterType, inFactor: inFactor)
    }

    // Contrast level
    // contrast: 1.0 = normal/unchanged, (1...1.5] = more contrast, < 1.0 = less contrast
    open override func applyFilter(_ inPixel : Pixel) -> Pixel {
        var outPixel : Pixel = inPixel
        
        // apply formula and cap values
        let newR = max ( 0, min (255, (((Double(outPixel.red) - 125) * factor)) + 125))
        let newG = max ( 0, min (255, (((Double(outPixel.green) - 125) * factor)) + 125))
        let newB = max ( 0, min (255, (((Double(outPixel.blue) - 125) * factor)) + 125))
        
        // update output pixel
        outPixel.red = UInt8(newR)
        outPixel.green = UInt8(newG)
        outPixel.blue = UInt8(newB)
        
        return outPixel
    }
    
}
