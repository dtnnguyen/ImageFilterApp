//
//  FilterSerbia.swift
//  ImageFilterApp
//
//  Created by Trang Nguyen on 2017-04-13.
//  Copyright © 2017 Trang Nguyen. All rights reserved.
//

import Foundation


open class SepiaFilter : Filter {
    
    public override init()
    {
        super.init()
    }
    
    public override init(inFilterType: Filters_Enum, inFactor: Double) {
        super.init(inFilterType: inFilterType, inFactor: inFactor)
    }


    // Brown tone.
    open override func applyFilter(_ inPixel : Pixel) -> Pixel {
        var outPixel : Pixel = inPixel
        
        // apply formula
        var newR = Double(outPixel.blue) * 0.189 * factor + Double(outPixel.green) * 0.769 * factor + Double(outPixel.red) * 0.393 * factor
        var newG = Double(outPixel.blue) * 0.168 * factor + Double(outPixel.green) * 0.686 * factor + Double(outPixel.red) * 0.349 * factor
        var newB = Double(outPixel.blue) * 0.131 * factor + Double(outPixel.green) * 0.534 * factor + Double(outPixel.red) * 0.272 * factor
        
        // cap values
        newR = max ( 0, min (255, newR))
        newG = max ( 0, min (255, newG))
        newB = max ( 0, min (255, newB))
        
        // update output pixel
        outPixel.red = UInt8(newR)
        outPixel.green = UInt8(newG)
        outPixel.blue = UInt8(newB)
        
        return outPixel
        
    }
}
