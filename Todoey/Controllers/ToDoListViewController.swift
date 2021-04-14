//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory : Categoryy? {
        // the following code snipet is called as soon as the selectedCategory is set
        didSet {
            loadItems()
        }
    }
    
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // this stores data in a plist format and the value could be anything
//    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        print(dataFilePath)
        
//        let newItem = Item()
//        newItem.title = "Find Mike"
//        itemArray.append(newItem)
//
//        let newItem1 = Item()
//        newItem1.title = "Buy mikee"
//        itemArray.append(newItem1)
//
//        let newItem2 = Item()
//        newItem2.title = "Remove Mike"
//        itemArray.append(newItem2)
        
//        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] {
//            itemArray = items
//        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        // this will make the selected cell to have an additional checkmark at the end of the cell
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        // Do the following to delete an item and then call save.

        // context.delete(itemArray[indexPath.row])
        // itemArray.remove(at: indexPath.row)
        
        saveItems()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // what will happen once the user clicks the add button on the ui alert
            
            let newItem = Item(context: self.context)
            newItem.done = false
            newItem.title = textField.text!
            // setting the relationship
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
//            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.saveItems()
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
//        let encoder = PropertyListEncoder()
        do {
            try context.save()
//            let data = try encoder.encode(itemArray)
//            try data.write(to: dataFilePath!)
        } catch {
            print("Error in writing \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        // reading data
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionaPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionaPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("\(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search bar methods

extension ToDoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        print(searchBar.text!)
        
        // specifies how we want to query our database
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // adds a sorting functionalty to our results
        request.sortDescriptors = [ NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

