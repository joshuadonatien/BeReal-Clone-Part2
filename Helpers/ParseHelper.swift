//
//  ParseHelper.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/17/26.
//

//
//  ParseHelper.swift
//  BeReal-Clone
//
//  Helper class for Parse authentication operations
//

import Foundation
import Parse

class ParseHelper {
    
    // Singleton instance
    static let shared = ParseHelper()
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    /// Sign up a new user
    /// - Parameters:
    ///   - username: User's chosen username
    ///   - password: User's password
    ///   - completion: Callback with success status and optional error
    func signUp(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        
        // Validate inputs
        guard !username.isEmpty, !password.isEmpty else {
            let error = NSError(domain: "ValidationError",
                              code: 1,
                              userInfo: [NSLocalizedDescriptionKey: Constants.ErrorMessages.emptyFields])
            completion(false, error)
            return
        }
        
        // Create new Parse user
        let user = PFUser()
        user.username = username.lowercased().trimmingCharacters(in: .whitespaces)
        user.password = password
        
        // Sign up in background
        user.signUpInBackground { success, error in
            if success {
                print("✅ User signed up successfully: \(username)")
            } else {
                print("❌ Sign up failed: \(error?.localizedDescription ?? "Unknown error")")
            }
            completion(success, error)
        }
    }
    
    /// Log in an existing user
    /// - Parameters:
    ///   - username: User's username
    ///   - password: User's password
    ///   - completion: Callback with success status and optional error
    func logIn(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        
        // Validate inputs
        guard !username.isEmpty, !password.isEmpty else {
            let error = NSError(domain: "ValidationError",
                              code: 1,
                              userInfo: [NSLocalizedDescriptionKey: Constants.ErrorMessages.emptyFields])
            completion(false, error)
            return
        }
        
        // Log in with Parse
        PFUser.logInWithUsername(inBackground: username.lowercased().trimmingCharacters(in: .whitespaces),
                                password: password) { user, error in
            if user != nil {
                print("✅ User logged in successfully: \(username)")
                completion(true, nil)
            } else {
                print("❌ Login failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(false, error)
            }
        }
    }
    
    /// Log out the current user
    /// - Parameter completion: Callback with success status and optional error
    func logOut(completion: @escaping (Bool, Error?) -> Void) {
        PFUser.logOutInBackground { error in
            if let error = error {
                print("❌ Logout failed: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("✅ User logged out successfully")
                completion(true, nil)
            }
        }
    }
    
    /// Check if a user is currently logged in
    /// - Returns: true if user is logged in, false otherwise
    func isUserLoggedIn() -> Bool {
        return PFUser.current() != nil
    }
    
    /// Get current user's username
    /// - Returns: Username string or nil
    func getCurrentUsername() -> String? {
        return PFUser.current()?.username
    }

    // MARK: - Comment Methods

    /// Fetch comments for a given post, ordered oldest first
    func fetchComments(for post: PFObject, completion: @escaping ([Comment]?, Error?) -> Void) {
        let query = PFQuery(className: Constants.ParseClass.comment)
        query.whereKey(Constants.CommentKeys.post, equalTo: post)
        query.includeKey(Constants.CommentKeys.user)
        query.order(byAscending: Constants.CommentKeys.createdAt)
        query.findObjectsInBackground { objects, error in
            if let error = error {
                completion(nil, error)
            } else if let objects = objects {
                let comments = objects.map { Comment(pfObject: $0) }
                completion(comments, nil)
            }
        }
    }

    /// Save a new comment on a post
    func createComment(text: String, post: PFObject, completion: @escaping (Bool, Error?) -> Void) {
        let comment = PFObject(className: Constants.ParseClass.comment)
        comment[Constants.CommentKeys.text] = text
        comment[Constants.CommentKeys.user] = PFUser.current()
        comment[Constants.CommentKeys.post] = post
        comment.saveInBackground { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Validation Methods
    
    /// Validate username format
    /// - Parameter username: Username to validate
    /// - Returns: true if valid, false otherwise
    func isValidUsername(_ username: String) -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 3 && trimmed.count <= 20
    }
    
    /// Validate password strength
    /// - Parameter password: Password to validate
    /// - Returns: true if valid, false otherwise
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    /// Get validation error message for username
    /// - Parameter username: Username to check
    /// - Returns: Error message or nil if valid
    func getUsernameError(_ username: String) -> String? {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        
        if trimmed.isEmpty {
            return "Username cannot be empty"
        }
        
        if trimmed.count < 3 {
            return "Username must be at least 3 characters"
        }
        
        if trimmed.count > 20 {
            return "Username cannot exceed 20 characters"
        }
        
        return nil
    }
    
    /// Get validation error message for password
    /// - Parameter password: Password to check
    /// - Returns: Error message or nil if valid
    func getPasswordError(_ password: String) -> String? {
        if password.isEmpty {
            return "Password cannot be empty"
        }
        
        if password.count < 6 {
            return "Password must be at least 6 characters"
        }
        
        return nil
    }
}
