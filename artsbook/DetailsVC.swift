//
//  DetailsVC.swift
//  artsbook
//
//  Created by Mert Bora on 1.04.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    
    @IBOutlet weak var imageVİew: UIImageView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var yearTextfield: UITextField!
    @IBOutlet weak var artistTextfield: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    var chosenPaiting = ""
    var chosenPaitingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if chosenPaiting != "" {
            
            saveButton.isHidden = true
            
           
           
            
            // Core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaitingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameTextfield.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistTextfield.text = artist
                        }
                        if let year = result.value(forKey: "year") as? String {
                            yearTextfield.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageVİew.image = image
                        }
                        
                        
                    }
                }
            }catch{
                
            }
           
            
            
            
            
            
        }else{
            saveButton.isHidden = false
            
            nameTextfield.text = ""
            artistTextfield.text = ""
            yearTextfield.text = ""
        }
            
        
        
        

        
        // Recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        
        
        imageVİew.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageVİew.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker , animated: true, completion:nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageVİew.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
        
    }
    

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(nameTextfield.text!, forKey: "name")
        newPainting.setValue(artistTextfield.text!, forKey: "artist")
        
        if let year = Int(yearTextfield.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageVİew.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
