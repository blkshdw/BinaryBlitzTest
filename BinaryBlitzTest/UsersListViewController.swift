//
//  TableViewController.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 24.09.16.
//
//

import UIKit
import RxSwift
import Kingfisher
import EZLoadingActivity

class UsersListViewController: UITableViewController {
    
    let storageManager = StorageManager.instance
    
    var disposeBag = DisposeBag()
    
    let reuseIdentifier = "UserListCell"
    
    let userFormStoryBoard = UIStoryboard(name: "UserFormViewController", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserListCell.self, forCellReuseIdentifier: reuseIdentifier)
                
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonTapped))
        
        StorageManager.instance.fetchUsers()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onError: { error in
                    if let error = error as? DataError {
                        let alertVc = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
                        self.navigationController?.present(alertVc, animated: true, completion: nil)
                    }
                },
                onCompleted: {
                    self.tableView.reloadData()
                    
            }).addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func addButtonTapped() {
        if let userFormViewController = userFormStoryBoard.instantiateInitialViewController() as? UserFormViewController {
            self.showDetailViewController(userFormViewController, sender: self)
        }

    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storageManager.users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserListCell
        
        let user = storageManager.users[indexPath.row]
        
        cell.nameLabel.text = user.first_name + " " + user.last_name
        cell.emailLabel.text = user.email
        cell.avatarImageUrl = user.avatar_url

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = storageManager.users[indexPath.row]
        if let userFormViewController = userFormStoryBoard.instantiateInitialViewController() as? UserFormViewController {
            userFormViewController.user = user

            self.showDetailViewController(userFormViewController, sender: self)

        }
    }

}
