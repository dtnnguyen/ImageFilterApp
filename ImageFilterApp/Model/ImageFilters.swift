import Foundation
import UIKit


////////////////////////////////////////
// Helper structures, etc
////////////////////////////////////////

struct Vect4D {
    var x, y, z, w: Double
    
    init(X : Double, Y: Double, Z: Double, W: Double){
        x = X
        y = Y
        z = Z
        w = W
    }
    
    init(Xui : UInt8, Yui: UInt8, Zui: UInt8, Wui: UInt8)
    {
        self.init(X: Double(Xui), Y: Double(Yui), Z: Double(Zui), W : Double(Wui) )
    }
}


////////////////////////////////////////
// Filter Defaults
////////////////////////////////////////

// Default factors
public let defaultBrightness = 0.0
public let defaultContrast = 1.0
public let fiftyPercent = 0.5
public let twoHundredPercent = 1.50
public let lateNightFactor = 0.75
public let preDawnFactor = 0.95

// Filter Types
public enum Filters_Enum : String {
    case brightness  = "brightness"
    case contrast = "contrast"
    case nightVision = "night vision"
    case gray = "gray"
    case sepia = "sepia"
    case blackLight = "black light"
    case red = "red"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case teal = "teal"
    case yellow = "yellow" 
}

// DEFAULT filter types
public enum Default_Filters_Enum : String {
    // brightness
    case halfBrightness = "halfBrightness"
    case doubleBrightness = "doubleBrightness"
    
    // contrast
    case halfContrast = "halfContrast"
    case doubleConstrast = "doubleContrast"
    
    // night vision
    case lateNight = "lateNight"
    case preDawn = "preDawn"
    
    // sepia
    case sepia = "sepia"
    
    // RGB colours
    case red = "red"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case teal = "teal"
    case yellow = "yellow"
    case gray = "gray"
}

open class Sorter{
    
    static func filterSortByName(_ filterName : String) -> Filter {
        let defaultFilter = Default_Filters_Enum(rawValue: filterName)!
        
        switch defaultFilter  {
        case .halfBrightness:
            return filterSortByType(.brightness, -fiftyPercent )
            
        case .doubleBrightness:
            return filterSortByType(.brightness, twoHundredPercent )
            
        case .halfContrast:
            return filterSortByType(.contrast,   fiftyPercent )
            
        case .doubleConstrast:
            return filterSortByType( .contrast, twoHundredPercent )
            
        case .lateNight:
            return filterSortByType(.nightVision, lateNightFactor)
            
        case .preDawn:
             return filterSortByType(.nightVision, preDawnFactor )
        
        case .sepia:
            return filterSortByType(.sepia,  1.0 )
 
        case .red:
            return filterSortByType(.red, 1.0 )
            
        case .green:
            return filterSortByType(.green,1.0 )
            
        case .blue:
            return filterSortByType(.blue,  1.0 )
            
        case .purple:
            return filterSortByType( .purple,  1.0 )
            
        case .yellow:
            return filterSortByType( .yellow,  1.0 )
            
        case .teal:
            return filterSortByType( .teal,  1.0 )
            
        case .gray:
            return filterSortByType( .gray,  1.0 )

        //default :
          //  return filterSortByType(.brightness, defaultContrast )
        }
    }
    
    static func filterSortByType(_ inFilterType: Filters_Enum, _ inFactor: Double ) -> Filter{
        switch inFilterType {
        case .brightness:
            return BrightnessFilter(inFilterType: .brightness, inFactor: inFactor)
            
        case .contrast:
            return ContrastFilter(inFilterType: .brightness, inFactor: inFactor)
        
     //   case .blackLight:
    
        case .sepia:
            return SepiaFilter(inFilterType: .sepia, inFactor:  inFactor )
            
        case .nightVision:
             return ColorRGBFilter(inFilterType: .nightVision, inFactor:  inFactor )
            
        case .red:
            return ColorRGBFilter(inFilterType: .red, inFactor:  inFactor )
            
        case .green:
            return ColorRGBFilter(inFilterType: .green, inFactor:  inFactor )
            
        case .blue:
            return ColorRGBFilter(inFilterType: .blue, inFactor:  inFactor )
            
        case .purple:
            return ColorRGBFilter(inFilterType: .purple, inFactor:  inFactor )
            
        case .teal:
            return ColorRGBFilter(inFilterType: .teal, inFactor:  inFactor )
        
        case .yellow:
            return ColorRGBFilter(inFilterType: .yellow, inFactor:  inFactor )
            
        case .gray:
            return ColorRGBFilter(inFilterType: .gray, inFactor:  inFactor )
            
        default :
            return Filter(inFilterType: inFilterType, inFactor:  inFactor )

        }
    
    }

}

////////////////////////////////////////
// Filter Class
////////////////////////////////////////
open class Filter {
    var factor : Double
    var filterType : Filters_Enum
    
    // constructors
    public init (){
        self.factor = defaultBrightness
        self.filterType = .brightness
    }
    
    // Specify factor value and filter type
    public init (inFilterType : Filters_Enum, inFactor : Double) {
        self.factor = inFactor
        self.filterType = inFilterType
    }
    
    open func applyFilter( _ orgPix : Pixel) -> Pixel
    {
        return orgPix
    }
    
    ////////////////////////////////////////
    // Image processing functions
    ////////////////////////////////////////
    
    // Turn picture into night vision.
    // factor: 1.0 = normal/unchanged, (1...1.5] = more gree, < 1.0 = less gree
    open func nightVision(_ inPixel : Pixel, _ factor: Double) -> Pixel {
        var outPixel : Pixel = inPixel
        
        let visionPixel = Vect4D(X:0.1, Y:0.95, Z: 0.2, W:0.0)
        
        // apply formula and cap values
        let newR = max ( 0, min (255, Double(inPixel.red) * visionPixel.x * factor))
        let newG = max ( 0, min (255, Double(inPixel.green) * visionPixel.y * factor))
        let newB = max ( 0, min (255, Double(inPixel.blue) * visionPixel.z * factor))
        
        // update output pixel
        outPixel.red = UInt8(newR)
        outPixel.green = UInt8(newG)
        outPixel.blue = UInt8(newB)
        
        return outPixel
        
    }
    
}



