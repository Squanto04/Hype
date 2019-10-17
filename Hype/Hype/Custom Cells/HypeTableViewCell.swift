//
//  HypeTableViewCell.swift
//  Hype
//
//  Created by Jordan Lamb on 10/17/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import UIKit

class HypeTableViewCell: UITableViewCell {
    
    var hype: Hype? {
        didSet {
            updateViews()
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var hypeImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var hypeBodyLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpViews()
    }

    // MARK: - HelperViews
    func setUpViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.contentMode = .scaleAspectFill
        hypeImageView.layer.cornerRadius = hypeImageView.frame.height / 10
        hypeImageView.contentMode = .scaleAspectFill
    }
    
    func updateViews() {
        guard let hype = hype else { return }
        updateUser(for: hype)
        setImageView(for: hype)
        hypeBodyLabel.text = hype.body
        timestampLabel.text = hype.timestamp.formatDate()
    }
    
    func updateUser(for hype: Hype) {
        if hype.user == nil {
            UserController.shared.fetchUserFor(hype) { (user) in
                guard let user = user else { return }
                hype.user = user
                self.setUserInfo(for: user)
            }
        } else {
            setUserInfo(for: hype.user!)
        }
    }
    
    func setUserInfo(for user: User) {
        DispatchQueue.main.async {
            self.profileImageView.image = user.profilePhoto
            self.userNameLabel.text = user.username
        }
    }
    
    func setImageView(for hype: Hype) {
        if let hypeImage = hype.hypePhoto {
            hypeImageView.image = hypeImage
            hypeImageView.isHidden = false
        } else {
            hypeImageView.isHidden = true
        }
    }
    
} // EOC
