//
//  User.swift
//  Inentory App
//
//  Created by Egor Kosmin on 01.12.2017.
//  Copyright © 2017 Egor Kosmin. All rights reserved.
//

import Foundation
import Firebase

struct FUser {
    
    let uid: String
    let email: String
    
    init(authData: User) {
       uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
