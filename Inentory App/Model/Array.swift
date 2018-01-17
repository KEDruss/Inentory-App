//
//  Array.swift
//  Inentory App
//
//  Created by Egor Kosmin on 03.11.2017.
//  Copyright © 2017 Egor Kosmin. All rights reserved.
//

import Foundation
import Firebase

struct Technical {
    let nameModel: String //"Название модели"
    let departments: String //"Отдел материальное лицо"
    let location: String //"Площадка Отед, выставочный зал "
    let inventoryNumber: String //"Инвентарный номер"
    let scpecification: String //"Технические характеристики техники"
    //let qrcodeText: String //"qr code"
   // let imgQR: UIImageView
    let comment: String // "Комментарии"
    let key: String
    let ref: DatabaseReference?

    init(nameModel: String, departments: String, location: String, inventoryNumber: String, scpecification: String, comment: String, key: String = "") {
        self.key = key
        self.nameModel = nameModel
        self.departments = departments
        self.location = location
        self.inventoryNumber = inventoryNumber
        self.scpecification = scpecification
        self.comment = comment
        //self.qrcodeText = qrcodeText
        self.ref = nil
//        self.imgQR = imgQR
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        nameModel = snapshotValue["Название модели"] as! String
        departments = snapshotValue["Отдел материальное лицо"] as! String
        location = snapshotValue["Площадка Отдел выставочный зал"] as! String
        inventoryNumber = snapshotValue["Инвентарный номер"] as! String
        scpecification = snapshotValue["Технические характеристики техники"] as! String
        comment = snapshotValue["Комментарии"] as! String
        //qrcodeText = snapshotValue["qr code"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "Название модели": nameModel,
            "Отдел материальное лицо": departments,
            "Площадка Отдел выставочный зал": location,
            "Технические характеристики техники": scpecification,
            "Инвентарный номер": inventoryNumber,
            "Комментарии": comment,
            //"qr code": qrcodeText
        ]
    }
    
    
}
//switch Technical {
//case nameModel:
//    "nameModel" = "Название модели"
//case departments:
//    "departments" = "Отдел материальное лицо"
//case location:
//    "location" = "Площадка Отед, выставочный зал"
//case scpecification:
//    "scpecification" = "Технические характеристики техники"
//case inventoryNumber:
//    "inventoryNumber" = "Инвентарный номер"
//}

