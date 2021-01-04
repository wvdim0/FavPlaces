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
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]

        cell.imageOfPlace.image = place.image
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type

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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPlace" {
            let navigationVC = segue.destination as! UINavigationController
            let editPlaceVC = navigationVC.topViewController as! PlaceViewController
            let indexForSelectedRow = tableView.indexPathForSelectedRow!.row
            
            editPlaceVC.title = "Edit place"
            editPlaceVC.saveButtonState = true
            editPlaceVC.place = places[indexForSelectedRow]
        } else if segue.identifier == "addPlace" {
            let navigationVC = segue.destination as! UINavigationController
            let addPlaceVC = navigationVC.topViewController as! PlaceViewController
            
            addPlaceVC.title = "Add place"
        }
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveSegue" else { return }
        let placeVC = segue.source as! PlaceViewController
        let placeFromPlaceVC = placeVC.place
        
        if let indexPathForEditedRow = tableView.indexPathForSelectedRow {
            places[indexPathForEditedRow.row] = placeFromPlaceVC
            tableView.reloadRows(at: [indexPathForEditedRow], with: .fade)
        } else {
            let lastIndexPath = IndexPath(row: places.count, section: 0)
            places.append(placeFromPlaceVC)
            tableView.insertRows(at: [lastIndexPath], with: .fade)
        }
    }

}
