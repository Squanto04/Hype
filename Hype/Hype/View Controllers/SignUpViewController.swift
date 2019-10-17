//
//  SignUpViewController.swift
//  Hype
//
//  Created by Jordan Lamb on 10/16/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonDesign()
        fetchUser()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text,
            !username.isEmpty
            else { return }
        UserController.shared.createUserWith(username: username, profilePhoto: image) { (success) in
            if success {
                self.showHypeListVC()
            }
        }
    }
    
    func updateButtonDesign(){
        signUpButton.layer.cornerRadius = 5
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
    
    // MARK: - Class Methods
    func fetchUser() {
        UserController.shared.fetchUser { (success) in
            if success {
                self.showHypeListVC()
            }
        }
    }
    
    func showHypeListVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let vc = storyboard.instantiateInitialViewController() else { return }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
}

extension SignUpViewController: PhotoPickerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
        self.image = image
    }
    
    
}
