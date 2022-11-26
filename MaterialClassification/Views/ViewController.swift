//
//  ViewController.swift
//  MaterialClassification
//
//  Created by Anshumali Karna on 18/11/22.
//

import UIKit
import CoreML
import Vision
import SwiftGifOrigin

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nothingEhhh: UILabel!
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var MyImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    
    var MyResult : VNClassificationObservation? 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let homegif = UIImage.gif(name: "home")
        
        homeImage.image = homegif
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        closeButton.isHidden = true
        infoButton.isHidden = true
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            MyImageView.image = userImage
            
            guard let ciimage = CIImage(image: userImage) else {
                fatalError("Fatal error : CIImage")
            }
            detect(userImage: ciimage)
        }
        nothingEhhh.isHidden = true
        homeImage.isHidden = true
        closeButton.isHidden = false
        infoButton.isHidden = false
        imagePicker.dismiss(animated: true)
        
    }
    
    func detect(userImage: CIImage){
      
        guard let model = try? VNCoreMLModel(for: minc_vgg16().model) else {
            fatalError("Fatal Error: Model Import")
        }
        
        let requests = VNCoreMLRequest(model: model) { requests, error in
            guard let results = requests.results as? [VNClassificationObservation] else {
                fatalError("Fatal Error:- \(String(describing: error))")
            }
            self.MyResult = results.first
            
            print(self.MyResult!.identifier)
        }
        
        
        let handler = VNImageRequestHandler(ciImage: userImage)
        
        do {
            try handler.perform([requests])
        }
        catch {
            print(error)
        }
        
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    @IBAction func photoLibrary(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        MyImageView.image = nil
        
        closeButton.isHidden = true
        infoButton.isHidden = true
        homeImage.isHidden = false
        nothingEhhh.text = "Deleted Uhh?"
        nothingEhhh.isHidden = false
        
        
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        let alertInfo = UIAlertController(title: "Details of Material", message: "Identifiers:- \(MyResult!.identifier) \n Confidence Level:- \(MyResult!.confidence)", preferredStyle: UIAlertController.Style.alert)
        
        let okayButton = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel)
        
        alertInfo.addAction(okayButton)
        
        self.present(alertInfo, animated: true, completion: nil)
    }
}

