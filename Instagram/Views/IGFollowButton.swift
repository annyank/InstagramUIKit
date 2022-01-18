//
//  IGFollowButton.swift
//  Instagram
//
//  Created by Ann Yank on 18.01.22.
//

import UIKit

final class IGFollowButton: UIButton {
    
    enum State: String {
        case follow = "Follow"
        case unfollow = "Unfollow"
        
        var titleColor: UIColor {
            switch self {
            case .follow:
                return .white
            case .unfollow:
                return .label
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .follow:
                return .systemBlue
            case .unfollow:
                return .tertiarySystemBackground
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(for state: State) {
        setTitle(state.rawValue, for: .normal)
        backgroundColor = state.backgroundColor
        setTitleColor(state.titleColor, for: .normal)
        
        switch state {
        case .follow:
            layer.borderWidth = 0
        case .unfollow:
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.secondaryLabel.cgColor
        }
    }
}

