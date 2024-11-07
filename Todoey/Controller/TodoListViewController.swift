//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet {
            CoreDataloadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListIdentifier", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        CoreDatasaveItem()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add New Toey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
        
           
            let newItem = Item(context: self.context)
            newItem.title = alertTextField.text!
            newItem.date = Date()
            newItem.done = false
            newItem.categoryRelationship = self.selectedCategory
            self.itemArray.append(newItem)
            self.CoreDatasaveItem()
                    
                    
                
            
            
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Enter Item"
            alertTextField = textField
        }
        
        
        alert.addAction(action)
        present(alert, animated: true)
        
        }
    
    
    
    
func CoreDatasaveItem()
        {
            do {
                try context.save()
            }
            catch
            {
                print(error)
            }
    
            tableView.reloadData()
        }
    
func CoreDataloadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), with predicate: NSPredicate? = nil)
        {
            let categoryPredicate = NSPredicate(format: "categoryRelationship.name MATCHES %@", selectedCategory!.name!)
            let sortDate = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [sortDate]
            if let safePredicate = predicate
    
            {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [safePredicate, categoryPredicate])
            }
            else {
                request.predicate = categoryPredicate
            }
    
            do
            {
                itemArray = try context.fetch(request)
    
            }
            catch {
                print(error)
            }
    
            tableView.reloadData()
        }
    

    
}

extension TodoListViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        print(request)
        
        CoreDataloadItems(with: request,with: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            CoreDataloadItems()
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}

