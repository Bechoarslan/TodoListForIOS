//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Berkay Arslan on 31.10.2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
class CategoryViewController: SwipeTableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryArray = [Category]()
    
   //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        CoreloadData()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }

    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError()
        }
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    
        
    }

 //MARK:  - Table View Configuration
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        cell.backgroundColor = UIColor(hexString: categoryArray[indexPath.row].colorString!)
   
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
            newCategory.colorString = UIColor.randomFlat().hexValue()
           
            self.categoryArray.append(newCategory)
            self.CoreDatesave()
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
    
    
    func CoreDatesave()
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
    
    override func deleteCoreData(at indexPath: IndexPath) {
        context.delete(categoryArray[indexPath.row])
        categoryArray.remove(at: indexPath.row)
        do
        {
            try context.save()
            
        }
        catch {
            print(error)
        }
        
    }
    
}
