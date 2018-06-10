//
//  ViewController.swift
//  ImageFilterApp
//
//  Created by Trang Nguyen on 2017-04-05.
//  Copyright © 2017 Trang Nguyen. All rights reserved.
//
// https://stackoverflow.com/questions/44379348/the-use-of-swift-3-objc-inference-in-swift-4-mode-is-deprecated

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, ImageProcessViewDelegate, ImageProcessViewManagerDelegate,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    // Image Views
    var initialImageName : String?          // Name of image file
    @IBOutlet weak var imageView: ImageProcessView!
    var imageViewBack: ImageProcessView?
    
    var imageViewMgr : ImageViewManager =  ImageViewManager()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Menus
    @IBOutlet var SecondaryMenu: UIView!
    @IBOutlet weak var bottomMenu: UIView!
    
    // Buttons and Label
    @IBOutlet var imageLabel: UILabel!
    @IBOutlet weak var newPhotoButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet var intensitySlider: UISlider!
    
    var bCascadeOperation:Bool = false
    var imageProcessor : ImageProcessor?
    var originalImage : UIImage?
    var filteredImage : UIImage?  // optional: may or may not exist
    
    // Previous button state
    var filterPrevState : Bool = true
    var editPrevState : Bool = false

    //
    //MARK: collection view data members
    //
    var labels = ["red", "green", "blue", "purple", "yellow", "teal", "gray", "sepia"]
    
    @IBOutlet var collectionView: UICollectionView!
    
    ////////////////////
    //MARK: View Controller Life Cycle
    ///////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize SecondaryMenu
        SecondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        
        // Transparent
        SecondaryMenu.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        // disable Compare button. Image has not changed yet.
        enableCompareButton(false)
        
        // disable Edit buttons until a filter is selsected
        enableEditButton(false)
        
        // Initialize imageView
        initialImageName = "DeerBackYardTiny"
        imageView.delegate = self
        imageView.setFileName(initialImageName!)
        imageViewMgr.addView(imageView)
        
        // add imageViewBack.
        addImageViewBack()
        imageViewMgr.delegate = self
        imageViewMgr.addView(imageViewBack!)
        
        // Initialize and add Image Label
        addImageLabel()
        
        // Initialize and add Slider 
        addIntensitySlider()
        
        // Collection View
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.gray
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "filterCell")
        
       activityIndicator.stopAnimating()   // ??
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //////////////////////
    //MARK: Add ImageView
    //////////////////////
    func addImageViewBack(){
        // Create imageView2
        let app = UIApplication.shared
        let statusBarFrameHeight = app.statusBarFrame.size.height
       
        let newFrame = CGRect(x: imageView.frame.origin.x, y: app.statusBarFrame.size.height, width: imageView.frame.width, height: imageView.frame.height)
        imageViewBack = ImageProcessView(frame: newFrame)
        imageViewBack?.delegate = self
        imageViewBack!.setFileName(initialImageName!)
        imageViewBack!.alpha = 0.0
        imageViewBack!.contentMode = .scaleAspectFit
        imageViewBack!.backgroundColor = UIColor.black
        self.view.insertSubview(imageViewBack!, belowSubview: imageView)
        
        // whenever you want to use auto-layout constraints then you have to set to false.
        imageViewBack!.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up Constraint
        let topConstraint = imageViewBack!.topAnchor.constraint(equalTo: self.view.topAnchor, constant: statusBarFrameHeight)
        let bottomConstraint = imageViewBack!.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = imageViewBack!.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = imageViewBack!.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        // Update View Controller
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
        
        imageViewBack!.isUserInteractionEnabled = true
        
        // Add Long Gesture
        let longGestureRecognizer = UILongPressGestureRecognizer (target: self, action:  #selector(ViewController.onLongPressGesture(_:)))
        imageViewBack!.addGestureRecognizer(longGestureRecognizer)
        
        // Add tap gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapImageView(_:)))
        imageViewBack!.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    //////////////////////
    //MARK: Show Image
    //////////////////////
    func showImage(_ bOriginalImageView : Bool)
    {
        let tempImage : UIImage?
        if ( bOriginalImageView)
        {   tempImage = originalImage     }
        else {
            tempImage = filteredImage
        }
        
        if (self.imageView!.bImageViewTapped) {
            self.imageView!.image = tempImage
        }
        else
        {
            UIView.transition(with: imageView, duration: 1.0, options: .transitionCrossDissolve, animations: { self.imageView!.image = tempImage }, completion: nil)
            
            activityIndicator?.stopAnimating()
        }
        
        self.imageView.layoutIfNeeded()
        
    }
    
    //////////////////////
    //MARK: Gestures
    //////////////////////
    // Handle Tap gesture
    @IBAction func tapImageView(_ recognizer:UITapGestureRecognizer) {
        recognizer.numberOfTapsRequired = 1

        // State.Began and .changed were never entered because tap is not a continuous gesture
        if ( recognizer.state == UIGestureRecognizerState.ended )
        {
            if(self.imageViewMgr.currentImageView!.bImageFiltered)
            {
                self.imageViewMgr.currentImageView!.bImageViewTapped = false
                self.imageViewMgr.currentImageView!.setShowOriginalImage(!self.imageViewMgr.currentImageView!.bShowOriginalImage)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.imageViewMgr.currentImageView!.bImageFiltered){
            self.imageViewMgr.currentImageView!.bImageViewTapped = true
            self.imageViewMgr.currentImageView!.setShowOriginalImage(!self.imageViewMgr.currentImageView!.bShowOriginalImage)
        }
        
    }
    
    // Handle long press gesture
    @IBAction func onLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if ( sender.state == UIGestureRecognizerState.ended)
        {
            if(self.imageViewMgr.currentImageView!.bImageFiltered)
            {
                self.imageViewMgr.currentImageView!.bImageViewTapped = false
                self.imageViewMgr.currentImageView!.setShowOriginalImage(!self.imageViewMgr.currentImageView!.bShowOriginalImage)
            }
        }
    }
    
    
    //////////////////////
    //MARK: New Photo
    //////////////////////
    @IBAction func OnNewPhoto(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in self.showCamera()} ) )
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in self.showAlbum() } ) )
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ) )
      
        // This line dismisses the actionSheet. This is a special case
        self.present(actionSheet, animated: true, completion: nil)
        
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        
        popoverPresentationController.permittedArrowDirections = .down
        
        popoverPresentationController.sourceView = self.view
        popoverPresentationController.sourceRect = self.view.bounds
        
    }
    
    func showCamera(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum(){
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .photoLibrary
        
        //present(cameraPicker, animated: true, completion: nil)
        present(cameraPicker, animated: true, completion: nil)
        
    }
    
    // Call when the user finish picking an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        // UnWrap the image - as? UIImage
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageViewMgr.setUIImage(image)
            enableCompareButton(false)
            if ( filterButton.isSelected) {
                hideSecondaryMenu()
                filterButton.isSelected = false
            }
            if ( editButton.isSelected ) {
                hideIntensitySlider()
                editButton.isEnabled = false
            }
        }
    }
    
    // Normally, there is a call back “DidCancel” to remove the actionsheet
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // delegate to presenter to dismiss the image picker controller
        // UIImagePicker doesnt want to worry about how it is presented.
        // It can be push on Navigation Control or displayed anyway you want.
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //////////////////////
    //MARK: Edit
    //////////////////////
    @IBAction func onEdit(_ sender: UIButton) {
        // true = show intensity slider after secondary menu is removed.
        if ( !sender.isSelected) {
            hideCollectionView()
            showIntensitySlider()
            sender.isSelected = true
        }
        else {
            hideIntensitySlider()
            showCollectionView()
            sender.isSelected = false
        }
        
    }
    
    func enableEditButton(_ bEnable : Bool){
        editButton.isEnabled = bEnable
    }
    
    func addIntensitySlider() {
        
        intensitySlider.translatesAutoresizingMaskIntoConstraints = false
        
        // Animation the slider fading in.
        self.intensitySlider.alpha = 0
        
        // Initialize values
        self.intensitySlider.maximumValue = 1.99
        self.intensitySlider.minimumValue = 0.0
        self.intensitySlider.value = 1.0
        
        self.view.addSubview(intensitySlider)
        
        let topConstraint = intensitySlider.topAnchor.constraint(equalTo: self.bottomMenu.topAnchor, constant: -44)
        
        let bottomConstraint = intensitySlider.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        
        let leftConstraint = intensitySlider.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        
        let rightConstraint = intensitySlider.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        
        let widthConstraint = imageLabel.widthAnchor.constraint(equalToConstant: intensitySlider.bounds.width)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leftConstraint, widthConstraint, rightConstraint])
        
       self.view.layoutIfNeeded()
        
    }
    
    func showIntensitySlider() {

        // Animate : phase in secondary menu
        UIView.animate(withDuration: 0.55, animations: {
            // closure as a parameter
            self.intensitySlider.alpha = 1.0
            self.enableIntensitySlider(true)
        })

    }
    
    func hideIntensitySlider() {
        self.editButton.isSelected = false
        
        UIView.animate(withDuration: 0.55, animations: {
            self.intensitySlider.alpha = 0
        }, completion: { completed in
            if ( completed) {
                self.enableIntensitySlider(false)
            }
        }) 
    }
    
    @IBAction func sliderTouchUpInSide(_ sender: UISlider) {
        let factor = sender.value
        
        enableIntensitySlider(false)
        
        activityIndicator?.startAnimating()
        self.imageViewMgr.updateIntensity(Double(factor))
        
    }
    
    func enableIntensitySlider(_ bEnable : Bool) {
        self.intensitySlider.isEnabled = bEnable
        
        if ( bEnable && self.intensitySlider.alpha > 0 ){
            self.intensitySlider.isUserInteractionEnabled = true
            self.intensitySlider.backgroundColor = UIColor.black
            self.intensitySlider.thumbTintColor = UIColor.white
        }
        else {
            self.intensitySlider.isUserInteractionEnabled = false
            self.intensitySlider.backgroundColor = UIColor.blue
            self.intensitySlider.thumbTintColor = UIColor.blue
        }
        self.intensitySlider.setNeedsDisplay()
        self.view.setNeedsDisplay()
    }
    
    func updateActivityIndicator (_ bStart : Bool){
        if bStart {
            self.activityIndicator.startAnimating()
        }
        else {
            self.activityIndicator.stopAnimating()
        }
    }
 
    
    //////////////////////
    //MARK: Compare
    //////////////////////
    @IBAction func OnCompare(_ sender: UIButton) {
        
        self.imageViewMgr.currentImageView!.setShowOriginalImage(!self.imageViewMgr.currentImageView!.bShowOriginalImage)
        
        if ( sender.isSelected){
            sender.isSelected = false
            
            // en_sable other buttons if compareButton is enabled
            self.editButton.isEnabled = self.editPrevState
            self.filterButton.isEnabled = self.filterPrevState
            self.newPhotoButton.isEnabled = !sender.isSelected
            self.shareButton.isEnabled = !sender.isSelected
        }
        else {
            sender.isSelected = true
            
            self.filterPrevState = filterButton.isEnabled
            self.editPrevState = editButton.isEnabled
            
            // disable other buttons if compareButton is enabled
            self.newPhotoButton.isEnabled = !sender.isSelected
            self.filterButton.isEnabled = !sender.isSelected
            self.editButton.isEnabled = !sender.isSelected
            self.shareButton.isEnabled = !sender.isSelected
        }
    }
    
    func enableCompareButton(_ bEnable : Bool){
        compareButton.isEnabled = bEnable
    }
    
    //////////////////////
    //MARK: Share
    //////////////////////
    @IBAction func onShare(_ sender: UIButton) {
        
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    //////////////////////
    //MARK: Image Label
    //////////////////////
    func addImageLabel() {
    
        imageLabel.text = "Original"
        imageLabel.textColor = UIColor.white
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageLabel.alpha = 0.0
        self.view.addSubview(imageLabel)
        let app = UIApplication.shared
        let statusBarFrameHeight = app.statusBarFrame.size.height
        
        let topConstraint = imageLabel.topAnchor.constraint (equalTo: self.view.topAnchor, constant: statusBarFrameHeight)
        let leftConstraint = imageLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        let heightConstraint = imageLabel.heightAnchor.constraint(equalToConstant: 44)
        let widthConstraint = imageLabel.widthAnchor.constraint(equalToConstant: imageLabel.bounds.width)
    
        NSLayoutConstraint.activate([topConstraint, leftConstraint, widthConstraint, heightConstraint])
        
        self.view.layoutIfNeeded()
    }
    
    // showImageLabel (self.bShowOriginalImage)
    func showImageLabel(_ bShowImageLabel : Bool) {
        
        if ( bShowImageLabel && self.imageViewMgr.numOfViews > 0) {
            if ( self.imageViewMgr.currentImageView!.bShowOriginalImage && self.imageViewMgr.currentImageView!.bImageFiltered) {
                imageLabel.alpha = 1.0
                self.view.bringSubview(toFront: imageLabel)
            }
        }
        else {
            imageLabel.alpha = 0.0
        }
        
    }
    
    //
    //MARK: Filters
    //
    @IBAction func OnFilter(_ sender: UIButton) {
       
        if (sender.isSelected) {
            //hideSecondaryMenu()
            hideCollectionView()
            hideIntensitySlider()
            sender.isSelected = false
        }
        else{
            hideIntensitySlider()
            //showSecondaryMenu()
            showCollectionView()
            sender.isSelected = true
        }
    }
    
    func showSecondaryMenu() {
    
        self.view.addSubview(SecondaryMenu)
     
        let bottomConstraint = SecondaryMenu.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        
        let leftConstraint = SecondaryMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        
        let rightConstraint = SecondaryMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = SecondaryMenu.heightAnchor.constraint(equalToConstant: 44)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        self.view.layoutIfNeeded()
        
        // Animation the menu fading in.
        self.SecondaryMenu.alpha = 0
        
        // Animate : phase in secondary menu
        UIView.animate(withDuration: 0.55, animations: {
            // closure as a parameter
            self.SecondaryMenu.alpha = 1.0
        })
        
    }
    
    func hideSecondaryMenu() {
        
        UIView.animate(withDuration: 0.55, animations: {
            self.SecondaryMenu.alpha = 0
            }, completion: { completed in
                if ( completed) {
                    self.SecondaryMenu.removeFromSuperview()
                }
        }) 
    }
    
    //////////////////////
    // On select specific filters - Secondary Menu
    //////////////////////
    
    @IBAction func OnRed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        imageViewMgr.onFilterd("red")
        activityIndicator.stopAnimating()
    }
    
    @IBAction func OnGreen(_ sender: UIButton) {
        activityIndicator.startAnimating()
        imageViewMgr.onFilterd("green")
        activityIndicator.stopAnimating()
    }
    
    @IBAction func OnBlue(_ sender: UIButton) {
        activityIndicator.startAnimating()
        imageViewMgr.onFilterd("blue")
        activityIndicator.stopAnimating()
    }
    
    @IBAction func OnPurple(_ sender: UIButton) {
        activityIndicator.startAnimating()
        imageViewMgr.onFilterd("purple")
        activityIndicator.stopAnimating()
    }
    
    @IBAction func OnSepia(_ sender: UIButton) {
        activityIndicator.startAnimating()
        // "vintage
        imageViewMgr.onFilterd("vintage")
        activityIndicator.stopAnimating()
    }
    
    //
    //MARK: Collection View
    //
    func showCollectionView() {
        
        self.view.addSubview(collectionView)
        
        let bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        
        let leftConstraint = collectionView.leftAnchor.constraint(equalTo: view.leftAnchor)
        
        let rightConstraint = collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 50)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        self.view.layoutIfNeeded()
        
        // Animation the menu fading in.
        self.collectionView.alpha = 0
        
        // ???? just UIView???
        UIView.animate(withDuration: 0.55, animations: {
            // closure as a parameter
            self.collectionView.alpha = 1.0
        })
    }
    
    func hideCollectionView() {
        UIView.animate(withDuration: 0.55, animations: {
            self.collectionView.alpha = 0
        }, completion: { completed in
            if ( completed) {
                self.collectionView.removeFromSuperview()
            }
        }) 
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }
    
    // DELEGATES for FLOWLAYOUT
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FilterCell
        
        cell.imageView.image = UIImage(named:labels[indexPath.row])
        if ( cell.imageView.image == nil ) {
            cell.imageView.image = UIImage(named: "sample")
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        activityIndicator?.startAnimating()
        
        self.imageViewMgr.onFilterd(self.labels[indexPath.row])
        
    }
    
}





