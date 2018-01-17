//
//  CreateListViewController.swift
//  Inentory App
//
//  Created by Egor Kosmin on 16.01.2018.
//  Copyright © 2018 Egor Kosmin. All rights reserved.
//

import UIKit
import Firebase

class CreateListViewController: UIViewController {
    
    @IBOutlet weak var createNewListButton: UIButton!
    @IBOutlet weak var loginInListButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func createNewList(_ sender: UIButton) {
    }
    
    @IBAction func loginInList(_ sender: UIButton) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
