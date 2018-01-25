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
    
    var itemsReference = TableViewController.ref
    var itemCell: List?
    var qrdata: String?
    //var scannedCode: [List]?
    
    @IBOutlet weak var nameModel: UILabel!
    @IBOutlet weak var inventoryLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var scpecificationView: UILabel!
    @IBOutlet weak var imageQR: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    var qrcodeImage: CIImage!
    
    @IBOutlet weak var itemBarButton: UIBarButtonItem!
    
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "EditItem", sender: nil)
        
        
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
    func save(itemCell: List) {
        let listRef = TableViewController.ref.child(itemCell.key)
        listRef.updateChildValues(itemCell.toAnyObject() as! [AnyHashable : Any])
        self.itemCell = itemCell
        configureView()
        
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
            categoryLabel.text = item.category
            qrCode(imgQR: imageQR)
            
            
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

