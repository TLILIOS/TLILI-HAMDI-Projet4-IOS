//
//  ViewController.swift
//  InstagridP4
//
//  Created by HAMDI TLILI on 10/03/2022.
//

import Foundation
import UIKit
import PhotosUI


// Fixer les contraintes
// https://www.youtube.com/watch?v=UPndmwPxRmY

// 3. Faire le document pour la soutenance

enum Style: Int {
    case layout1 = 0, layout2, layout3
}

class GridController: UIViewController {
    
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var swipeUpLabel: UILabel!
    @IBOutlet weak var firstHorizontalStackView: UIStackView!
    @IBOutlet weak var secondHorizontalStackView: UIStackView!
    @IBOutlet var selectedImageViews: [UIImageView]!
    @IBOutlet var gridImageViews: [UIImageView]!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet var layoutStackViewButtons: [UIButton]!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container3: UIView!
    
    private var selectedContainer: Int = 0
    private var labelSwipped = false
    private var deviceIsInPortrait = true
    private let duration = 0.5
    private var swipeGesture: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeGesture(recognizer:)))
        frameView.addGestureRecognizer(swipeGesture)
        swipeGesture.direction = .up
    }
    
    // change the direction of the swipe when detect a screen rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        deviceIsInPortrait = UIDevice.current.orientation == .portrait
        swipeGesture.direction = deviceIsInPortrait ? .up : .left
    }
    
    //  functions called after a swipe
    @objc func didSwipeGesture(recognizer: UISwipeGestureRecognizer) {
        animateView()
        presentActivityController()
    }
    
    // MARK: - IBACtions
    
    @IBAction func addPhoto(_ sender: UIButton) {
        selectedContainer = sender.tag
        
        let imagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePickerController.sourceType = .photoLibrary
        }
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @IBAction func changePhotoLayout(_ sender: UIButton) {
        guard let selectedLayout = Style(rawValue: sender.tag) else {
            return
        }
        setStyle(selectedLayout)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension GridController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // choose an image from the gallery and assign it to the button
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            gridImageViews[selectedContainer].image = pickedImage
        }
        dismiss(animated: true)
    }
}


// MARK: - Convenience Methods

extension GridController {
    
    //  animates FrameView after swipe based on screen orientation
    private func animateView() {
        var translationTransform: CGAffineTransform
        
        if deviceIsInPortrait {
            let screenHeight = UIScreen.main.bounds.height
            translationTransform = CGAffineTransform(translationX: 0, y: -screenHeight)
        } else {
            let screenWidth = UIScreen.main.bounds.width
            translationTransform = CGAffineTransform(translationX: -screenWidth, y: 0)
        }
        
        UIView.animate(withDuration: self.duration) {
            self.frameView.transform = translationTransform
        }
    }
    
    @objc func presentActivityController() {
        let renderer = UIGraphicsImageRenderer(size: frameView.bounds.size)
        let screenshot = renderer.image { _ in
            frameView.drawHierarchy(in: frameView.bounds, afterScreenUpdates: true)
        }
        let activityController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        present(activityController, animated: true)
        
        activityController.completionWithItemsHandler = { (_, _, _, _) in
            UIView.animate(withDuration: self.duration) {
                self.frameView.transform = .identity
            }
        }
    }
    
    func setStyle(_ style: Style) {
        selectedImageViews.forEach { imageView in
            imageView.isHidden = true
        }
        selectedImageViews[style.rawValue].isHidden = false
        
        switch style {
        case .layout1:
            container1.isHidden = true
            container3.isHidden = false
        case .layout2:
            container1.isHidden = false
            container3.isHidden = true
        case .layout3:
            container1.isHidden = false
            container3.isHidden = false
        }
    }
}

