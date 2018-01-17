//
//  TouchIDAuthentication.swift
//  Inentory App
//
//  Created by Egor Kosmin on 14.01.2018.
//  Copyright © 2018 Egor Kosmin. All rights reserved.
//

import Foundation
import LocalAuthentication

class LocalAuthentification {
    let context = LAContext()
    
    func canEvalutePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    func authenticateUser(completion: @escaping (String?) -> Void) {
        
        guard canEvalutePolicy() else {
            completion("TouchID не доступен")
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Вход с помощью TouchID") { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {
                var message: String
                switch evaluateError {
                case LAError.authenticationFailed?: message = "Проблемы с аутентификацей."
                case LAError.userCancel?: message = "Вы нажали отмену."
                case LAError.userFallback?: message = "Вы нажали пароль."
                default: message = "TouchID возможно не настроен."
                }
                completion(message)
            }
        }
        
    }
}
