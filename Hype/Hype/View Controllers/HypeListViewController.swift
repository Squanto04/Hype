//
//  HypeListViewController.swift
//  Hype
//
//  Created by Jordan Lamb on 10/14/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import UIKit

class HypeListViewController: UIViewController {
    
    // MARK: - Properties
    var refreshControl = UIRefreshControl()
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction func composeButtonTapped(_ sender: Any) {
        presentAddHypeAlert()
    }
    
    // MARK: - Helper Functions
    private func setupViews() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to see new Hypes!")
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc private func loadData() {
        HypeController.shared.fetchAllHypes { (success) in
            if success {
                self.updateViews()
            }
        }
    }
    
    private func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func presentAddHypeAlert() {
        let alert = UIAlertController(title: "Get Hype!", message: "What is hype may never die", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Hype is hype today?!"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        
        let addHypeAction = UIAlertAction(title: "Send", style: .default) { (_) in
            guard let text = alert.textFields?.first?.text,
                !text.isEmpty
                else { return }
            HypeController.shared.saveHype(with: text, completion: { (success) in
                if success {
                    self.updateViews()
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addHypeAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
}

extension HypeListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        let hype = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = hype.timestamp.formatDate()
        
        return cell
    }
    
    
}
