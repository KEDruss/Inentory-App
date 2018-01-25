//
//  TableViewController.swift
//  Inentory App
//
//  Created by Egor Kosmin on 03.11.2017.
//  Copyright © 2017 Egor Kosmin. All rights reserved.
//

import UIKit
import Firebase
import Alamofire


class Conectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

class TableViewController: UITableViewController, EditViewControllerDelegate, SendDelegate {
    
    static var ref: DatabaseReference!
    let usersReference = Database.database().reference(withPath: "online")
    let searchController = UISearchController(searchResultsController: nil)
    var filterTechnical = [List]()
    var items = [List]()
    var itemCell: List?
    var test: String?
    var user: FUser!
    var lv: LoginViewController?
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = FUser(authData: currentUser)
        
        
        TableViewController.ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("lists")
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let curUser = user {
                self.user = FUser(uid: curUser.uid, email: curUser.email!)
                let currentUserRef = self.usersReference.child(self.user.uid)
                currentUserRef.setValue(self.user.email)
                currentUserRef.onDisconnectRemoveValue()
            }
        }
        
        
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(TableViewController.update), for: .valueChanged)
        tableView?.refreshControl? = refresher
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск техники"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        
        
    }
    
    @objc func update () {
        if Conectivity.isConnectedToInternet() {
            tableView.reloadData()
            print("Yes! internet is available.")
            tableView?.refreshControl?.endRefreshing()
        } else {
            let alertView = UIAlertController(title: "Ошибка", message: "Проблемы с подключением", preferredStyle: .alert)
            alertView.addAction(
                UIAlertAction(title: "Ok", style: .default, handler: nil)
            )
            present(alertView, animated: true, completion: nil)
            print("No! internet not working!")
            tableView?.refreshControl?.endRefreshing()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        TableViewController.ref.observe(.value) { (snapshot) in
            var newItems = [List]()
            for item in snapshot.children {
                let techicalItem = List(snapshot: item as! DataSnapshot)
                newItems.append(techicalItem)
            }
            self.items = newItems
            self.tableView.reloadData()
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        itemCell = nil
        test = nil
        //showLoginView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TableViewController.ref.removeAllObservers()
    }
    
    // MARK: - Search
    func searchBarIsEmpty () -> Bool {
        return searchController.searchBar.text? .isEmpty ?? true
    }
    func filterContentForSearchText (_ searchText: String, scope: String = "All") {
        filterTechnical = items.filter { (item: List) -> Bool in
            if item.nameModel.lowercased().contains(searchText.lowercased()) {
                return true
            } else if item.inventoryNumber.lowercased().contains(searchText.lowercased()) {
                return true
            } else if item.departments.lowercased().contains(searchText.lowercased()) {
                return true
            } else if item.location.lowercased().contains(searchText.lowercased()) {
                return true
            } else if item.scpecification.lowercased().contains(searchText.lowercased()) {
                return true
            } else if item.comment.lowercased().contains(searchText.lowercased()) {
                return true
            } else {return false}
            
        }
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filterTechnical.count
        }
        return items.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        let technicalItem : List
        if isFiltering() {
            technicalItem = filterTechnical[indexPath.row]
        } else {
            technicalItem = items[indexPath.row]
        }
        cell.modelLabel.text = technicalItem.nameModel
        return cell
    }
    
    //MARK: - Segue
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if isFiltering() {
            itemCell = filterTechnical[indexPath.row]
        } else {
            itemCell = items[indexPath.row]
        }
        performSegue(withIdentifier: "DetailInfo", sender: itemCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailInfo"{
            let controller = segue.destination as! ModelViewController
            controller.itemCell = itemCell
        }
        if segue.identifier == "AddItem" {
            let controller = segue.destination as! EditViewController
            controller.delegate = self
            
        }
        if segue.identifier == "Scan" {
            let controller = segue.destination as! ScanController
            controller.delegate = self
            
            
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isFiltering() {
            itemCell = filterTechnical[indexPath.row]
        } else {
            itemCell = items[indexPath.row]
        }
        performSegue(withIdentifier: "DetailInfo", sender: itemCell)
        
        
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = items[indexPath.row]
            item.ref?.removeValue()
        }
    }
    
    func save(itemCell: List) {
        let key = "\(items.count)"
        let listRef = TableViewController.ref.child(key)
        listRef.setValue(itemCell.toAnyObject())
        tableView.reloadData()
        
        // Сохранение после добавления
    }
    
    func checkData(data: String) {
        if itemCell == nil{
            for item in items {
                if item.inventoryNumber.lowercased().contains(data.lowercased()){
                    itemCell = item
                }
            }
            if itemCell != nil{
                performSegue(withIdentifier: "DetailInfo", sender: itemCell)
                dismiss(animated: true, completion: nil)
            }
        }else {
            return
        }
    }
    
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        
    }
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        
        
        let alertView = UIAlertController(title: "Выход", message: "Вы уверены что хотите выйти из учетной записи?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ок", style: .default) { action  in
            do {
                try Auth.auth().signOut()
                let currentUserRef = self.usersReference.child(self.user.uid)
                currentUserRef.setValue(self.user.email)
                currentUserRef.removeValue()
                TableViewController.ref.removeAllObservers()
                self.dismiss(animated: true, completion: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        alertView.addAction(ok)
        alertView.addAction(cancel)
        present(alertView, animated: true, completion: nil)

    }
    
}
extension TableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
