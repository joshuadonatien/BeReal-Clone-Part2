//
//  LoginViewController.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/17/26.
//

//
//  LoginViewController.swift
//  BeReal-Clone
//
//  View controller for user login
//

import UIKit
import Parse
import UserNotifications

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Style login button
        loginButton.layer.cornerRadius = 12
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        
        // Style sign up button
        signUpButton.setTitleColor(.systemBlue, for: .normal)
        
        // Hide activity indicator initially
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFields() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Style text fields
        [usernameTextField, passwordTextField].forEach { textField in
            textField?.layer.cornerRadius = 8
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = UIColor.systemGray4.cgColor
            textField?.backgroundColor = .systemBackground
            
            // Add padding
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField?.frame.height ?? 0))
            textField?.leftView = paddingView
            textField?.leftViewMode = .always
        }
        
        // Configure password field
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        
        // Configure username field
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.textContentType = .username
    }
    
    // MARK: - IBActions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        performLogin()
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        navigateToSignUp()
    }
    
    // MARK: - Login Logic
    
    private func performLogin() {
        // Get input values
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespaces),
              let password = passwordTextField.text else {
            showAlert(message: Constants.ErrorMessages.emptyFields)
            return
        }
        
        // Validate inputs
        if username.isEmpty || password.isEmpty {
            showAlert(message: Constants.ErrorMessages.emptyFields)
            return
        }
        
        // Show loading state
        setLoadingState(true)
        
        // Attempt login
        ParseHelper.shared.logIn(username: username, password: password) { [weak self] success, error in
            
            DispatchQueue.main.async {
                self?.setLoadingState(false)
                
                if success {
                    // Navigate to feed
                    self?.navigateToFeed()
                } else {
                    // Show error
                    let errorMessage = error?.localizedDescription ?? Constants.ErrorMessages.networkError
                    self?.showAlert(message: errorMessage)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToFeed() {
        requestNotificationPermission()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let feedVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardID.feedViewController) as? FeedViewController {
            let navController = UINavigationController(rootViewController: feedVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
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
    
    private func navigateToSignUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardID.signUpViewController) as? SignUpViewController {
            navigationController?.pushViewController(signUpVC, animated: true)
        }
    }
    
    // MARK: - Helper Methods
    
    private func setLoadingState(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        signUpButton.isEnabled = !isLoading
        usernameTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
            loginButton.setTitle("", for: .normal)
        } else {
            activityIndicator.stopAnimating()
            loginButton.setTitle("Log In", for: .normal)
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

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            // Move to password field
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            // Perform login
            dismissKeyboard()
            performLogin()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray4.cgColor
    }
}
