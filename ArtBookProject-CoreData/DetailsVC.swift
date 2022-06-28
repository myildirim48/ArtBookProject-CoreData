//
//  DetailsVC.swift
//  ArtBookProject-CoreData
//
//  Created by YILDIRIM on 25.05.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var choosenPainting = ""
    var choosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if choosenPainting != "" {
            
            saveButton.isHidden = true
            //Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            
            //Filter
            let idString = choosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@ ", idString!)
            
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                      
                        if let name = result.value(forKey: "picname") as? String{
                            nameText.text = name
                        }
                        
                          if let artist = result.value(forKey: "artistName") as? String{
                              artistText.text = artist
                          }
                        if let year = result.value(forKey: "paintYear") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            
                            imageView.image = image
                        }
                        
                    }
                    
                }
            } catch{
                print("Error")
            }
            
            
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            yearText.text = ""
            nameText.text = ""
            artistText.text = ""
        }
        
        
        //Close the keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        //Select image Recognizer
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    //Choose photo from library
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    //After choosen photo from library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveButtpn(_ sender: UIButton) {
        
        //Connecting to CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(nameText.text!, forKey: "picname")
        newPainting.setValue(artistText.text, forKey: "artistName")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "paintYear")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Success")
        }catch{
            print("Error")
        }
        
        
        //Send data to ViewController
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        //Turning back to ViewController
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
}
