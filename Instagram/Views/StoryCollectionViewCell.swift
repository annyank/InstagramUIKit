//
//  StoryCollectionViewCell.swift
//  Instagram
//
//  Created by Ann Yank on 27.01.22.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "StoryCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: contentView.height-label.height, width: contentView.width, height: label.height)
        
        let imageSize: CGFloat = contentView.height-label.height-7
        imageView.layer.cornerRadius = imageSize/2
        imageView.frame = CGRect(x: (contentView.width-imageSize)/2, y: 2, width: imageSize, height: imageSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = nil
    }
    
    func configure(with story: Story) {
        label.text = story.username
        imageView.image = story.image
    }
}
