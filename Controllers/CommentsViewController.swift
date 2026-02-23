//
//  CommentsViewController.swift
//  BeReal-Clone
//
//  View controller for viewing and adding comments on a post
//

import UIKit
import Parse

class CommentsViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputContainerBottomConstraint: NSLayoutConstraint!

    // MARK: - Properties

    var post: Post?
    private var comments: [Comment] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comments"
        setupTableView()
        setupKeyboardObservers()
        fetchComments()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
        let nib = UINib(nibName: "CommentCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CommentCell.identifier)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Keyboard Handling

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let keyboardHeight = keyboardFrame.height
        inputContainerBottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        inputContainerBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Data

    private func fetchComments() {
        guard let pfObject = post?.pfObject else { return }

        ParseHelper.shared.fetchComments(for: pfObject) { [weak self] comments, error in
            DispatchQueue.main.async {
                if let comments = comments {
                    self?.comments = comments
                    self?.tableView.reloadData()
                } else if let error = error {
                    print("❌ Failed to fetch comments: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - IBActions

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = commentTextField.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty,
              let pfObject = post?.pfObject else { return }

        sendButton.isEnabled = false
        ParseHelper.shared.createComment(text: text, post: pfObject) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.sendButton.isEnabled = true
                if success {
                    self?.commentTextField.text = nil
                    self?.dismissKeyboard()
                    self?.fetchComments()
                } else {
                    print("❌ Failed to post comment: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension CommentsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        cell.configure(with: comments[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CommentsViewController: UITableViewDelegate {}
