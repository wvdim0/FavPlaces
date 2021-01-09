//
//  StorageManager.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 05.01.2021.
//  Copyright © 2021 Вадим Аписов. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func savePlaceToDB(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deletePlaceFromDB(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
    
}
