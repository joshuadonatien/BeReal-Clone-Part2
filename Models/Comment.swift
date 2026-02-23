//
//  Comment.swift
//  BeReal-Clone
//
//  Model representing a comment on a post
//

import Foundation
import Parse

class Comment {

    // MARK: - Properties

    var objectId: String?
    var text: String?
    var user: PFUser?
    var post: PFObject?
    var createdAt: Date?

    // MARK: - Initializer

    init(pfObject: PFObject) {
        self.objectId = pfObject.objectId
        self.text = pfObject[Constants.CommentKeys.text] as? String
        self.user = pfObject[Constants.CommentKeys.user] as? PFUser
        self.post = pfObject[Constants.CommentKeys.post] as? PFObject
        self.createdAt = pfObject.createdAt
    }

    // MARK: - Helpers

    var username: String {
        return user?.username ?? "Unknown"
    }

    var timeAgo: String {
        guard let createdAt = createdAt else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
