//
//  Post.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/17/26.
//
//
//  Post.swift
//  BeReal-Clone
//
//  Model representing a post in the BeReal clone
//

import Foundation
import Parse

class Post {
    
    // MARK: - Properties

    var objectId: String?
    var user: PFUser?
    var image: PFFileObject?
    var caption: String?
    var location: PFGeoPoint?
    var createdAt: Date?
    var pfObject: PFObject?

    // MARK: - Initializers

    init(pfObject: PFObject) {
        self.pfObject = pfObject
        self.objectId = pfObject.objectId
        self.user = pfObject[Constants.PostKeys.user] as? PFUser
        self.image = pfObject[Constants.PostKeys.image] as? PFFileObject
        self.caption = pfObject[Constants.PostKeys.caption] as? String
        self.location = pfObject[Constants.PostKeys.location] as? PFGeoPoint
        self.createdAt = pfObject.createdAt
    }
    
    // MARK: - Static Methods
    
    /// Create a new post and save it to Parse
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - caption: Optional caption text
    ///   - location: Optional location data
    ///   - completion: Callback with success status and optional error
    static func createPost(image: UIImage,
                          caption: String?,
                          location: PFGeoPoint?,
                          completion: @escaping (Bool, Error?) -> Void) {
        
        // Compress and convert image to data
        guard let imageData = image.jpegData(compressionQuality: Constants.ImageSettings.compressionQuality) else {
            completion(false, NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"]))
            return
        }
        
        // Create Parse file object
        let file = PFFileObject(name: "post_\(UUID().uuidString).jpg", data: imageData)
        
        // Create post object
        let post = PFObject(className: Constants.ParseClass.post)
        post[Constants.PostKeys.user] = PFUser.current()
        post[Constants.PostKeys.image] = file
        post[Constants.PostKeys.caption] = caption
        
        if let location = location {
            post[Constants.PostKeys.location] = location
        }
        
        // Save to Parse
        post.saveInBackground { success, error in
            if success {
                print("✅ Post created successfully")
                NotificationCenter.default.post(name: NSNotification.Name("PostCreated"), object: nil)
            } else {
                print("❌ Failed to create post: \(error?.localizedDescription ?? "Unknown error")")
            }
            completion(success, error)
        }
    }
    
    /// Fetch recent posts from Parse
    /// - Parameters:
    ///   - limit: Number of posts to fetch
    ///   - skip: Number of posts to skip (for pagination)
    ///   - completion: Callback with array of posts or error
    static func fetchPosts(limit: Int = Constants.Pagination.pageSize,
                          skip: Int = 0,
                          completion: @escaping ([Post]?, Error?) -> Void) {
        
        let query = PFQuery(className: Constants.ParseClass.post)
        query.includeKey(Constants.PostKeys.user)
        query.order(byDescending: Constants.PostKeys.createdAt)
        query.limit = limit
        query.skip = skip
        query.whereKey("createdAt", greaterThanOrEqualTo: Date(timeIntervalSinceNow: -86400))
        
        query.findObjectsInBackground { objects, error in
            if let error = error {
                print("❌ Failed to fetch posts: \(error.localizedDescription)")
                completion(nil, error)
            } else if let objects = objects {
                let posts = objects.map { Post(pfObject: $0) }
                print("✅ Fetched \(posts.count) posts")
                completion(posts, nil)
            }
        }
    }
    
    /// Check whether the current user has already posted in the last 24 hours
    static func hasPostedToday(completion: @escaping (Bool) -> Void) {
        guard let currentUser = PFUser.current() else {
            completion(false)
            return
        }
        let query = PFQuery(className: Constants.ParseClass.post)
        query.whereKey(Constants.PostKeys.user, equalTo: currentUser)
        query.whereKey("createdAt", greaterThanOrEqualTo: Date(timeIntervalSinceNow: -86400))
        query.limit = 1
        query.countObjectsInBackground { count, error in
            completion(count > 0 && error == nil)
        }
    }

    // MARK: - Helper Methods

    /// Get username of post author
    var username: String {
        return user?.username ?? "Unknown User"
    }
    
    /// Get formatted time since post creation
    var timeAgo: String {
        guard let createdAt = createdAt else { return "" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    /// Load image data asynchronously
    /// - Parameter completion: Callback with UIImage or nil
    func loadImage(completion: @escaping (UIImage?) -> Void) {
        guard let imageFile = image else {
            completion(nil)
            return
        }
        
        imageFile.getDataInBackground { data, error in
            if let error = error {
                print("❌ Failed to load image: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
}
