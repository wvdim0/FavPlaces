//
//  MainViewController.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 26.12.2020.
//  Copyright © 2020 Вадим Аписов. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reverseSortingButton: UIBarButtonItem!
    var ascendingSorting = true
    var places: Results<Place>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserDefaults.standard.bool(forKey: "firstLaunch") {
            addingPlacesOnfirstLaunch()
        }
        
        places = realm.objects(Place.self)
    }
    
    // MARK: - Adding places on first launch of the app
    
    private func addingPlacesOnfirstLaunch() {
        var placesForFirstLaunch = [Place]()
        let placeNames = ["Burger Heroes", "Corner", "Black Star Burger", "BB&Burgers", "Ketch Up Burgers"]
        
        for name in placeNames {
            placesForFirstLaunch.append(Place(imageData: UIImage(named: name)?.pngData(), name: name, location: "Москва", type: "Бургерная"))
        }
        
        for place in placesForFirstLaunch {
            StorageManager.savePlaceToDB(place)
        }
            
        UserDefaults.standard.set(true, forKey: "firstLaunch")
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        cell.imageOfPlace.layer.cornerRadius = 12
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let placeToDelete = places[indexPath.row]
        
        StorageManager.deletePlaceFromDB(placeToDelete)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "editPlace" else { return }
        
        let navigationVC = segue.destination as! UINavigationController
        let editPlaceVC = navigationVC.topViewController as! PlaceViewController
        let indexForSelectedRow = tableView.indexPathForSelectedRow!.row
        
        editPlaceVC.placeToEdit = places[indexForSelectedRow]
        navigationVC.navigationBar.prefersLargeTitles = true
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
    
    // MARK: - Sorting
        
    @IBAction func sortSelected(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        
        sorting()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
    
}
