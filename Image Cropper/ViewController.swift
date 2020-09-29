//
//  ViewController.swift
//  Image Cropper
//
//  Created by admin on 04/05/2020.
//  Copyright © 2020 AM Kirsch. All rights reserved.

import UIKit
import CropViewController


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var imagePicker = UIImagePickerController()
    
    //============================================
    // MARK: IBOutlets
    //============================================
    @IBOutlet var imageView: UIImageView!
    
    //============================================
    // MARK: Buttons
    //============================================
    @IBOutlet weak var pickerButton: UIBarButtonItem!
    @IBOutlet weak var cropButton: UIBarButtonItem!
    
    //============================================
    // MARK: Lifecycle
    //============================================
    override func viewDidLoad() {
        super.viewDidLoad()
        if imageView.image == nil {
            cropButton.isEnabled = false
        }
    }
    
    //============================================
    // MARK: Actions
    //============================================
    
    @IBAction func pickerClicked() {

        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Select pressed")
            print("imageView.image =  \( (imageView.image != nil) ? (imageView.image!.size) : CGSize(width: 0.0 , height: 0.0) ) ")

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }

   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage

        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }

        print("picker newImage.size = ", newImage.size)
        print("picker newImage byte size = \(newImage.jpegData(compressionQuality: 1)!)")
        self.imageView.image = newImage

        cropButton.isEnabled = true
        dismiss(animated: true)
    }
    
    @IBAction func cropClicked(_ sender: Any) {
           presentCropViewController()
       }
    
}

extension ViewController : CropViewControllerDelegate{
    
    func presentCropViewController() {
      guard let imageToCrop: UIImage = self.imageView.image else { return }
      let cropViewController = CropViewController( image: imageToCrop )
      cropViewController.delegate = self
      present(cropViewController, animated: true, completion: nil)
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            // 'image' is the newly cropped version of the original image
        
        print("cropped image size = \(image.size)")
        print("cropped image byte size = \(image.jpegData(compressionQuality: 1)!)")
       
        // need to calculate best size----------------------
        self.imageView.image = ImageUtilities.resizeImage(image: image, targetSize: CGSize(width: 300.0, height: 200.0))
       
        print("resizeImage size = \(self.imageView.image!.size)")
        print("resizeImage byte size = \(self.imageView.image!.jpegData(compressionQuality: 1)!)")

        

            cropViewController.dismiss(animated: true) {
            }
    }
}

class ImageUtilities {
        class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}

