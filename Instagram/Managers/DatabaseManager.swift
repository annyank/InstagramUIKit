//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Ann Yank on 15.12.21.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {
        
    }
    
    let database = Firestore.firestore()
    
    public func findUsers(
        with usernamePrefix: String,
        completion: @escaping ([User]) -> Void
    ) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion([])
                return
            }
            let subset = users.filter({
                $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
            })
            
            completion(subset)
        }
    }
    
    public func posts(
        for username: String,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("posts")
        ref.getDocuments { snapshot, error in
            guard let posts = snapshot?.documents.compactMap({
                Post(with: $0.data())
            }).sorted(by: {
                return $0.date > $1.date
            }),
            error == nil else {
                return
            }
            
            completion(.success(posts))
        }
    }
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion(nil)
                return
            }
            
            let user = users.first(where: { $0.email == email })
            completion(user)
        }
    }
    
    public func findUser(username: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion(nil)
                return
            }
            
            let user = users.first(where: { $0.username == username })
            completion(user)
        }
    }
    
    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let reference = database.document("users/\(username)/posts/\(newPost.id)")
        guard let data = newPost.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func explorePosts(completion: @escaping ([(post: Post, user: User)]) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion([])
                return
            }
            
            let group = DispatchGroup()
            var aggregatePosts = [(post: Post, user: User)]()
            
            users.forEach { user in
                group.enter()
                
                let username = user.username
                let postsRef = self.database.collection("users/\(username)/posts")
                
                postsRef.getDocuments { snapshot, error in
                    defer {
                        group.leave()
                    }
                    
                    guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data()) }),
                          error == nil else {
                        return
                    }
                    
                    aggregatePosts.append(contentsOf: posts.compactMap({
                        (post: $0, user: user)
                    }))
                }
            }
            
            group.notify(queue: .main) {
                completion(aggregatePosts)
            }
        }
    }
    
    public func getNotifications(
        completion: @escaping ([IGNotification]) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion([])
            return
        }
        let ref = database.collection("users").document(username).collection("notifications")
        ref.getDocuments { snapshot, error in
            guard let notifications = snapshot?.documents.compactMap({
                IGNotification(with: $0.data())
            }),
            error == nil else {
                completion([])
                return
            }
            
            completion(notifications)
        }
    }
    
    public func insertNotification(
        identifier: String,
        data: [String: Any],
        for username: String
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("notifications")
            .document(identifier)
        ref.setData(data)
    }
    
    public func getPost(
        with identifier: String,
        from username: String,
        completion: @escaping (Post?) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("posts")
            .document(identifier)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }
            
            completion(Post(with: data))
        }
    }
    
    enum RelationsgipState: String {
        case follow
        case unfollow
    }
    
    public func updateRelationship(
        state: RelationsgipState,
        for targetUsername: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        
        let currentFollowers = database.collection("users")
            .document(currentUsername)
            .collection("followers")
        let currentFollowing = database.collection("users")
            .document(currentUsername)
            .collection("following")
        
        let targetUserFollowers = database.collection("users")
            .document(targetUsername)
            .collection("followers")
        let targetUserFollowing = database.collection("users")
            .document(targetUsername)
            .collection("following")
        
        switch state {
        case .follow:
            // Add follower for requester following list
            currentFollowing.document(targetUsername).setData(["valid": "1"])
            // Add currentUser to targetUser followers list
            targetUserFollowers.document(currentUsername).setData(["valid": "1"])

            completion(true)
        case .unfollow:
            // Remove follower for requester following list
            currentFollowing.document(targetUsername).delete()
            // Remove currentUser from targetUser followers list
            targetUserFollowers.document(currentUsername).delete()

            completion(true)
        }
    }
    
    public func getUserCounts(
        username: String,
        completion: @escaping ((followers: Int, following: Int, posts: Int)) -> Void
    ) {
        let userRef = database.collection("users").document(username)
            
        var followers = 0
        var following = 0
        var posts = 0
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()

        userRef.collection("posts").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            posts = count
        }
        userRef.collection("followers").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            followers = count
        }
        userRef.collection("following").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            following = count
        }
        
        group.notify(queue: .global()) {
            let result = (
                followers: followers,
                following: following,
                posts: posts
            )
            completion(result)
        }
    }
    
    public func isFollowing(
        targetUsername: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let ref = database.collection("users")
            .document(targetUsername)
            .collection("followers")
            .document(currentUsername)
        ref.getDocument { snapshot, error in
            guard snapshot?.data() != nil, error == nil else {
                // Not following
                completion(false)
                return
            }
            // Following
            completion(true)
        }
        
    }
    
    public func followers(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users")
            .document(username)
            .collection("followers")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    /// Gets users that the username follows
    public func following(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users")
            .document(username)
            .collection("following")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    // MARK: - User Info
    
    public func getUserInfo(
        username: String,
        completion: @escaping (UserInfo?) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("information")
            .document("basic")
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let userInfo = UserInfo(with: data) else {
                completion(nil)
                return
            }
            completion(userInfo)
        }
    }
    
    public func setUserInfo(
        userInfo: UserInfo,
        completion: @escaping (Bool) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = userInfo.asDictionary() else {
            return
        }
        let ref = database.collection("users")
            .document(username)
            .collection("information")
            .document("basic")
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
}
