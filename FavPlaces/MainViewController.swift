//
//  MainViewController.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 26.12.2020.
//  Copyright © 2020 Вадим Аписов. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserDefaults.standard.bool(forKey: "firstLaunch") {
            addingPlacesOnfirstLaunch()
        }
        
        places = realm.objects(Place.self)
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    // MARK: - Adding places on first launch of the app
    
    private func addingPlacesOnfirstLaunch() {
        let placesForFirstLaunch = [Place(imageData: UIImage(named: "Burger Heroes")?.pngData(), name: "Burger Heroes", location: "Москва", type: "Бургерная"),
                                    Place(imageData: UIImage(named: "Corner")?.pngData(), name: "Corner", location: "Москва", type: "Бургерная"),
                                    Place(imageData: UIImage(named: "Black Star Burger")?.pngData(), name: "Black Star Burger", location: "Москва", type: "Бургерная"),
                                    Place(imageData: UIImage(named: "BB&Burgers")?.pngData(), name: "BB&Burgers", location: "Москва", type: "Бургерная"),
                                    Place(imageData: UIImage(named: "Ketch Up Burgers")?.pngData(), name: "Ketch Up Burgers", location: "Москва", type: "Бургерная")]
        
        for place in placesForFirstLaunch {
            StorageManager.savePlaceToDB(place)
        }
            
        UserDefaults.standard.set(true, forKey: "firstLaunch")
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        cell.imageOfPlace.layer.cornerRadius = 12
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let placeToDelete = places[indexPath.row]
        
        StorageManager.deletePlaceFromDB(placeToDelete)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "editPlace" else { return }
        
        let navigationVC = segue.destination as! UINavigationController
        let editPlaceVC = navigationVC.topViewController as! PlaceViewController
        let indexForSelectedRow = tableView.indexPathForSelectedRow!.row
        
        editPlaceVC.placeToEdit = places[indexForSelectedRow]
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        guard let placeVC = segue.source as? PlaceViewController else { return }
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            placeVC.savePlace()
            tableView.reloadRows(at: [indexPathForSelectedRow], with: .fade)
        } else {
            let lastIndexPath = IndexPath(row: places.count, section: 0)
            placeVC.savePlace()
            tableView.insertRows(at: [lastIndexPath], with: .fade)
        }
    }
    
}
