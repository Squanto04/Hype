//
//  HypePhotoViewController.swift
//  Hype
//
//  Created by Jordan Lamb on 10/17/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import UIKit

class HypePhotoViewController: UIViewController {
    
    // MARK: - Properties
    var image: UIImage?
    
    // MARK: - Outlets
    @IBOutlet weak var hypeBodyTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDesign()
    }
    
    // MARK: - Actions
    @IBAction func confirmButtonTapped(_ sender: Any) {
        guard let text = hypeBodyTextField.text,
            !text.isEmpty,
            let image = image
            else { return }
        HypeController.shared.saveHype(with: text, photo: image) { (success) in
            if success {
                self.dismissView()
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissView()
    }
    
    // MARK: - Helper Functions
    func updateDesign() {
        let cornerRadius: CGFloat = 5
        cancelButton.layer.cornerRadius = cornerRadius
        confirmButton.layer.cornerRadius = cornerRadius
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}

extension HypePhotoViewController: PhotoPickerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
        self.image = image
    }
}
