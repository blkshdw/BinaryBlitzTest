//
//  TableViewController.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 24.09.16.
//
//

import UIKit
import RxSwift

class UsersListViewController: UITableViewController {
    
    let storageManager = StorageManager.instance
    
    var imageCache = Dictionary<Int, UIImage>()
    
    var disposeBag = DisposeBag()
    
    let reuseIdentifier = "UserListCell"
    
    let userFormStoryBoard = UIStoryboard(name: "UserFormViewController", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserListCell.self, forCellReuseIdentifier: reuseIdentifier)
                
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func addButtonTapped() {
        if let userFormViewController = userFormStoryBoard.instantiateInitialViewController() as? UserFormViewController {
            let navController = UINavigationController(rootViewController: userFormViewController)
            navController.modalPresentationStyle = .popover
            self.present(navController, animated: true, completion: nil)
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
        if !user.avatar_url.isEmpty {
            if let image = self.imageCache[user.id] {
                cell.avatarImage = image
            } else {
                DataManager.instance.downloadFile(url: user.avatar_url).subscribe(onNext: { data in
                    self.imageCache[user.id] = UIImage(data: data)
                    }, onCompleted: {
                        tableView.reloadRows(at: [indexPath], with: .none)
                }).addDisposableTo(disposeBag)
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = storageManager.users[indexPath.row]
        if let userFormViewController = userFormStoryBoard.instantiateInitialViewController() as? UserFormViewController {
            let navController = UINavigationController(rootViewController: userFormViewController)
            navController.modalPresentationStyle = .popover
            userFormViewController.user = user

            if let pctrl = navController.popoverPresentationController {
                pctrl.sourceView = tableView.cellForRow(at: indexPath)
                self.present(navController, animated: true, completion: nil)
            }
        }
    }

}