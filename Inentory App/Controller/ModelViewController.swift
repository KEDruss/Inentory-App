//
//  ModelViewController.swift
//  Inentory App
//
//  Created by Egor Kosmin on 03.11.2017.
//  Copyright © 2017 Egor Kosmin. All rights reserved.
//

import UIKit
import Firebase

class ModelViewController: UIViewController, EditViewControllerDelegate {
    let itemsReference = Database.database().reference()
    var itemCell: Technical?
    var qrdata: String?
    //var scannedCode: [Technical]?
    
    @IBOutlet weak var nameModel: UILabel!
    @IBOutlet weak var inventoryLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var scpecificationView: UILabel!
    @IBOutlet weak var imageQR: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var comment: UILabel!
    var qrcodeImage: CIImage!
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
        configureView()
    }
    //генератор QR code
    func qrCode (imgQR: UIImageView) {
        if qrdata == nil {
            qrdata = "\(itemCell!.inventoryNumber)"
            if let qrcode = qrdata {
                let data = qrcode.data(using: .ascii, allowLossyConversion: false)
                if let data = data {
                    let filter = CIFilter(name: "CIQRCodeGenerator")
                    filter!.setValue(data, forKey: "inputMessage")
                    qrcodeImage = filter?.outputImage
                    displayQRCodeImage()
                }
            } else {
                print("error")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // переход с ModelView на EditView
        if segue.identifier == "EditItem" {
            if let indexPath = itemCell {
                let cell = segue.destination as! EditViewController
                cell.itemCell = indexPath
                cell.delegate = self
            }
        }
    }
    //Сохранение данных при редактировании
    func save(itemCell: Technical) {
        let values: [String: Any] = ["Название модели": itemCell.nameModel,
                                     "Отдел материальное лицо": itemCell.departments,
                                     "Площадка Отдел выставочный зал": itemCell.location,
                                     "Инвентарный номер": itemCell.inventoryNumber,
                                     "Технические характеристики техники": itemCell.scpecification,
                                     "Комментарии": itemCell.comment]
        
        itemsReference.child(itemCell.key).updateChildValues(values)
        self.itemCell = itemCell
        configureView()
//        TableViewController().tableView.reloadData()
        // Сохранение после редактирования
    }
    //конфигурирование карточки техники
    func configureView () {
        if let item = itemCell {
            nameModel.text = item.nameModel
            departmentLabel.text = item.departments
            inventoryLabel.text = "Номер: \(item.inventoryNumber)"
            scpecificationView.text = item.scpecification
            location.text = "Площадка: \(item.location)"
            comment.text = item.comment
            qrCode(imgQR: imageQR)

            //imageQR.image = imageQR.image

        }
        func labelEditing (_ label: UILabel) -> Bool {
            
            label.layer.borderWidth = 1.0
            label.layer.borderColor = UIColor.gray.cgColor
            return true
        }
    }
    //отоброжение QR code в карточке
    func displayQRCodeImage() {
        let scaleX = imageQR.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imageQR.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        imageQR.image = UIImage(ciImage: transformedImage)
    }
    
}

