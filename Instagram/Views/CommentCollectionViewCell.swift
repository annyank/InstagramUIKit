//
//  CommentCollectionViewCell.swift
//  Instagram
//
//  Created by Ann Yank on 25.01.22.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
    static let identifier = "CommentCollectionViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(label)
//        // Add constraints
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: contentView.topAnchor),
//            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 5, y: 0, width: contentView.width-10, height: contentView.height)
    }
    
    func configure(with model: Comment) {
        label.text = "\(model.username): \(model.comment)"
    }
}
