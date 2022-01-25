//
//  SettingsModels.swift
//  Instagram
//
//  Created by Ann Yank on 25.01.22.
//

import Foundation
import UIKit

struct SettingsSection {
    let title: String
    let options: [SettingOption]
}

struct SettingOption {
    let title: String
    let image: UIImage?
    let color: UIColor
    let handler: (() -> Void)
}
