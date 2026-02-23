//
//  CreatePostViewController.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/17/26.
//

//
//  CreatePostViewController.swift
//  BeReal-Clone
//
//  View controller for creating and uploading new posts
//

import UIKit
import CoreLocation

class CreatePostViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var locationLabel: UILabel!
    
    // MARK: - Properties
    
    private var selectedImage: UIImage?
    private let locationManager = CLLocationManager()
    private var currentLocation: PFGeoPoint?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Create Post"
        
        // Add cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Style image view
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray6
        imageView.image = ImageHelper.shared.createPlaceholder(
            color: .systemGray5,
            size: CGSize(width: 300, height: 300)
        )
        
        // Add tap gesture to image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectPhotoTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        // Style select photo button
        selectPhotoButton.layer.cornerRadius = 12
        selectPhotoButton.backgroundColor = .systemBlue
        selectPhotoButton.setTitleColor(.white, for: .normal)
        
        // Style share button
        shareButton.layer.cornerRadius = 12
        shareButton.backgroundColor = .systemGreen
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.isEnabled = false
        shareButton.alpha = 0.5
        
        // Setup caption field
        captionTextField.delegate = self
        captionTextField.layer.cornerRadius = 8
        captionTextField.layer.borderWidth = 1
        captionTextField.layer.borderColor = UIColor.systemGray4.cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: captionTextField.frame.height))
        captionTextField.leftView = paddingView
        captionTextField.leftViewMode = .always
        
        // Hide activity indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        // Add keyboard dismiss gesture
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboard)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check authorization status
        checkLocationAuthorization()
    }
    
    private func checkLocationAuthorization() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if locationSwitch.isOn {
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted:
            locationSwitch.isEnabled = false
            locationLabel.text = "Location access denied"
        @unknown default:
            break
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func selectPhotoTapped(_ sender: Any) {
        presentPhotoPicker()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        uploadPost()
    }
    
    @IBAction func locationSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            checkLocationAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
            currentLocation = nil
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Photo Selection

    private func presentPhotoPicker() {
        let actionSheet = UIAlertController(title: "Select Photo", message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }

        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad popover support
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = selectPhotoButton
            popover.sourceRect = selectPhotoButton.bounds
        }

        present(actionSheet, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = sourceType
        if sourceType == .camera {
            picker.cameraDevice = .rear
        }
        present(picker, animated: true)
    }
    
    // MARK: - Post Upload
    
    private func uploadPost() {
        guard let image = selectedImage else {
            showAlert(message: Constants.ErrorMessages.invalidImage)
            return
        }
        
        let caption = captionTextField.text?.trimmingCharacters(in: .whitespaces)
        let location = locationSwitch.isOn ? currentLocation : nil
        
        // Show loading state
        setLoadingState(true)
        
        // Create post
        Post.createPost(image: image, caption: caption, location: location) { [weak self] success, error in
            
            DispatchQueue.main.async {
                self?.setLoadingState(false)
                
                if success {
                    self?.showSuccessAndDismiss()
                } else {
                    let errorMessage = error?.localizedDescription ?? Constants.ErrorMessages.uploadFailed
                    self?.showAlert(message: errorMessage)
                }
            }
        }
    }
    
    // MARK: - UI State
    
    private func setLoadingState(_ isLoading: Bool) {
        shareButton.isEnabled = !isLoading
        selectPhotoButton.isEnabled = !isLoading
        captionTextField.isEnabled = !isLoading
        locationSwitch.isEnabled = !isLoading
        navigationItem.leftBarButtonItem?.isEnabled = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
            shareButton.setTitle("", for: .normal)
        } else {
            activityIndicator.stopAnimating()
            shareButton.setTitle("Share Post", for: .normal)
        }
    }
    
    private func updateShareButtonState() {
        let hasImage = selectedImage != nil
        shareButton.isEnabled = hasImage
        shareButton.alpha = hasImage ? 1.0 : 0.5
    }
    
    // MARK: - Navigation & Alerts
    
    private func showSuccessAndDismiss() {
        let alert = UIAlertController(
            title: "Success!",
            message: Constants.SuccessMessages.postCreated,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            imageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            imageView.image = originalImage
        }
        
        updateShareButtonState()
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension CreatePostViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray4.cgColor
    }
}

// MARK: - CLLocationManagerDelegate

extension CreatePostViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = PFGeoPoint(latitude: location.coordinate.latitude,
                                     longitude: location.coordinate.longitude)
        
        locationLabel.text = "Location enabled"
        
        // Stop updating once we have a location
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        locationLabel.text = "Location unavailable"
        currentLocation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

// MARK: - Import Parse

import Parse
