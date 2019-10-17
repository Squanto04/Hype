//
//  PhotoPickerViewController.swift
//  Hype
//
//  Created by Jordan Lamb on 10/17/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import UIKit

protocol PhotoPickerDelegate: class {
    func photoSelectorViewControllerSelected(image: UIImage)
}

class PhotoPickerViewController: UIViewController {
    
    // MARK: - Properties
    let imagePicker = UIImagePickerController()
    weak var delegate: PhotoPickerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        photoPickerAlert()
    }
    
}

extension PhotoPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            delegate?.photoSelectorViewControllerSelected(image: pickedImage)
        }
        picker.dismiss(animated: true)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true)
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
