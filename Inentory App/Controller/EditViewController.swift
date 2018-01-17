//
//  EditViewController.swift
//  Inentory App
//
//  Created by Egor Kosmin on 10.11.2017.
//  Copyright © 2017 Egor Kosmin. All rights reserved.
//

import UIKit
import Firebase

protocol EditViewControllerDelegate {
    func save(itemCell: Technical)
}

class EditViewController: UIViewController, UITextFieldDelegate {
    
    let editItem = "EditItem"
    let ref = Database.database().reference()
    var itemCell: Technical?
    var delegate: EditViewControllerDelegate?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameModelText: UITextField!
    @IBOutlet weak var departmentText: UITextField!
    @IBOutlet weak var inventoryNumberText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var scpecificationText: UITextView!
    @IBOutlet weak var comment: UITextView!
    var imgQR = ModelViewController()
    var keyboardDismissTapGesture: UIGestureRecognizer?
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.upadtetextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.upadtetextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    @objc func upadtetextView (notification: Notification){
        let userInfo = notification.userInfo!
        if keyboardDismissTapGesture == nil {
            keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            keyboardDismissTapGesture?.cancelsTouchesInView = false
            self.view.addGestureRecognizer(keyboardDismissTapGesture!)
        }
        let keyboardEndFrameScreenCoordinate = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinate, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
        
    }
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        //отображение данных в тектовых полях при редактировании
        if let item = itemCell {
            
            nameModelText.text = item.nameModel
            departmentText.text = item.departments
            inventoryNumberText.text = item.inventoryNumber
            locationText.text = item.location
            scpecificationText.text = item.scpecification
            comment.text = item.comment
            if scpecificationText.text.isEmpty {
                scpecificationText.text = "Технические характеристики"
                scpecificationText.textColor = UIColor.lightGray
            }
            if comment.text.isEmpty {
                comment.text = "Комментарии"
                comment.textColor = UIColor.lightGray
            }
        }
        
    }

    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        //сохранение данных
        if itemCell == nil {
            itemCell = Technical(nameModel: nameModelText.text!, departments: departmentText.text!, location: locationText.text!, inventoryNumber: inventoryNumberText.text!, scpecification: scpecificationText.text!, comment: comment.text!)
            
        } else {
            itemCell = Technical(nameModel: nameModelText.text!, departments: departmentText.text!, location: locationText.text!, inventoryNumber: inventoryNumberText.text!, scpecification: scpecificationText.text!, comment: comment.text!, key: itemCell!.key)
            
        }
        delegate?.save(itemCell: itemCell!)
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    func sendData(itemCell: [Technical]) {
        //
    }
    func checkData(data: String) {
        //
    }
    
}
extension EditViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.scpecificationText.text == "Технические характеристики" {
            self.scpecificationText.text = ""
            self.scpecificationText.textColor = UIColor.black
        }
        if self.comment.text == "Комментарии" {
            self.comment.text = ""
            self.comment.textColor = UIColor.black
        }
        return true
    }
}

