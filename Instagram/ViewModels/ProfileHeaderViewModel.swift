//
//  ProfileHeaderViewModel.swift
//  Instagram
//
//  Created by Ann Yank on 11.01.22.
//

import Foundation

enum ProfileButtonType {
    case edit
    case follow(isFollowing: Bool)
}

struct ProfileHeaderViewModel {
    let profilePictureUrl: URL?
    let followerCount: Int
    let followingCount: Int
    let postCount: Int
    let buttonType: ProfileButtonType
    let name: String?
    let bio: String?
}
