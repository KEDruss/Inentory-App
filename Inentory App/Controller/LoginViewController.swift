//
//  LoginViewController.swift
//  Inentory App
//
//  Created by Egor Kosmin on 01.12.2017.
//  Copyright © 2017 Egor Kosmin. All rights reserved.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {
    
    let loginTo = "LoginTo"
    
    @IBOutlet weak var loginTouch: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var touchIDButton: UIButton!
    @IBOutlet weak var createInfoLabel: UILabel!
    struct KeychainConfiguration {
        static let serviseName = "TouchMe"
        static let accessGroup: String? = nil
    }
    var passwordItems: [KeychainConfiguration] = []
    let createLoginTouchButtonTag = 0
    let loginTouchButtonTag = 1
    let touchMe = LocalAuthentification()
    
    // проверка пароля в связке ключей
    func checkLogin (userName: String, password: String) -> Bool {
        guard userName == UserDefaults.standard.value(forKey: "userName") as? String else { return false }
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviseName, account: userName, accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return password == keychainPassword
        } catch {
            fatalError("Ошибка чтения пароля в Связке Ключей - \(error)")
        }
        return false
    }
    //MARK: viewDidLoad method
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        
        if hasLogin {
            loginTouch.setTitle("Login", for: .normal)
            loginTouch.tag = loginTouchButtonTag
            createInfoLabel.isHidden = true
        } else {
            loginTouch.setTitle("Login", for: .normal)
            loginTouch.tag = createLoginTouchButtonTag
            createInfoLabel.isHidden = false
        }
        if let storedUserName = UserDefaults.standard.value(forKey: "userName") as? String {
            loginTextField.text = storedUserName
        }
        
        touchIDButton.isHidden = !touchMe.canEvalutePolicy()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                //проеверить тот ли текст вбит в поле user
                self.performSegue(withIdentifier: self.loginTo, sender: nil)
            }
        }
        
    }
    //MARK: Login Button
    @IBAction func loginTouchButton(_ sender: UIButton) {
        
        //проверка пустого поля
        guard let newAccountName = loginTextField.text, let newPassword = passwordTextField.text, !newAccountName.isEmpty && !newPassword.isEmpty else {
            let alertView = UIAlertController(title: "Проблема со входом", message: "Неправельное имя или пароль", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Еще раз!", style: .default, handler: nil)
            alertView.addAction(okAction)
            present(alertView, animated: true, completion: nil)
            return
        }
        // если пользователь еще не осуществял вход теш создание пользователя
        
        if sender.tag == createLoginTouchButtonTag {
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey {
                UserDefaults.standard.setValue(loginTextField.text, forKey: "userName")
            }
// проверка пользователя в Fire base
            Auth.auth().signIn(withEmail: loginTextField.text!, password: passwordTextField.text!) { (user, error) in
            
                if user != nil {
                    //попытка записать пароль в связку ключей
                    do {
                        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviseName, account: newAccountName, accessGroup: KeychainConfiguration.accessGroup)
                        try passwordItem.savePassword(newPassword)
                        print("Пароль успешно сохранен в связке ключей")
                        UserDefaults.standard.set(true, forKey: "hasLoginKey")
                        self.loginTouch.tag = self.loginTouchButtonTag
                    } catch {
                        fatalError("Ошибка обновления связки ключей - \(error)")
                    }
                    
                    self.performSegue(withIdentifier: self.loginTo, sender: nil)
                }  else {
                    // пользователь был создан в Связке ключей, но его нету в пользователях FireBase
                    let alertView = UIAlertController(title: "Проблема со входом", message: "Неправельное имя или пароль", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
                    alertView.addAction(okAction)
                    self.present(alertView, animated: true, completion: nil)
                }
            }
            // проверка пользователя и вход
        } else if sender.tag == loginTouchButtonTag {
            // запуск проверки логина и пароля
            if checkLogin(userName: loginTextField.text!, password: passwordTextField.text!) {
                //проверка пользователя в FireBase
                Auth.auth().signIn(withEmail: loginTextField.text!, password: passwordTextField.text!) { (user, error) in
                    if user != nil {
                        self.performSegue(withIdentifier: self.loginTo, sender: nil)
                    }  else {
                        // если пользователь найден в Связке ключей, но его нету в пользователях FireBase
                        let alertView = UIAlertController(title: "Проблема со входом", message: "Данный пользователь не найден", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertView.addAction(okAction)
                        self.present(alertView, animated: true, completion: nil)
                    }
                }
            } else {
                //8 - Если автторизация не пройдена, выводим сообщение
                let alertView = UIAlertController(title: "Проблема со входом", message: "Неправельное имя или пароль", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Еще раз!", style: .default, handler: nil)
                alertView.addAction(okAction)
                present(alertView, animated: true, completion: nil)
            }
        }
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    //MARK: Register Touch Button
    
    @IBAction func registerTouchButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: error!._code){
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
    //MARK: TouchID Button
    @IBAction func touchIdLoginButton(_ sender: UIButton) {
        
        
        touchMe.authenticateUser { [weak self] (message) in
            if let message = message {
                let alertView = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Черт побери!", style: .default)
                alertView.addAction(okAction)
                self?.present(alertView, animated: true)
            } else {
                do {
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviseName, account: self!.loginTextField.text!, accessGroup: KeychainConfiguration.accessGroup)
               let keychainPassword = try passwordItem.readPassword()
                    
                Auth.auth().signIn(withEmail: self!.loginTextField.text!, password: keychainPassword) { (user, error) in
                    if user != nil {
                        self?.performSegue(withIdentifier: self!.loginTo, sender: nil)
                    }
                }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        
    }
    
}
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            textField.resignFirstResponder()
            loginTouchButton(loginTouch)
            //self.performSegue(withIdentifier: self.loginTo, sender: nil)
        }
        return true
    }
}
