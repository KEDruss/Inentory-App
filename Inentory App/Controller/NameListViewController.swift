//
//  NameListViewController.swift
//  Inentory App
//
//  Created by Egor Kosmin on 16.01.2018.
//  Copyright © 2018 Egor Kosmin. All rights reserved.
//

import UIKit
import Firebase

class NameListViewController: UIViewController {
    @IBOutlet weak var nameListTextFiled: UITextField!
    var text = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func checkLoginInList(_ sender: UIButton) {
        //var nameList = ""
        
        let list = Database.database().reference(withPath: nameListTextFiled.text!)
        list.observe(.value) { (snapshot) in
            if snapshot.exists() == true {
                print("массив с таким именем не пустой")
                print("попробуй найди эту ошибку\(self.nameListTextFiled.text!)")
                self.text = self.nameListTextFiled.text!
                self.performSegue(withIdentifier: "InTo", sender: self.text)
            } else {
                print("массив с таким именем не существует")
            }
        }
//        if {
//
//        }
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(text)
        if segue.identifier == "InTo" {
            let controller = segue.destination as! TableViewController
text = nameListTextFiled.text!
            controller.text = text
            

        } else {
            print("Error")
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
