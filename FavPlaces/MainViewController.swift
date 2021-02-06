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
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        
        return text.isEmpty
    }
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reverseSortingButton: UIBarButtonItem!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserDefaults.standard.bool(forKey: "firstLaunch") {
            addingPlacesOnfirstLaunch()
        }
        
        places = realm.objects(Place.self)
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search places"
        definesPresentationContext = true
        
        if #available(iOS 13, *) {
        }
        else {
            navigationItem.searchController = searchController
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        navigationItem.searchController = searchController
    }
    
    // MARK: - Adding places on first launch of the app
    
    private func addingPlacesOnfirstLaunch() {
        var placesForFirstLaunch = [Place]()
        let placeNames = ["Burger Heroes", "Corner", "Black Star Burger", "BB&Burgers", "Ketch Up Burgers"]
        
        for name in placeNames {
            placesForFirstLaunch.append(Place(imageData: UIImage(named: name)?.pngData(), name: name, location: "Москва", type: "Бургерная", rating: 0.0))
        }
        
        for place in placesForFirstLaunch {
            StorageManager.savePlaceToDB(place)
        }
            
        UserDefaults.standard.set(true, forKey: "firstLaunch")
    }
    
    // MARK: - Tablew view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredPlaces.count
        } else {
            return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let place = isSearching ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.cosmosView.rating = place.rating
        
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

        let place = isSearching ? filteredPlaces[indexForSelectedRow] : places[indexForSelectedRow]

        editPlaceVC.placeToEdit = place
        navigationVC.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        guard let placeVC = segue.source as? PlaceViewController else { return }
        
            placeVC.savePlace()
            sorting()
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
            if isSearching {
                filteredPlaces = filteredPlaces.sorted(byKeyPath: "date", ascending: ascendingSorting)
            } else {
                places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
            }
        } else {
            if isSearching {
                filteredPlaces = filteredPlaces.sorted(byKeyPath: "name", ascending: ascendingSorting)
            } else {
                places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
            }
        }
        
        tableView.reloadData()
    }
    
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterPlacesForSearchText(searchController.searchBar.text!)
    }
    
    private func filterPlacesForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR type CONTAINS[c] %@", searchText, searchText, searchText)
        
        tableView.reloadData()
    }
    
}
