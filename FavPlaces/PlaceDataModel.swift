//
//  PlaceDataModel.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 28.12.2020.
//  Copyright © 2020 Вадим Аписов. All rights reserved.
//

import Foundation
import UIKit

struct Place {
    
    var image: UIImage!
    var name: String
    var location: String
    var type: String
    
    static let restNames = ["Burger Heroes", "Corner", "Black Star Burger", "Ketch Up Burgers", "BB&Burgers"]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        
        for place in restNames {
            places.append(Place(image: UIImage(named: place), name: place, location: "Москва", type: "Бургерная"))
        }
        
        return places
    }
    
}
