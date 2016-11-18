//
//  AllBeersTableTableViewController.swift
//  HopHead
//
//  Created by Sophie Gairo on 11/4/16.
//  Copyright © 2016 Sophie Gairo. All rights reserved.
//

import UIKit

class AllBeersTableTableViewController: UITableViewController {
    
    @IBOutlet var allBeersView: UITableView!
   
    
    
    ////////////////////////////////////////////
    /////////////...COLORS...///////////////////
    ////////////////////////////////////////////
    
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
    
    var favorties = [Int] ()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //self.tableView.allowsMultipleSelectionDuringEditing = false
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
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
        
        if sqlite3_prepare_v2(db, "select * from beers ", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error preparing select: \(errmsg)")
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
            
            let fav = sqlite3_column_int(statement,8) ;
            favorties.append(Int(fav))
            print("fav= \(fav)")
            
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
        print(cats)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = UITableViewCell() as! AleTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllBeersTableViewCell", for: indexPath) as! AllBeersTableViewCell
        
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
        
        //TO DO: ADD Favorites array output
        if favorties[indexPath.item]==0
        {
            cell.fav_btn.isHidden = true
        }
        
        cell.color_lbl.backgroundColor = color
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
    
    //func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //  let cell = UITableViewCell()
    // if indexPath.section == 0
    //{
    //  let beer = beerNames[indexPath.row]
    //  let abv = abvs[indexPath.row]
    // let ibu = ibus[indexPath.row]
    //                cell.textLabel?.text = beer
    //cell.textLabel?.text = String(abv)
    //}
    // else
    //{
    //var colorIndex = Int(arc4random_uniform(4) + 1)
    //  let color = alesColor
    //cell.textLabel?.backgroundColor = color
    //}
    
    // return cell
    //}
    
    
    
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
            
            if sqlite3_prepare_v2(db, "delete from beers where beerName = (?)", -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error preparing select: \(errmsg)")
            }
            
            if sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("failure binding name delete: \(errmsg)")
            }
            
            //one step
            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("failure deleting beer: \(errmsg)")
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
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        
        if segue.identifier == "allBeersEdit"{
            
            
            let destination = segue.destination as? ViewController
            let cell = sender as! UITableViewCell
            let selectedRow = tableView.indexPath(for: cell)!.row
            
            destination?.SelectedValue = beerNames[selectedRow]
        }
    }
    
}
