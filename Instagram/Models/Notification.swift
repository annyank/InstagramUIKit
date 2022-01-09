//
//  Notification.swift
//  Instagram
//
//  Created by Ann Yank on 15.12.21.
//

import Foundation

struct IGNotification: Codable {
    let notififcationType: Int // 1: like, 2: comment, 3: follow
    let profilePictureUrl: String
    let username: String
    // Follow / Unfollow
    let isFollowing: Bool?
    // Like / Comment
    let postId: String?
    let postUrl: String?
}
