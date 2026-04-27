//
//  SignUpViewController.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/17/26.
//

//
//  SignUpViewController.swift
//  BeReal-Clone
//
//  View controller for user registration
//

import UIKit
import UserNotifications

class SignUpViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Sign Up"
        
        // Style sign up button
        signUpButton.layer.cornerRadius = 12
        signUpButton.backgroundColor = .systemGreen
        signUpButton.setTitleColor(.white, for: .normal)
        
        // Hide activity indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFields() {
        nameTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        // Style text fields
        [nameTextField, usernameTextField, passwordTextField, confirmPasswordTextField].forEach { textField in
            textField?.layer.cornerRadius = 8
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = UIColor.systemGray4.cgColor
            textField?.backgroundColor = .systemBackground
            
            // Add padding
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField?.frame.height ?? 0))
            textField?.leftView = paddingView
            textField?.leftViewMode = .always
        }
        
        // Configure password fields
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .newPassword
        confirmPasswordTextField.textContentType = .newPassword
        
        // Configure username field
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.textContentType = .username
    }
    
    // MARK: - IBActions
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        performSignUp()
    }
    
    // MARK: - Sign Up Logic
    
    private func performSignUp() {
        // Get input values
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              let username = usernameTextField.text?.trimmingCharacters(in: .whitespaces),
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            showAlert(message: Constants.ErrorMessages.emptyFields)
            return
        }

        // Validate inputs
        if let validationError = validateInputs(name: name, username: username, password: password, confirmPassword: confirmPassword) {
            showAlert(message: validationError)
            return
        }

        // Show loading state
        setLoadingState(true)

        // Attempt sign up
        ParseHelper.shared.signUp(username: username, name: name, password: password) { [weak self] success, error in
            
            DispatchQueue.main.async {
                self?.setLoadingState(false)
                
                if success {
                    // Show success and navigate
                    self?.showSuccessAndNavigate()
                } else {
                    // Show error
                    let errorMessage = self?.parseSignUpError(error) ?? Constants.ErrorMessages.networkError
                    self?.showAlert(message: errorMessage)
                }
            }
        }
    }
    
    // MARK: - Validation
    
    private func validateInputs(name: String, username: String, password: String, confirmPassword: String) -> String? {

        // Check for empty fields
        if name.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            return Constants.ErrorMessages.emptyFields
        }
        
        // Validate username
        if let usernameError = ParseHelper.shared.getUsernameError(username) {
            return usernameError
        }
        
        // Validate password
        if let passwordError = ParseHelper.shared.getPasswordError(password) {
            return passwordError
        }
        
        // Check password match
        if password != confirmPassword {
            return "Passwords do not match"
        }
        
        return nil
    }
    
    private func parseSignUpError(_ error: Error?) -> String {
        guard let error = error else {
            return Constants.ErrorMessages.networkError
        }
        
        let errorMessage = error.localizedDescription
        
        // Parse common error codes
        if errorMessage.contains("username") && errorMessage.contains("taken") {
            return "This username is already taken. Please choose another."
        } else if errorMessage.contains("network") || errorMessage.contains("internet") {
            return "Network error. Please check your connection and try again."
        } else {
            return errorMessage
        }
    }
    
    // MARK: - Navigation
    
    private func showSuccessAndNavigate() {
        let alert = UIAlertController(title: "Success!",
                                     message: Constants.SuccessMessages.signUpSuccess,
                                     preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.navigateToFeed()
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToFeed() {
        requestNotificationPermission()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let feedVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardID.feedViewController) as? FeedViewController {
            let navController = UINavigationController(rootViewController: feedVC)
            navController.modalPresentationStyle = .fullScreen

            // Present and dismiss sign up flow
            view.window?.rootViewController = navController
            view.window?.makeKeyAndVisible()
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    self.scheduleDailyReminder()
                }
            }
        }
    }

    private func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Constants.Notifications.identifier])

        let content = UNMutableNotificationContent()
        content.title = Constants.Notifications.title
        content.body = Constants.Notifications.body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Constants.Notifications.interval,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Constants.Notifications.identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setLoadingState(_ isLoading: Bool) {
        signUpButton.isEnabled = !isLoading
        nameTextField.isEnabled = !isLoading
        usernameTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        confirmPasswordTextField.isEnabled = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
            signUpButton.setTitle("", for: .normal)
        } else {
            activityIndicator.stopAnimating()
            signUpButton.setTitle("Create Account", for: .normal)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            dismissKeyboard()
            performSignUp()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray4.cgColor
    }
}
