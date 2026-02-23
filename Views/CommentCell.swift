//
//  CommentCell.swift
//  BeReal-Clone
//
//  Custom table view cell for displaying a comment
//

import UIKit

class CommentCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    // MARK: - Properties

    static let identifier = Constants.CellID.commentCell

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        commentTextLabel.text = nil
        timestampLabel.text = nil
    }

    // MARK: - Configuration

    func configure(with comment: Comment) {
        usernameLabel.text = comment.username
        commentTextLabel.text = comment.text
        timestampLabel.text = comment.timeAgo
    }
}
