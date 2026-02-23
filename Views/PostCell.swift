//
//  PostCell.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/17/26.
//

//
//  PostCell.swift
//  BeReal-Clone
//
//  Custom table view cell for displaying posts
//

import UIKit

class PostCell: UITableViewCell {
    
    // MARK: - IBOutlets

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var commentsButton: UIButton!

    // MARK: - Properties

    static let identifier = Constants.CellID.postCell
    var onCommentsTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        commentsButton.addTarget(self, action: #selector(commentsTapped), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        usernameLabel.text = nil
        captionLabel.text = nil
        timestampLabel.text = nil
        locationLabel.text = nil
        locationLabel.isHidden = true
        blurView.isHidden = true
        onCommentsTapped = nil
    }

    @objc private func commentsTapped() {
        onCommentsTapped?()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Style post image view
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 12
        postImageView.backgroundColor = .systemGray6
        
        // Style username label
        usernameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        usernameLabel.textColor = .label
        
        // Style caption label
        captionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        captionLabel.textColor = .secondaryLabel
        captionLabel.numberOfLines = 0
        
        // Style timestamp label
        timestampLabel.font = .systemFont(ofSize: 12, weight: .regular)
        timestampLabel.textColor = .tertiaryLabel
        
        // Style location label
        locationLabel.font = .systemFont(ofSize: 12, weight: .regular)
        locationLabel.textColor = .tertiaryLabel
        locationLabel.isHidden = true
        
        // Cell styling
        selectionStyle = .none
    }
    
    // MARK: - Configuration

    func configure(with post: Post, isBlurred: Bool = false) {
        blurView.isHidden = !isBlurred
        // Set username
        usernameLabel.text = post.username
        
        // Set caption
        if let caption = post.caption, !caption.isEmpty {
            captionLabel.text = caption
            captionLabel.isHidden = false
        } else {
            captionLabel.isHidden = true
        }
        
        // Set timestamp
        timestampLabel.text = post.timeAgo
        
        // Set location if available
        if let location = post.location {
            locationLabel.text = "📍 \(formatLocation(location))"
            locationLabel.isHidden = false
        } else {
            locationLabel.isHidden = true
        }
        
        // Load image asynchronously
        loadPostImage(from: post)
    }
    
    // MARK: - Image Loading
    
    private func loadPostImage(from post: Post) {
        // Show placeholder
        postImageView.image = ImageHelper.shared.createPlaceholder(color: .systemGray5,
                                                                   size: postImageView.bounds.size)
        
        // Load actual image
        post.loadImage { [weak self] image in
            DispatchQueue.main.async {
                if let image = image {
                    self?.postImageView.image = image
                } else {
                    // Keep placeholder if loading fails
                    self?.postImageView.image = ImageHelper.shared.createPlaceholder(
                        color: .systemGray4,
                        size: self?.postImageView.bounds.size ?? CGSize(width: 100, height: 100)
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatLocation(_ location: PFGeoPoint) -> String {
        // In a real app, you would reverse geocode this to get a readable address
        // For now, just show coordinates
        return String(format: "%.2f, %.2f", location.latitude, location.longitude)
    }
}

// MARK: - PFGeoPoint Import

import Parse
