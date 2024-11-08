//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
class TodoListViewController: SwipeTableViewController {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    @IBOutlet weak var searchBar: UISearchBar!
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet {
            CoreDataloadItems()
            tableView.separatorStyle = .none
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if let colour = selectedCategory?.colorString {
            title = selectedCategory!.name
            guard let nav = navigationController?.navigationBar else {fatalError("Could not find any navigation bar")}
            if let navBarColor = UIColor(hexString: colour) {
                nav.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                nav.barTintColor = navBarColor
                nav.tintColor = navBarColor
                searchBar.backgroundColor = navBarColor
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        cell.backgroundColor = UIColor(hexString: selectedCategory!.colorString!)?.darken(byPercentage:
         CGFloat(indexPath.row) / CGFloat(itemArray.count)
        )
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
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
    
    override func deleteCoreData(at indexPath: IndexPath)
    {
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        do {
            try context.save()
        }
        catch
        {
            print(error)
        }

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

