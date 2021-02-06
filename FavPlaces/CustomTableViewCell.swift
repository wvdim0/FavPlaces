//
//  CustomTableViewCell.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 28.12.2020.
//  Copyright © 2020 Вадим Аписов. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = 12
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
            cosmosView.backgroundColor = .none
        }
    }
    
}
