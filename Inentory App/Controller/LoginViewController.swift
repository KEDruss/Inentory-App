//
//  login.swift
//  Inentory App
//
//  Created by Egor Kosmin on 19.01.2018.
//  Copyright © 2018 Egor Kosmin. All rights reserved.
//
import UIKit
import Foundation
import Firebase

class LoginViewController: UIViewController {
    
    let loginTo = "LoginTo"
    let touchMe = LocalAuthentification()
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createInfoLabel: UILabel!
    var handle: AuthStateDidChangeListenerHandle?
    
    
    struct KeychainConfiguration {
        static let serviseName = "TouchMe"
        static let accessGroup: String? = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
    }
    @objc func kbDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + kbFrameSize.height)
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrameSize.height, right: 0)
    }
    @objc func kbDidHide() {
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard Auth.auth().currentUser != nil else { return }
        print("проверка currentUser прошла")
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard user != nil else { return }
            print("проверка user прошла")
            self?.touchMe.authenticateUser(completion: { [weak self] (message) in
                if let message = message {
                    let alertView = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alertView.addAction(okAction)
                    self?.present(alertView, animated: true)
                    return
                } else {
                    print("Вот тут происходит второй переход")
                    self?.performSegue(withIdentifier: (self?.loginTo)!, sender: nil)
                    return
                }
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Auth.auth().removeStateDidChangeListener(handle!)
        //loginTextField.text = ""
        passwordTextField.text = ""
    }
    //MARK: FUNC
    func checkLogin(userName: String, password: String) -> Bool {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviseName, account: userName, accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return password == keychainPassword
            
        } catch {
            print("ошибка чтения пароля из Связки Ключей - \(error)")
        }
        return false
    }
    func savePassword(userName: String, password: String) -> Void {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviseName, account: userName, accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(password)
        } catch {
            fatalError("Ошибка сохранения пароля в Связке ключей - \(error)")
        }
    }
    //MARK: BUTTON
    @IBAction func loginIn(_ sender: UIButton) {
        guard let login = loginTextField.text, let password = passwordTextField.text, !login.isEmpty && !password.isEmpty else {
            let alertView = UIAlertController(title: "Проблема со входом", message: "Поле Email или Password пустое", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Еще раз!", style: .default, handler: nil)
            alertView.addAction(okAction)
            present(alertView, animated: true, completion: nil)
            return
        }
        if self.checkLogin(userName: login, password: password) {
            Auth.auth().signIn(withEmail: login, password: password) { [weak self] (user, error) in
                if user != nil {
                    self?.performSegue(withIdentifier: (self?.loginTo)!, sender: nil)
                    return
                }
            }
        } else {
            Auth.auth().signIn(withEmail: login, password: password) { [weak self] (user, error) in
                if user != nil {
                    self?.savePassword(userName: login, password: password)
                    print("пароль успешно сохранен в Связке ключей")
                    self?.performSegue(withIdentifier: (self?.loginTo)!, sender: nil)
                    return
                } else {
                    let alertView = UIAlertController(title: "Проблема со входом", message: "Такой пользователь не найден, или данные не верны", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Еще раз!", style: .default, handler: nil)
                    alertView.addAction(okAction)
                    self?.present(alertView, animated: true, completion: nil)
                    return
                }
            }
        }
    }
    
    @IBAction func registerLogin(_ sender: UIButton) {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        switch errorCode {
                        case .weakPassword:
                            print("Введите более сложный пароль!")
                        default:
                            print("Ошибка")
                        }
                    }
                    return
                }
                
                if user != nil {
                    user?.sendEmailVerification(completion: { (error) in
                        print(error!.localizedDescription)
                    })
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    @IBAction func changeUser(_ sender: UIButton) {
    }
}
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            
            textField.resignFirstResponder()
            
        }
        return true
    }
}
