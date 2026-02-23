//
//  Constants.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/17/26.
//

//
//  Constants.swift
//  BeReal-Clone
//
//  Centralized constants for the entire application
//

import Foundation

struct Constants {
    
    // MARK: - Parse Configuration
    struct Parse {
        static let applicationId = "yUN3oVJCdwGcgjZRGIKPaw5WzxMZY6XDD7O17nju"
        static let clientKey = "q52OI9CVFQGjUx1jNHxhsYF87GdBg46TPuryCwI7"
        static let serverURL = "https://parseapi.back4app.com"
    }
    
    // MARK: - Parse Class Names
    struct ParseClass {
        static let post = "Post"
        static let user = "_User"
        static let comment = "Comment"
    }
    
    // MARK: - Comment Keys
    struct CommentKeys {
        static let text = "text"
        static let user = "user"
        static let post = "post"
        static let createdAt = "createdAt"
    }

    // MARK: - Parse Keys
    struct PostKeys {
        static let image = "image"
        static let caption = "caption"
        static let user = "user"
        static let location = "location"
        static let createdAt = "createdAt"
    }
    
    // MARK: - Storyboard IDs
    struct StoryboardID {
        static let loginViewController = "LoginViewController"
        static let signUpViewController = "SignUpViewController"
        static let feedViewController = "FeedViewController"
        static let createPostViewController = "CreatePostViewController"
        static let commentsViewController = "CommentsViewController"
    }
    
    // MARK: - Cell Identifiers
    struct CellID {
        static let postCell = "PostCell"
        static let commentCell = "CommentCell"
    }

    // MARK: - Push Notifications
    struct Notifications {
        static let identifier = "BeRealDailyReminder"
        static let title = "Time to BeReal!"
        static let body = "Share your moment before it's too late!"
        static let interval: TimeInterval = 86400
    }
    
    // MARK: - Segue Identifiers
    struct Segue {
        static let loginToFeed = "LoginToFeedSegue"
        static let signUpToFeed = "SignUpToFeedSegue"
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let emptyFields = "Please fill in all fields"
        static let invalidImage = "Please select an image"
        static let networkError = "Network error. Please try again."
        static let uploadFailed = "Failed to upload post. Please try again."
        static let fetchFailed = "Failed to load posts. Please try again."
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static let postCreated = "Post created successfully!"
        static let loginSuccess = "Welcome back!"
        static let signUpSuccess = "Account created successfully!"
    }
    
    // MARK: - Image Compression
    struct ImageSettings {
        static let compressionQuality: CGFloat = 0.7
        static let maxImageSize: CGFloat = 1000
    }
    
    // MARK: - Pagination
    struct Pagination {
        static let pageSize = 10
        static let scrollThreshold: CGFloat = 100
    }
}
