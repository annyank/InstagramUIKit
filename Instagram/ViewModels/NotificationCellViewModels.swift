//
//  NotificationCellViewModels.swift
//  Instagram
//
//  Created by Ann Yank on 6.01.22.
//

import Foundation

struct LikeNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let postUrl: URL
}
struct FollowNotificationCellViewModel {
    let username: String
    let profilePictureUrl: URL
    let isCurrentUserFollowing: Bool
}
struct CommentNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let postUrl: URL
}
