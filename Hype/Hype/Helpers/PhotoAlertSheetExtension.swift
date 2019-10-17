//
//  PhotoAlertSheetExtension.swift
//
//  Created by Jordan Lamb on 10/17/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import UIKit

extension PhotoPickerViewController {
    
    func photoPickerAlert() {
        let photoPickerAlert = UIAlertController(title: "Add a Photo", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.openPhotoLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        photoPickerAlert.addAction(cameraAction)
        photoPickerAlert.addAction(photoLibraryAction)
        photoPickerAlert.addAction(cancelAction)
        
        present(photoPickerAlert, animated: true)
    }
}
