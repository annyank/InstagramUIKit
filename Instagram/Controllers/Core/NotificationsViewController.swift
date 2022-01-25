//
//  NotificationsViewController.swift
//  Instagram
//
//  Created by Ann Yank on 15.12.21.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let noActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private var viewModels: [NotificationCellType] = []
    private var models: [IGNotification] = []
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.isHidden = true
        table.register(
            LikeNotificationTableViewCell.self,
            forCellReuseIdentifier: LikeNotificationTableViewCell.identifier
        )
        table.register(
            CommentNotificationTableViewCell.self,
            forCellReuseIdentifier: CommentNotificationTableViewCell.identifier
        )
        table.register(
            FollowNotificationTableViewCell.self,
            forCellReuseIdentifier: FollowNotificationTableViewCell.identifier
        )
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(noActivityLabel)
        fetchNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }
    
    private func fetchNotifications() {
        NotificationsManager.shared.getNotifications { [weak self] models in
            DispatchQueue.main.async {
                self?.models = models
                self?.createViewModels()
            }
        }
    }
    
    private func createViewModels() {
        models.forEach({ model in
            guard let type = NotificationsManager.IGType(rawValue: model.notififcationType) else {
                return
            }
            let username = model.username
            guard let profilePictureUrl = URL(string: model.profilePictureUrl) else {
                return
            }
            
            // Derive

            switch type {
            case .like:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                viewModels.append(
                    .like(
                        viewModel: LikeNotificationCellViewModel(
                            username: username,
                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .comment:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                viewModels.append(
                    .comment(
                        viewModel: CommentNotificationCellViewModel(
                            username: username,
                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .follow:
                guard let isFollowing = model.isFollowing else {
                    return
                }
                viewModels.append(
                    .follow(
                        viewModel: FollowNotificationCellViewModel(
                            username: username,
                            profilePictureUrl: profilePictureUrl,
                            isCurrentUserFollowing: isFollowing,
                            date: model.dateString
                        )
                    )
                )
            }
        })
        
        if viewModels.isEmpty {
            noActivityLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noActivityLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func mockData() {
        tableView.isHidden = false

        guard let postUrl = URL(string: "https://iosacademy.io/assets/images/courses/swiftui.png"),
              let iconUrl = URL(string: "https://iosacademy.io/assets/images/courses/swiftui.png") else {
            return
        }

        viewModels = [
            .like(
                viewModel: LikeNotificationCellViewModel(
                    username: "kyliejenner",
                    profilePictureUrl: iconUrl,
                    postUrl: postUrl,
                    date: String.date(from: Date()) ?? "Now"
                )
            ),
            .comment(
                viewModel: CommentNotificationCellViewModel(
                    username: "travisscott",
                    profilePictureUrl: iconUrl,
                    postUrl: postUrl,
                    date: String.date(from: Date()) ?? "Now"
                )
            ),
            .follow(
                viewModel: FollowNotificationCellViewModel(
                    username: "kimkardashian",
                    profilePictureUrl: iconUrl,
                    isCurrentUserFollowing: true,
                    date: String.date(from: Date()) ?? "Now"
                )
            )
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
        case .follow(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FollowNotificationTableViewCell.identifier,
                    for: indexPath
            ) as? FollowNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LikeNotificationTableViewCell.identifier,
                    for: indexPath
            ) as? LikeNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentNotificationTableViewCell.identifier,
                    for: indexPath
            ) as? CommentNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = viewModels[indexPath.row]
        let username: String
        switch cellType {
        case .follow(let viewModel):
            username = viewModel.username
        case .like(let viewModel):
            username = viewModel.username
        case .comment(let viewModel):
            username = viewModel.username
        }
        
        DatabaseManager.shared.findUser(username: username) { [weak self] user in
            guard let user = user else {
                // Show error alert 
                return
            }
            
            DispatchQueue.main.async {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - Actions

extension NotificationsViewController: LikeNotificationTableViewCellDelegate, CommentNotificationTableViewCellDelegate, FollowNotificationTableViewCellDelegate {
    func likeNotificationTableViewCell(_ cell: LikeNotificationTableViewCell, didTapPostWith viewModel: LikeNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .comment, .follow:
                return false
            case .like(let current):
                return current == viewModel
            }
        }) else {
            return
        }
        
        openPost(with: index, username: viewModel.username)
    }
    
    func commentNotificationTableViewCell(_ cell: CommentNotificationTableViewCell, didTapPostWith viewModel: CommentNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .like, .follow:
                return false
            case .comment(let current):
                return current == viewModel
            }
            
        }) else {
            return
        }
        
        openPost(with: index, username: viewModel.username)
    }
    
    func followNotificationTableViewCell(
        _ cell: FollowNotificationTableViewCell,
        didTapButton isFollowing: Bool,
        viewModel: FollowNotificationCellViewModel
    ) {
        let username = viewModel.username
        print("\n\n Request follow=\(isFollowing) for user=\(username)")
        DatabaseManager.shared.updateRelationship(
            state: isFollowing ? .follow : .unfollow,
            for: username
        ) { [weak self] success in
            if !success {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Woops",
                                                  message: "Unable to perform action",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    func openPost(with index: Int, username: String) {
        print(index)
        
        guard index < models.count else {
            return
        }
        
        let model = models[index]
        let username = username
        guard let postID = model.postId else {
            return
        }
        
        print(username)
        print(postID)
        
        // Find post by id from target user
        DatabaseManager.shared.getPost(
            with: postID,
            from: username) { [weak self] post in
                DispatchQueue.main.async {
                    guard let post = post else {
                        let alert = UIAlertController(title: "Oops",
                                                      message: "We are unable to open this post.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self?.present(alert, animated: true)
                        return
                    }
                    
                    let vc = PostViewController(post: post, owner: username)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
    }
}
