//
//  PlaceViewController.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 29.12.2020.
//  Copyright © 2020 Вадим Аписов. All rights reserved.
//

import UIKit

class PlaceViewController: UITableViewController {
    
    var placeToEdit: Place!
    var imageIsChanged = false
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        
        placeName.addTarget(self, action: #selector(placeNameChanged), for: .editingChanged)
        
        getPlaceFromMainVC()
    }
    
    // MARK: - Getting place from MainViewController
    
    private func getPlaceFromMainVC() {
        guard placeToEdit != nil, let imageData = placeToEdit?.imageData, let image = UIImage(data: imageData) else { return }
        
        setupNavigationBar()
        
        imageIsChanged = true
        
        placeImage.image = image
        placeName.text = placeToEdit?.name
        placeLocation.text = placeToEdit?.location
        placeType.text = placeToEdit?.type
        ratingControl.rating = Int(placeToEdit.rating)
        
        placeImage.contentMode = .scaleAspectFill
    }
    
    private func setupNavigationBar() {
        title = placeToEdit?.name
        saveButton.isEnabled = true
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath == [0, 0] else { return }
        
        let cameraIcon = #imageLiteral(resourceName: "camera")
        let photoIcon = #imageLiteral(resourceName: "photo")
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.getImage(source: .camera)
        }
        camera.setValue(cameraIcon, forKey: "image")
        camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let photoLibrary = UIAlertAction(title: "Photo library", style: .default) { _ in
            self.getImage(source: .photoLibrary)
        }
        photoLibrary.setValue(photoIcon, forKey: "image")
        photoLibrary.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - Adding new places and editing places
    
    func savePlace(){
        var image: UIImage?
        
        image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        
        let imageData = image?.pngData()
        
        let place = Place(imageData: imageData, name: placeName.text!, location: placeLocation.text, type: placeType.text, rating: Double(ratingControl.rating))

        if placeToEdit != nil {
            try! realm.write {
                placeToEdit?.imageData = place.imageData
                placeToEdit?.name = place.name
                placeToEdit?.location = place.location
                placeToEdit?.type = place.type
                placeToEdit?.rating = place.rating
            }
        } else {
            StorageManager.savePlaceToDB(place)
        }
    }
    
    // MARK: - Closing PlaceViewController
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

// MARK: - Text field delegate

extension PlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @objc private func placeNameChanged() {
        saveButton.isEnabled = placeName.text?.isEmpty == false ? true : false
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
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
    
}
