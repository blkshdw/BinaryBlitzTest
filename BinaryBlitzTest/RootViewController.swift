//
//  RootViewController.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 24.09.16.
//
//

import UIKit
import RxSwift

class RootViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
        
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
                    self.navigationController?.viewControllers = [UsersListViewController()]

            }).addDisposableTo(disposeBag)
    }

}
