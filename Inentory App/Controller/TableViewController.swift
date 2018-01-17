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
    var text = ""
   // var itemsReference = Database.database().reference(withPath: )
    let usersReference = Database.database().reference(withPath: "online")
    let searchController = UISearchController(searchResultsController: nil)
    var filterTechnical = [Technical]()
    var items = [Technical]()
    var itemCell: Technical?
    var test: String?
    var user: User!
    
    var isAuthenticated = true
    var didReturnFromBackground = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: .UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
        
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let curUser = user {
                self.user = User(uid: curUser.uid, email: curUser.email!)
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
       // itemsReference
        Database.database().reference(withPath: text).observe(.value) { (snapshot) in
            var newItems = [Technical]()
            for item in snapshot.children {
                let techicalItem = Technical(snapshot: item as! DataSnapshot)
                newItems.append(techicalItem)
            }
            self.items = newItems
            self.tableView.reloadData()
    }
        
    }
    @objc func appWillResignActive(_ notification : Notification) {
        
        view.alpha = 1
        isAuthenticated = false
        didReturnFromBackground = true
    }
    
    @objc func appDidBecomeActive(_ notification : Notification) {
        
        if didReturnFromBackground {
            showLoginView()
        }
    }
    func showLoginView() {
        
        if !isAuthenticated {
            isAuthenticated = false
            dismiss(animated: true, completion: nil)
        }
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
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        itemCell = nil
        test = nil
        showLoginView()
    }
    
    // MARK: - Search
    func searchBarIsEmpty () -> Bool {
        return searchController.searchBar.text? .isEmpty ?? true
    }
    func filterContentForSearchText (_ searchText: String, scope: String = "All") {
        filterTechnical = items.filter { (item: Technical) -> Bool in
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return filterTechnical.count
        }
        return items.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        let technicalItem : Technical
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
        //переделать detail info на переход от контроллера к контроллеру для передачи массива данных из ScanerController
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
    
    func save(itemCell: Technical) {
        let values: [String: Any] = ["Название модели": itemCell.nameModel,
                                     "Отдел материальное лицо": itemCell.departments,
                                     "Площадка Отдел выставочный зал": itemCell.location,
                                     "Инвентарный номер": itemCell.inventoryNumber,
                                     "Технические характеристики техники": itemCell.scpecification,
                                     "Комментарии": itemCell.comment
                                     ]
        let key = "\(items.count)"
        Database.database().reference(withPath: text).child(key).setValue(values)
        //tableView.reloadData()
        
        // Сохранение после добавления
    }
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        
    }
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        isAuthenticated = false
        do{try Auth.auth().signOut()}catch{print(error.localizedDescription)}
        dismiss(animated: true, completion: nil)
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
}
extension TableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
