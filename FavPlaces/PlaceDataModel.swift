//
//  PlaceDataModel.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 28.12.2020.
//  Copyright © 2020 Вадим Аписов. All rights reserved.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var imageData: Data?
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var date = Date()
    
    convenience init(imageData: Data?, name: String, location: String?, type: String?) {
        self.init()
        
        self.imageData = imageData
        self.name = name
        self.location = location
        self.type = type
    }
    
}
