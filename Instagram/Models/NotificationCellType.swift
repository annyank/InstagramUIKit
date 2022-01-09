//
//  NotificationCellType.swift
//  Instagram
//
//  Created by Ann Yank on 6.01.22.
//

import Foundation

enum NotificationCellType {
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
}
