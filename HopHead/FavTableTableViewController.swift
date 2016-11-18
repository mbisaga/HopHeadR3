//
//  FavTableTableViewController.swift
//  HopHead
//
//  Created by Sophie Gairo on 11/4/16.
//  Copyright © 2016 Sophie Gairo. All rights reserved.
//

import UIKit

class FavTableTableViewController: UITableViewController {
    
    @IBOutlet var favView: UITableView!
   
    
    
    
    
    
    
    let alesColor = UIColor(red: 247, green: 183, blue: 45)
    let lagersColor = UIColor(red: 241, green: 149, blue: 40)
    let porterStoutsColor = UIColor(red: 196, green: 79, blue: 25)
    let maltsColor = UIColor(red: 171, green: 41, blue: 26)
    
    
    
    ////////////////////////////////////////////
    /////////////TABLE ARRAYS///////////////////
    ////////////////////////////////////////////
    var beerNames = [String]()
    var abvs = [Int]()
    var ibus = [Int]()
    var cats = [String]()
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //open Database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("hophead.db")
        
        
        
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //in case no beer or table has been added, create table here
        if sqlite3_exec(db, "create table if not exists beers (id integer primary key autoincrement, beerName varchar not null, breweryName varchar, breweryLocation varchar, abv integer, ibu integer, category varchar, style varchar, favorites integer, notes varchar)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error creating table: \(errmsg)")
        }
        
        
        
        //query database
        //let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, "select * from beers where favorites = (?)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error preparing select: \(errmsg)")
        }

        
        if sqlite3_bind_int(statement, 1, Int32(1)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("failure binding favorites: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            print("id = \(id); ", terminator: "")
            
            if let name = sqlite3_column_text(statement, 1) {
                let nameString = String(cString: name)
                beerNames.append(nameString)
                print("beer name = \(nameString)")
            } else {
                print("name not found")
            }
            
            
            if let category = sqlite3_column_text(statement, 6) {
                let catString = String(cString: category)
                cats.append(catString)
                print("category name = \(catString)")
            } else {
                print("name not found")
            }

            
            
            let abv =  sqlite3_column_int(statement, 4);
            //let abvInt = Int8(CInt: abv)
            abvs.append(Int(abv))
            print("abv = \(abv)")
            
            
            let ibu = sqlite3_column_int(statement, 5) ;
            ibus.append(Int(ibu))
            print("ibu = \(ibu)")

            
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        
        
        //close db & set to nil
        //if sqlite3_close(db) != SQLITE_OK {
        //  print("error closing database")
        //}
        
        // db = nil
        print(beerNames)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = UITableViewCell() as! AleTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavTableViewCell", for: indexPath) as! FavTableViewCell
        
        var color = UIColor(red: 247, green: 183, blue: 45)
        
        if cats[indexPath.item] == "Ales"{
         color = alesColor
        }
        
        if cats[indexPath.item] == "Lagers" {
         color = lagersColor
        }
        
        if cats[indexPath.item] == "PorterStouts" {
            color = porterStoutsColor
        }
        if cats[indexPath.item] == "Malts" {
            color = maltsColor
        }
        

        cell.colorView_view.backgroundColor = color
        cell.beerName_lbl.text = beerNames[indexPath.item]
        cell.abvValue_lbl.text = String(abvs[indexPath.item])
        cell.ibuValue_lbl.text = String(ibus[indexPath.item])
        cell.abv_lbl.text = "ABV:"
        cell.ibu_lbl.text = "IBU:"
        
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return beerNames.count
        }
        else
        {
            return 4//number of color accents
        }
    }

    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let name = beerNames[indexPath.row]
            beerNames.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            //remove from DB
            
            //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            //let name = cell.textLabel?.text
            //print("THIS IS THE NAME TO BE DELETED")
            print(name)
            
            
            //open Database
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("hophead.db")
            
            
            
            var db: OpaquePointer? = nil
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("error opening database")
            }
            
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            var statement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, "update beers set favorites = (?) where beerName = (?)", -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error preparing select: \(errmsg)")
            }
            
            if sqlite3_bind_int(statement, 1, Int32(0)) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("failure binding favorites: \(errmsg)")
            }
            
            
            if sqlite3_bind_text(statement, 2, name, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("failure binding name update: \(errmsg)")
            }
            
            //one step
            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("failure updating fav beer: \(errmsg)")
            }
            
            
            //finalize & reset statement
            if sqlite3_finalize(statement) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error finalizing prepared statement: \(errmsg)")
            }
            
            statement = nil
            
            //close db & set to nil
            if sqlite3_close(db) != SQLITE_OK {
                print("error closing database")
            }
            
            db = nil
            
            let alert = UIAlertController(title: "Success", message: "That beer is no longer stored in your favorites!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Nice!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
//    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
//        return "Remove"
//    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        
        if segue.identifier == "favsEdit"{
            
            
            let destination = segue.destination as? ViewController
            let cell = sender as! UITableViewCell
            let selectedRow = tableView.indexPath(for: cell)!.row
            
            destination?.SelectedValue = beerNames[selectedRow]
        }
    }

   
    
    
    


    
}
