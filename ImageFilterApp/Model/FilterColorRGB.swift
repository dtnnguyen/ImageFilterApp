//
//  ColorRGBFilter.swift
//  ImageFilterApp
//
//  Created by Trang Nguyen on 2017-04-13.
//  Copyright © 2017 Trang Nguyen. All rights reserved.
//

import Foundation

open class ColorRGBFilter : Filter{
    
    public override init()
    {
        super.init()
    }
    
    public override init(inFilterType: Filters_Enum, inFactor: Double) {
        super.init(inFilterType: inFilterType, inFactor: inFactor)
    }
    
    open override func applyFilter(_ inPixel : Pixel) -> Pixel {
            
        var outPixel : Pixel = inPixel
        
        var newR : Double, newG: Double, newB: Double
        
        if ( filterType == .nightVision)
        {
            // apply formula
            let visionPixel = Vect4D(X:0.1, Y:0.95, Z: 0.2, W:0.0)
            
            // apply formula and cap values
             newR = max ( 0, min (255, Double(inPixel.red) * visionPixel.x * factor))
             newG = max ( 0, min (255, Double(inPixel.green) * visionPixel.y * factor))
             newB = max ( 0, min (255, Double(inPixel.blue) * visionPixel.z * factor))
        }
        else if ( filterType == .yellow){
            // apply formula
            newR = Double(inPixel.red) * factor
            newG = Double(inPixel.green) * factor
            newB = 0
        }
        else if ( filterType == .teal ){
            // apply formula
            newR = 0
            newG = Double(inPixel.green) * factor
            newB = Double(inPixel.blue) * factor
        }
        else if ( filterType == .gray){
            // apply formula
            let newVal = factor * (Double(inPixel.red) + Double(inPixel.green) + Double(inPixel.blue) ) / 3.0
            newR = newVal
            newG = newVal
            newB = newVal
        }
        else
        {
            // apply formula
             newR = (filterType == .red || filterType == .purple) ? Double(inPixel.red) * factor : 0
             newG = (filterType == .green ) ? Double(inPixel.green) * factor : 0
             newB = (filterType == .blue || filterType == .purple) ? Double(inPixel.blue) * factor : 0
        }
        
        // cap values, update output pixel
        outPixel.red = UInt8(max ( 0, min (255, newR)))
        outPixel.green = UInt8(max ( 0, min (255, newG)))
        outPixel.blue = UInt8(max ( 0, min (255, newB)))
        
        return outPixel
        
    }
}
