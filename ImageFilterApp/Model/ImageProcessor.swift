import Foundation
import UIKit

////////////////////////////////////////
// Class to Process the image!
////////////////////////////////////////

open class ImageProcessor {
    
    // true = return itself after processImage()
    // false = don't change imageRGBA, return a new copy in processImage()
    var cascade : Bool = false
    
    // image file name
    var imageName : String?
    
    // image types
    var originalImage : UIImage?
    var imageRGBA : RGBAImage?
    
    // a list of filters
    var filters : [Filter] = [Filter]()
    
    // constructor
    public init (name: String ){
        
        self.imageName = name
        
        initialize(UIImage(named: imageName!)!, itself: false)
    }
    
    public init (uiimage :UIImage, itself cascade : Bool = false)
    {
        initialize(uiimage, itself: cascade)
    }
    
    internal func initialize( _ uiimage : UIImage, itself cascade : Bool = false)
    {
        self.originalImage = uiimage
        self.imageRGBA = RGBAImage(image: originalImage!)!
        self.cascade = cascade
        
        // Set default filter and type
        self.filters.append(Filter(inFilterType: .brightness, inFactor: defaultBrightness))
        
    }
    
    open func ToUIImage()-> UIImage{
        return self.imageRGBA!.toUIImage()!
    }
    
    open func restore() -> ImageProcessor {
        self.filters.removeAll()
        
        self.imageRGBA = RGBAImage(image: self.originalImage!)
        return self
    }
    
    // Walk through the list of filters and apply each filter to each pixel
    internal func processImage()->UIImage {
       
        var outImageRGBA : RGBAImage = self.imageRGBA!
        
        // loop through each pixel in the image
        for y in 0..<self.imageRGBA!.height {
            for x in 0..<self.imageRGBA!.width {
                let dPixel = y * self.imageRGBA!.width + x
                
                let orgPix = self.imageRGBA!.pixels[dPixel]
                
                var newPix = orgPix
                
                // apply all the filters
                for aFilter in filters{
                    // one filter at a time.
                    newPix = aFilter.applyFilter(newPix)
                    
                    if ( cascade == true)
                    {
                        self.imageRGBA!.pixels[dPixel].red = newPix.red
                        self.imageRGBA!.pixels[dPixel].green = newPix.green
                        self.imageRGBA!.pixels[dPixel].blue = newPix.blue
                        self.imageRGBA!.pixels[dPixel].alpha = newPix.alpha
                    }
                    else{
                        outImageRGBA.pixels[dPixel].red = newPix.red
                        outImageRGBA.pixels[dPixel].green = newPix.green
                        outImageRGBA.pixels[dPixel].blue = newPix.blue
                        outImageRGBA.pixels[dPixel].alpha = newPix.alpha
                    }
                    
                }
            }
        }
        
        // convert the output image into UIIMage for viewing
        if ( cascade == true)
        {  return self.imageRGBA!.toUIImage()! }
        else{
            return outImageRGBA.toUIImage()!
        }
    }
    
    // Process image based on specific filter type and factor
    open func processImage(_ filter : Filters_Enum, _ factor : Double) ->UIImage {
        
        self.filters.removeAll()
        
        self.filters += [Sorter.filterSortByType(filter, factor)]
    
        return self.processImage()
    }
    
    open func updateIntensity( _ factor : Double) -> UIImage {
        
        for aFilter in self.filters {
            aFilter.factor = factor
        }
        
        return self.processImage()
    }
    
    // Create a list of default filters based on input names
    // then apply the filters to the image
    open func applyFilters( _ bClear: Bool, _ inputs : String...) -> UIImage
    {
        // Clear filters array
        if bClear { self.filters.removeAll() }
        
        for item in inputs
        {
            // add default filter to filter array
            self.filters.append ( Sorter.filterSortByName (item) )
        }
        
        // apply filter to the image RGBA
        return self.processImage()
        
    }
    
    ////////////////////////
    // Decorator pattern
    // Keep applying one filter after another to self.
    ///////////////////////
    open func applyFilter(_ filter : Filter ) -> ImageProcessor{
        self.cascade = true
        let _ = processImage(filter.filterType, filter.factor)
        return self
    }
    
}

