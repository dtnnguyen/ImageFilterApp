//
//  FIlterBrightness.swift
//  ImageFilterApp
//
//  Created by Trang Nguyen on 2017-04-13.
//  Copyright © 2017 Trang Nguyen. All rights reserved.
//

import Foundation


open class BrightnessFilter : Filter {
    
    public override init()
    {
        super.init()
    }
    
    public override init(inFilterType: Filters_Enum, inFactor: Double) {
        super.init(inFilterType: inFilterType, inFactor: inFactor)
    }

    // Brightness level
    // brighter = increment, darker = -increment,  normal/unchange: increment = 0 
    open override func applyFilter(_ inPixel : Pixel) -> Pixel {
            
        var outPixel : Pixel = inPixel
        let increment = 30.0
        let requestedVal = increment * factor
        
        // apply formula and cap values
        let newR = max ( 0, min (255, Double(inPixel.red) + requestedVal))
        let newG = max ( 0, min (255, Double(inPixel.green) + requestedVal))
        let newB = max ( 0, min (255, Double(inPixel.blue) + requestedVal))
        
        // update output pixel
        outPixel.red = UInt8(newR)
        outPixel.green = UInt8(newG)
        outPixel.blue = UInt8(newB)
        
        return outPixel
    }

}
