//
//  NewPlaceViewController.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 29.12.2020.
//  Copyright © 2020 Вадим Аписов. All rights reserved.
//

import UIKit

class PlaceViewController: UITableViewController {
    
    var place = Place(image: UIImage(named: "Photo"), name: "", location: "", type: "")

    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var typeTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getPlace()
    }
    
    private func getPlace() {
        imageOfPlace.image = place.image
        nameTF.text = place.name
        locationTF.text = place.location
        typeTF.text = place.type
        
        guard imageOfPlace.image != UIImage(named: "Photo") else { return }
        
        imageOfPlace.contentMode = .scaleAspectFill
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "saveSegue" else { return }
        
        let image = imageOfPlace.image
        let name = nameTF.text!
        let location = locationTF.text!
        let type = typeTF.text!
        
        place = Place(image: image, name: name, location: location, type: type)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.getImage(source: .camera)
        }
        let photoLibrary = UIAlertAction(title: "Photo library", style: .default) { _ in
            self.getImage(source: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true)
    }

}

// MARK: - Text field delegate

extension PlaceViewController: UITextFieldDelegate {
    
    // Скрытие клавиатуры по тапу на кнопку "done"
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}

// MARK: - Image picker

extension PlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func getImage(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true

        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        dismiss(animated: true)
    }
    
}
