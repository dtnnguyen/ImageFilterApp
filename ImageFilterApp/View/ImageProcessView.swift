//
//  ImageProcessView.swift
//  ImageFilterApp
//
//  Created by Trang Nguyen on 2017-04-19.
//  Copyright © 2017 Trang Nguyen. All rights reserved.
//

import UIKit
import Foundation

//
//MARK: Delegate  will be implemented by ViewController 
//
protocol ImageProcessViewDelegate {
    func showImageLabel(_ bShowOriginalImage : Bool)
    func enableCompareButton(_ bEnable : Bool)
    func enableIntensitySlider(_ bEnable : Bool)
}

// class ImageProcessView: subclass of UIImageView
open class ImageProcessView: UIImageView {

    //MARK: Member variables
    var bCascadeOperation:Bool = false
    var imageProcessor : ImageProcessor?
    var originalImage : UIImage?
    var filteredImage : UIImage?
    
    var delegate : ImageProcessViewDelegate?
    
    // Update display as this flag is updated
    var bShowOriginalImage : Bool = true {
        willSet(newValue) {
            self.bShowOriginalImage = newValue
            showImage(self.bShowOriginalImage)
            delegate!.showImageLabel(bShowOriginalImage)
        }
    }
    
    // Update Compare button as this flag is updated
    var bImageFiltered : Bool = false {
        willSet(newValue){
            self.bImageFiltered = newValue
            delegate!.enableCompareButton(self.bImageFiltered)
        }
    }
    
    var bImageViewTapped : Bool = false
    
    var imageFileName : String?
    
    //MARK: Initialize functions
    internal func resetMembers() {
        bImageFiltered = false
        bImageViewTapped = false
        bShowOriginalImage = true
        
        originalImage = imageProcessor!.ToUIImage()
        filteredImage = originalImage
        self.image = originalImage
    }
    
    open func setUIImage(_ image: UIImage?, bOriginalImage : Bool = true) {
        imageProcessor = ImageProcessor(uiimage: image!)
        
        resetMembers()
        
        // to signal when to display Image Label.
        self.bShowOriginalImage = bOriginalImage
    }
    
    open func setFileName (_ fileName : String) {
        imageProcessor = ImageProcessor(name: "DeerBackYardTiny")
        
        resetMembers()
    }
    
    //MARK: Update flags
    open func setShowOriginalImage(_ bShowOriginal : Bool){
        self.bShowOriginalImage = bShowOriginal
    }
    
    func setImageFiltered(_ bFiltered : Bool) {
        self.bImageFiltered = bFiltered
    }
    
    //MARK: Update Image
    // Update image when UIImageView is tapped or long pressed
    func showImage( _ bOriginalImage : Bool) {
        let tempImage : UIImage?
        if ( bOriginalImage)
        {   tempImage = originalImage     }
        else {
            tempImage = filteredImage
        }
        
        if (self.bImageViewTapped) {
            self.image = tempImage
        }
        else
        {
            UIView.transition(with: self, duration: 0.50, options: .transitionCrossDissolve, animations: { self.image = tempImage }, completion: nil)
            
            // Enable Intensity slider if it's showing filtered image.
            // delegate!.enableIntensitySlider(!bOriginalImage)
        }
        
        self.layoutIfNeeded()
    }
    
    //MARK: Apply filters
    func OnFiltered(_ filtered: String) {
        filteredImage = imageProcessor?.applyFilters( true, filtered )
    }

    func onCompleteFiltered() {
        setShowOriginalImage(false)
        setImageFiltered (true)
    }
    
    //MARK: Intensity
    func updateIntensity(_ factor : Double) {
        filteredImage = self.imageProcessor?.updateIntensity(factor)
    }
    
    func onCompleteUpdateIntensity() {
        setShowOriginalImage(false)
        setImageFiltered (true)
        self.delegate!.enableIntensitySlider(true)
    }
    
}

/////////////////////////////////////
// Delegate will be implemented by ViewController
/////////////////////////////////////
protocol ImageProcessViewManagerDelegate {
    func enableEditButton(_ bEnable : Bool)
    func updateActivityIndicator(_ bStart : Bool);
}

/////////////////////////////////////
// Image View manager class
// store multiple UIImageViews
/////////////////////////////////////
open class ImageViewManager {
    //MARK: Member variables
    var imageViewArray : [ImageProcessView] = [ImageProcessView]()
    var currentImageView : ImageProcessView?
    var currentImageViewIndex : Int = -1
    var nextImageViewIndex : Int = 0
    var numOfViews : Int = 0
    var delegate: ImageProcessViewManagerDelegate?
    
    //MARK: Initialize
    init () {
    }
      
    // Set image to all UImageView
    open func setUIImage (_ image : UIImage) {
        for each in self.imageViewArray {
            each.setUIImage(image)
        }
        
    }

    //MARK: Add View
    // Add one view at a time
    open func addView(_ view : ImageProcessView){
        self.imageViewArray.append(view)
        self.numOfViews += 1
        
        if ( currentImageViewIndex == -1 && numOfViews > 0 )
        {
            currentImageViewIndex = 0
            currentImageView = self.imageViewArray [currentImageViewIndex]
        }
    }
    
    // Add all views at once
    open func initialize(_ numOfViews: Int, views: ImageProcessView...){
        self.numOfViews = numOfViews
        // add views to array
        for each in views {
            self.imageViewArray.append(each)
        }
        currentImageView = imageViewArray[0]
        currentImageViewIndex = 0
    }
    
    //MARK: Filter
    // Filtered called by ViewController
    open func onFilterd ( _ filtered : String) {
        if (currentImageViewIndex >= 0 && currentImageViewIndex < numOfViews-1 ){
            nextImageViewIndex = currentImageViewIndex + 1
        }
        else if(currentImageViewIndex == numOfViews-1) {
            nextImageViewIndex = 0
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.imageViewArray[(self?.nextImageViewIndex)!].OnFiltered(filtered)
            
            DispatchQueue.main.async { [weak self] in
                self?.imageViewArray[(self?.nextImageViewIndex)!].onCompleteFiltered()
                self?.swapViews()
                self?.delegate!.enableEditButton(true)
                self?.delegate!.updateActivityIndicator(false)
            }
        }
        
    }
    
    // MARK: Intensity
    open func updateIntensity (_ factor : Double) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.imageViewArray[(self?.currentImageViewIndex)!].updateIntensity(factor)
            
            DispatchQueue.main.async { [weak self] in
                self?.imageViewArray[(self?.currentImageViewIndex)!].onCompleteUpdateIntensity()
               // self?.swapViews()
               // self?.delegate!.enableEditButton(true)
                self?.delegate!.updateActivityIndicator(false)
            }
        }
    }
    
    //MARK: Swap views
    // Swap views after image is filtered
    open func swapViews(){
        // Swap views.
        UIView.animate(withDuration: 1.0
            , animations: {
        
            self.imageViewArray[self.nextImageViewIndex].alpha = 1.0
         
            }, completion: { completed in
                if ( completed) {
                    let prevImageIndex = self.currentImageViewIndex
                    
                    self.currentImageViewIndex = self.nextImageViewIndex
                    
                    self.currentImageView = self.imageViewArray[self.currentImageViewIndex]
                    
                    self.imageViewArray[prevImageIndex].alpha = 0
                }
        })
        
    }
}

