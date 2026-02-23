//
//  FeedViewController.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/17/26.
//

//
//  FeedViewController.swift
//  BeReal-Clone
//
//  View controller for displaying feed of posts
//

import UIKit
import Parse
import UserNotifications

class FeedViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties

    private var posts: [Post] = []
    private var isLoadingMore = false
    private var currentPage = 0
    private let refreshControl = UIRefreshControl()
    private var hasPostedToday = false
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupRefreshControl()
        setupNotifications()
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "BeReal"
        
        // Add logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        
        // Add create post button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .camera,
            target: self,
            action: #selector(createPostTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
        // Register cell
        let nib = UINib(nibName: "PostCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PostCell.identifier)
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNotifications() {
        // Listen for new posts
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewPost),
            name: NSNotification.Name("PostCreated"),
            object: nil
        )
    }
    
    // MARK: - Data Loading
    
    private func fetchPosts(page: Int = 0, completion: (() -> Void)? = nil) {
        guard !isLoadingMore else { return }

        isLoadingMore = true

        Post.hasPostedToday { [weak self] posted in
            self?.hasPostedToday = posted

            Post.fetchPosts(limit: Constants.Pagination.pageSize, skip: page * Constants.Pagination.pageSize) { posts, error in
                DispatchQueue.main.async {
                    self?.isLoadingMore = false

                    if let posts = posts {
                        if page == 0 {
                            self?.posts = posts
                        } else {
                            self?.posts.append(contentsOf: posts)
                        }
                        self?.tableView.reloadData()
                    } else if let error = error {
                        self?.showError(error.localizedDescription)
                    }

                    completion?()
                }
            }
        }
    }
    
    @objc private func refreshFeed() {
        currentPage = 0
        fetchPosts(page: 0) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc private func handleNewPost() {
        refreshFeed()
    }
    
    // MARK: - Actions
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Constants.Notifications.identifier])
        ParseHelper.shared.logOut { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.navigateToLogin()
                } else {
                    self?.showError(error?.localizedDescription ?? "Logout failed")
                }
            }
        }
    }
    
    @objc private func createPostTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let createPostVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardID.createPostViewController) as? CreatePostViewController {
            let navController = UINavigationController(rootViewController: createPostVC)
            present(navController, animated: true)
        }
    }
    
    // MARK: - Navigation

    private func navigateToComments(for post: Post) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let commentsVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardID.commentsViewController) as? CommentsViewController {
            commentsVC.post = post
            let navController = UINavigationController(rootViewController: commentsVC)
            present(navController, animated: true)
        }
    }

    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardID.loginViewController) as? LoginViewController {
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            
            view.window?.rootViewController = navController
            view.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - Helper Methods
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            // Show empty state
            showEmptyState()
            return 0
        } else {
            hideEmptyState()
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as? PostCell else {
            return UITableViewCell()
        }

        let post = posts[indexPath.row]
        let isOwnPost = post.user?.objectId == PFUser.current()?.objectId
        let isBlurred = !hasPostedToday && !isOwnPost
        cell.configure(with: post, isBlurred: isBlurred)
        cell.onCommentsTapped = { [weak self] in
            self?.navigateToComments(for: post)
        }

        return cell
    }
    
    private func showEmptyState() {
        let label = UILabel(frame: tableView.bounds)
        label.text = "No posts yet.\nCreate your first post!"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        tableView.backgroundView = label
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Infinite scroll / pagination
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // Check if user scrolled near bottom
        if offsetY > contentHeight - height - Constants.Pagination.scrollThreshold {
            // Load more posts if not already loading
            if !isLoadingMore && posts.count >= Constants.Pagination.pageSize * (currentPage + 1) {
                currentPage += 1
                fetchPosts(page: currentPage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Could implement detail view here
    }
}
