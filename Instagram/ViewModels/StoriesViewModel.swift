//
//  StoriesViewModel.swift
//  Instagram
//
//  Created by Ann Yank on 27.01.22.
//

import Foundation
import UIKit

struct StoriesViewModel {
    let stories: [Story]
}

struct Story {
    let username: String
    let image: UIImage?
}
