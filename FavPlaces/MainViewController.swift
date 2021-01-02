//
//  MainViewController.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 26.12.2020.
//  Copyright © 2020 Вадим Аписов. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
            
    var places = Place.getPlaces()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Favourite places"
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPlace" {
            let navigationVC = segue.destination as! UINavigationController
            let editPlaceVC = navigationVC.topViewController as! PlaceViewController
            let indexForSelectedRow = tableView.indexPathForSelectedRow!.row
            
            editPlaceVC.title = "Edit place"
            editPlaceVC.place = places[indexForSelectedRow]
        } else if segue.identifier == "addPlace" {
            let navigationVC = segue.destination as! UINavigationController
            let addPlaceVC = navigationVC.topViewController as! PlaceViewController
            
            addPlaceVC.title = "Add place"
        }
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveSegue" else { return }
        let sourceVC = segue.source as! PlaceViewController
        let placeFromSourceVC = sourceVC.place
        
        if let indexPathForEditedRow = tableView.indexPathForSelectedRow {
            places[indexPathForEditedRow.row] = placeFromSourceVC
            tableView.reloadRows(at: [indexPathForEditedRow], with: .fade)
        } else {
            let lastIndexPath = IndexPath(row: places.count, section: 0)
            places.append(placeFromSourceVC)
            tableView.insertRows(at: [lastIndexPath], with: .fade)
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        cell.imageOfPlace.image = places[indexPath.row].image
        cell.nameLabel.text = places[indexPath.row].name
        cell.locationLabel.text = places[indexPath.row].location
        cell.typeLabel.text = places[indexPath.row].type

        cell.imageOfPlace.layer.cornerRadius = 12
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        places.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedPlace = places.remove(at: sourceIndexPath.row)
        places.insert(movedPlace, at: destinationIndexPath.row)
        tableView.reloadData()
    }

}
