//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Berkay Arslan on 31.10.2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import CoreData
import SwipeCellKit
class CategoryViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryArray = [Category]()
   //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        CoreloadData()
        tableView.rowHeight = 80
    }

    
    

 //MARK:  - Table View Configuration
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToCategoryIdentifier", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = categoryArray[indexPath.row].name
        cell.delegate = self

        return cell
        
    }
    
  //MARK: - Add Button Pressed Function
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = alertTextField.text!
            
           
            self.categoryArray.append(newCategory)
            self.CoreDatesave(category: newCategory)
            //self.save(category : category)
            
        }
        alert.addAction(action)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter a Category Name"
            alertTextField = textfield
            
        }
        
     
        
        present(alert, animated : true)
    }
    
    //MARK: - Go To Item
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "goToList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let selectedRow = tableView.indexPathForSelectedRow
        {
            destinationVC.selectedCategory = categoryArray[selectedRow.row]
            
        }
    }
    
    
    //MARK: - Save Data and Load Data
    
    
    func CoreDatesave(category : Category)
    {
        do
        {
            try context.save()
            
        }
        catch {
            print(error)
        }
        
        tableView.reloadData()
    }
    
    
    func CoreloadData()
    {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryArray = try context.fetch(request) }
        catch {
            print("Something happened while loading data on category \(error)")
        }
       
        tableView.reloadData()
    }
    
}

extension CategoryViewController : SwipeTableViewCellDelegate
{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
            //tableView.reloadData()
        }
       
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }

    
}
