//
//  UserFormViewController.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 25.09.16.
//
//

import UIKit
import RxSwift
import RxCocoa
import EZLoadingActivity

class UserFormViewController: UITableViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let NUMBER_OF_SECTIONS_EDIT = 3
    let NUMBER_OF_SECTIONS_NEW = 4
    
    let picker = UIImagePickerController()

    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func didTapUploadButton(_ sender: AnyObject) {
        picker.allowsEditing = false
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var uploadButton: UIButton!
    
    var user : User? = nil
    
    var newImageUrl = "" {
        didSet {
            if !newImageUrl.isEmpty {
                uploadButton.setTitle("Uploaded", for: .normal)
                uploadButton.isEnabled = false
            } else {
                uploadButton.setTitle("Upload", for: .normal)
                uploadButton.isEnabled = true
            }
        }
    }

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self

        if let user = self.user {
            firstNameTextField.text = user.first_name
            lastNameTextField.text = user.last_name
            emailTextField.text = user.email
        }
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.done, target: self, action: (#selector(UserFormViewController.tapSave)))
        
        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem = saveButton
        
        let isValidForm = Observable.combineLatest(firstNameTextField.rx.text.asObservable(), lastNameTextField.rx.text.asObservable(), emailTextField.rx.text.asObservable()) { firstName, lastName, email in
            return !firstName.isEmpty && !lastName.isEmpty && email.isValidEmail()
            }
        
        isValidForm
            .subscribe(onNext: { [weak self] isValid in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isValid
            }).addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.navigationItem.title = user?.first_name ?? "New user"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (user != nil) ? NUMBER_OF_SECTIONS_EDIT : NUMBER_OF_SECTIONS_NEW
    }
    
    func tapSave() {
        if let user = self.user {
            StorageManager.instance.patchUser(user: user, first_name: firstNameTextField.text ?? "", last_name: lastNameTextField.text ?? "", email: emailTextField.text ?? "").observeOn(MainScheduler.instance)
                .subscribe(
                    onError: { error in
                        if let error = error as? DataError {
                            let alertVc = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
                            alertVc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertVc, animated: true, completion: nil)
                        }
                    },
                    onCompleted: {
                        self.navigationController?.popViewController(animated: true)
                    }
            ).addDisposableTo(disposeBag)
        } else {
            StorageManager.instance.createUser(first_name: firstNameTextField.text ?? "", last_name: lastNameTextField.text ?? "", email: emailTextField.text ?? "", avatar_url: self.newImageUrl)
                .subscribe(
                    onError: { error in
                        if let error = error as? DataError {
                            let alertVc = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
                            alertVc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertVc, animated: true, completion: nil)
                        }
                    },
                    onCompleted: {
                        self.navigationController?.popViewController(animated: true)
                    }
                ).addDisposableTo(disposeBag)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                EZLoadingActivity.show("Loading", disableUI: true)
                
                DataManager.instance.uploadImage(image: image).subscribe(onNext: { urlString in
                    self.newImageUrl = urlString
                    
                    },onError: { error in
                        if error is NetworkError {
                            EZLoadingActivity.hide(success: false, animated: true)
                        }
                    }, onCompleted: {
                        EZLoadingActivity.hide(success: true, animated: true)
                }).addDisposableTo(self.disposeBag)
                
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
