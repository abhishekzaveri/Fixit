//
//  ViewController.swift
//  Filterer
//
//  Created by Cyrus on 1/15/17.
//  Copyright © 2017 Cyrus. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var filteredImage:UIImage?
  var originalImage:UIImage?
  var prevSelectedFilter:UIButton?
  var selectedFilterName:String?
  var isFiltered:Bool = false
  var label = UILabel()
  
  var avgRed:Int?
  var avgGreen:Int?
  var avgBlue:Int?
  var filterIntensity:Double = 5.0
  var filteredImageDict:[String:UIImage] = [:]
  var filters = ["red", "green", "blue", "yellow", "purple"]
  @IBOutlet var imageView: UIImageView!
  
  @IBOutlet var secondaryMenu: UIView!

  @IBOutlet var originalLabelMenu: UIView!
  @IBOutlet var bottomMenu: UIView!
 
  @IBOutlet var intensitySlider: UISlider!
  @IBOutlet weak var compareBtn: UIButton!
  @IBOutlet var editBtn: UIButton!
  
  @IBOutlet var filterPurpleButton: UIButton!
  @IBOutlet var filterYellowButton: UIButton!
  @IBOutlet var filterBlueButton: UIButton!
  @IBOutlet var filterGreenButton: UIButton!
  @IBOutlet var filterRedButton: UIButton!
  @IBOutlet var filterButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()
    //load image and reset button
    originalImage = imageView.image
    compareBtn.isEnabled = false
    editBtn.isEnabled = false
    preCalculation()
    
    //hide slider
    intensitySlider.isEnabled = false
    intensitySlider.alpha = 0
    
    //tap to compare
    imageView.isUserInteractionEnabled = true
    let tapRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(ViewController.imageTapped(_:)))
    tapRecognizer.minimumPressDuration = 0.1;
    imageView.addGestureRecognizer(tapRecognizer)
    
    //origin label set up
    let w = UIScreen.main.bounds.width
    let h = UIScreen.main.bounds.height
    label = UILabel(frame: CGRect(x: w/2, y: h/2, width:120, height:30))
    label.text = "Original"
    label.center=CGPoint(x:w/2, y:h/12)
    label.textAlignment = .center
    label.backgroundColor = UIColor.black
    label.textColor = UIColor.white
    //self.view?.addSubview(label)
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func imageTapped(_ sender: UILongPressGestureRecognizer) {
    if(isFiltered) {
      if(sender.state == .began) {
        onCompare(compareBtn)
      }
      else if(sender.state == .ended){
        onCompare(compareBtn)
      }
    }
  }
  @IBAction func onShare(_ sender: AnyObject) {
    let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
    present(activityController, animated: true, completion: nil)
  }
  @IBAction func onNewPhoto(_ sender: AnyObject) {
    if filterButton.isSelected == true {
      onFilter(filterButton)
    }
    let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {action in self.showCamera()
    }))
  
    actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: {action in self.showAlbum()
    }))
  
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(actionSheet, animated:true, completion: nil)
  }
  
  func showCamera() {
    let cameraPicker = UIImagePickerController();
    cameraPicker.delegate = self
    cameraPicker.sourceType = .camera
    present(cameraPicker, animated: true, completion: nil)
  }

  func showAlbum() {
    let cameraPicker = UIImagePickerController();
    cameraPicker.delegate = self
    cameraPicker.sourceType = .photoLibrary
    present(cameraPicker, animated: true, completion: nil)
  }
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    dismiss(animated: true, completion: nil)
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      isFiltered = false
      prevSelectedFilter?.isSelected=false
      compareBtn.isSelected = false
      compareBtn.isEnabled = false
      editBtn.isSelected = false
      editBtn.isEnabled = false
      intensitySlider.alpha = 0
      intensitySlider.isEnabled = false
      originalImage = image
      filteredImage = image
      showOriginalImage()
      preCalculation()
    }
  }
  
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  @IBAction func onFilter(_ sender: UIButton) {
    if(sender.isSelected) {
      hideSecondaryMenu()
      
      sender.isSelected = false
    }
    else {
      intensitySlider.alpha = 0
      intensitySlider.isEnabled = false
      editBtn.isSelected = false
      showSecondaryMenu()
      sender.isSelected = true
    }
  }
  
  @IBAction func onEdit(_ sender: UIButton) {
    if (filterButton.isSelected) {
      onFilter(filterButton)
    }
    if (editBtn.isSelected) {
      intensitySlider.isEnabled = false
      intensitySlider.alpha = 0
      editBtn.isSelected = false
    }
    else {
      intensitySlider.isEnabled = true
      intensitySlider.alpha = 1
      editBtn.isSelected = true
    }
    
  }
  @IBAction func onSlider(_ sender: UISlider) {
    if (compareBtn.isSelected) {
      onCompare(compareBtn)
    }
    
    filterIntensity = Double(sender.value*10)
    applyFilter(selectedFilterName!)
    imageView.image = filteredImage
    
  }
  @IBAction func onRedFilter(_ sender: UIButton) {
    filterBtnAction(sender, filterName: "red")

  }
  
  @IBAction func onGreenFilter(_ sender: UIButton) {
    filterBtnAction(sender, filterName: "green")

  }
  
  @IBAction func onBlueFilter(_ sender: UIButton) {
    filterBtnAction(sender, filterName: "blue")
  }
  @IBAction func onYellowFilter(_ sender: UIButton) {
    filterBtnAction(sender, filterName: "yellow")
  }
  
  @IBAction func onPurpleFilter(_ sender: UIButton) {
    filterBtnAction(sender, filterName: "purple")
  }
  
  func filterBtnAction(_ sender:UIButton, filterName:String) {
    if(sender.isSelected) {
      sender.isSelected = false
      isFiltered = false
      compareBtn.isEnabled = false
      editBtn.isEnabled = false
      showOriginalImage()
    }
    else {
      if(isFiltered) {
        prevSelectedFilter!.isSelected = false;
      }
      selectedFilterName = filterName
      prevSelectedFilter = sender
      sender.isSelected = true
      isFiltered = true
      compareBtn.isSelected = false
      compareBtn.isEnabled = true
      editBtn.isEnabled = true
      filteredImage = applyFilter(filterName)
      showFilteredImage()
    }
  }
  
  func showSecondaryMenu() {
    displayFilterImageAsFilterSubButton()
    view.addSubview(secondaryMenu)
    secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
    let bottomContraint = secondaryMenu.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
    let leftConstraint = secondaryMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
    let rightConstraint = secondaryMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
    let heightConstraint = secondaryMenu.heightAnchor.constraint(equalToConstant: 44)
    NSLayoutConstraint.activate([bottomContraint, leftConstraint, rightConstraint, heightConstraint])
    view.layoutIfNeeded()
    self.secondaryMenu.alpha = 0
    UIView.animate(withDuration: 1, animations: {
      self.secondaryMenu.alpha = 0.6
    }) 
    
  }
  
  func hideSecondaryMenu() {
    //secondaryMenu.removeFromSuperview()
    UIView.animate(withDuration: 0.4, animations: { self.secondaryMenu.alpha=0
    }, completion: { completed in
      if completed == true {
        self.secondaryMenu.removeFromSuperview()
      }
    }) 
  }
  
  func showOriginalLabelMenu() {
    
    view.addSubview(originalLabelMenu)
    self.originalLabelMenu.alpha = 0.45
    
    originalLabelMenu.translatesAutoresizingMaskIntoConstraints = false
    
    let heightConstraint = originalLabelMenu.heightAnchor.constraint(equalToConstant: 44)
    //let verticalConstraint = originalLabelMenu.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
    let horizontalConstraint = originalLabelMenu.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    let topContraint = originalLabelMenu.topAnchor.constraint(equalTo: view.topAnchor, constant: 44)
    
    NSLayoutConstraint.activate([horizontalConstraint, heightConstraint, topContraint])
    imageView.layoutIfNeeded()
    
  }
  
  func hideOriginalLabelMenu() {
    self.originalLabelMenu.removeFromSuperview()
  }

  
  func showOriginalImage() {
    UIView.transition(with: self.imageView, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {self.imageView.image = self.originalImage}, completion: nil)
    //self.view?.addSubview(label)
    //showOriginalLabelMenu()
  }
  
  func showFilteredImage() {
    UIView.transition(with: self.imageView, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {self.imageView.image = self.filteredImage}, completion: nil)
    //self.label.removeFromSuperview()
    //hideOriginalLabelMenu()
  }
  
  @IBAction func onCompare(_ sender: UIButton) {
    if(sender.isSelected) {
      sender.isSelected = false
      
      showFilteredImage()
      hideOriginalLabelMenu()
    }
    else {
      sender.isSelected = true
      showOriginalImage()
      showOriginalLabelMenu()
    }
  }
  
  func preCalculation() {
    
    let image = originalImage
    let rgbaImage = RGBAImage(image: image!)!
    
    var totalRed = 0
    var totalGreen = 0
    var totalBlue = 0
    
    let totalPixel = rgbaImage.height * rgbaImage.width
    
    for y in 0..<rgbaImage.height {
      for x in 0..<rgbaImage.width {
        let index = y * rgbaImage.width + x
        
        var pixel = rgbaImage.pixels[index]
        
        totalRed += Int(pixel.red)
        totalGreen += Int(pixel.green)
        totalBlue += Int(pixel.blue)
        
      }
      
    }
    
    avgRed = totalRed / totalPixel
    avgGreen = totalGreen / totalPixel
    avgBlue = totalBlue / totalPixel
    
    for filter in filters {
      filteredImageDict[filter]=applyFilter(filter)
    }
  }

  
  func applyFilter(_ filter:String)->UIImage {
    
    var rgbaImage = RGBAImage(image: originalImage!)!
    
    for y in 0..<rgbaImage.height {
      for x in 0..<rgbaImage.width {
        let index = y*rgbaImage.width + x
        var pixel = rgbaImage.pixels[index]
        
        var modifier = 1 + filterIntensity*(Double(y)/Double(rgbaImage.height))
        
        switch filter {
          case "red":
            let redDelta = Int(pixel.red) - avgRed!
            if(Int(pixel.red) < avgRed) {
              modifier = 1
            }
            pixel.red = UInt8(max(min(255,Int(round(Double(avgRed!) + modifier * Double(redDelta)))), 0))
            rgbaImage.pixels[index] = pixel
          case "green":
            let greenDelta = Int(pixel.green) - avgGreen!
            
            if (Int(pixel.green) < avgGreen) {
              modifier = 1
            }
            
            pixel.green = UInt8(max(min(255, Int(round(Double(avgGreen!) + modifier * Double(greenDelta)))), 0))
            rgbaImage.pixels[index] = pixel
          
          case "blue":
            let blueDelta = Int(pixel.blue) - avgBlue!
            
            if (Int(pixel.blue) < avgBlue) {
              modifier = 1
            }
            
            pixel.blue = UInt8(max(min(255, Int(round(Double(avgBlue!) + modifier * Double(blueDelta)))), 0))
            rgbaImage.pixels[index] = pixel
            
          case "yellow":
            let redDelta = Int(pixel.red) - avgRed!
            let greenDelta = Int(pixel.green) - avgGreen!
            
            var redModifier = 1 + filterIntensity * (Double(y) / Double(rgbaImage.height))
            var greenModifier = 1 + filterIntensity * (Double(y) / Double(rgbaImage.height))
            
            if (Int(pixel.red) < avgRed) {
              redModifier = 1
            }
            if (Int(pixel.green) < avgGreen) {
              greenModifier = 1
            }
            
            pixel.red = UInt8(max(min(255, Int(round(Double(avgRed!) + redModifier * Double(redDelta)))), 0))
            pixel.green = UInt8(max(min(255, Int(round(Double(avgGreen!) + greenModifier * Double(greenDelta)))), 0))
            
            rgbaImage.pixels[index] = pixel
            
          case "purple":
            let redDelta = Int(pixel.red) - avgRed!
            let blueDelta = Int(pixel.blue) - avgBlue!
            
            var redModifier = 1 + filterIntensity * (Double(y) / Double(rgbaImage.height))
            var blueModifier = 1 + filterIntensity * (Double(y) / Double(rgbaImage.height))
            
            if (Int(pixel.red) < avgRed) {
              redModifier = 1
            }
            if (Int(pixel.blue) < avgBlue) {
              blueModifier = 1
            }
            
            pixel.red = UInt8(max(min(255, Int(round(Double(avgRed!) + redModifier * Double(redDelta)))), 0))
            pixel.blue = UInt8(max(min(255, Int(round(Double(avgBlue!) + blueModifier * Double(blueDelta)))), 0))
            
            rgbaImage.pixels[index] = pixel
            
          default:
            print("color unrecogized")
            break
        }
        
        
      }
    }
    filteredImage = rgbaImage.toUIImage()
    
    return filteredImage!
  }

  func displayFilterImageAsFilterSubButton() {
    
    filterRedButton.setTitleColor(UIColor.clear, for: UIControlState())
    
    filterGreenButton.setTitleColor(UIColor.clear, for: UIControlState())
    
    filterBlueButton.setTitleColor(UIColor.clear, for: UIControlState())
    
    filterYellowButton.setTitleColor(UIColor.clear, for: UIControlState())
    
    filterPurpleButton.setTitleColor(UIColor.clear, for: UIControlState())
    
    filterRedButton.setBackgroundImage(filteredImageDict["red"], for: UIControlState())
    
    filterGreenButton.setBackgroundImage(filteredImageDict["green"], for: UIControlState())
    
    filterBlueButton.setBackgroundImage(filteredImageDict["blue"], for: UIControlState())
    
    filterYellowButton.setBackgroundImage(filteredImageDict["yellow"], for: UIControlState())
    
    filterPurpleButton.setBackgroundImage(filteredImageDict["purple"], for: UIControlState())
    
  }

}

