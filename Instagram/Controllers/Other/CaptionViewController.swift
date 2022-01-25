//
//  CaptionViewController.swift
//  Instagram
//
//  Created by Ann Yank on 15.12.21.
//

import UIKit

class CaptionViewController: UIViewController, UITextViewDelegate {

    private let image: UIImage
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Add caption..."
        textView.backgroundColor = .secondarySystemBackground
        textView.font = .systemFont(ofSize: 22)
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        return textView
    }()
    
    // MARK: - Init

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        imageView.image = image
        view.addSubview(textView)
        textView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(didTapPost)
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = view.width/4
        imageView.frame = CGRect(
            x: (view.width-size)/2,
            y: view.safeAreaInsets.top + 10,
            width: size,
            height: size
        )
        textView.frame = CGRect(
            x: 20,
            y: imageView.bottom + 20,
            width: view.width-40,
            height: 100
        )
    }
    
    @objc func didTapPost() {
        textView.resignFirstResponder()
        var caption = textView.text ?? ""
        if caption == "Add caption..." {
            caption = ""
        }
        
        // Generate post ID
        guard let newPostID = createNewPostID(), let stringDate = String.date(from: Date()) else {
            return
        }

        // Upload Post
        StorageManager.shared.uploadPost(
            data: image.pngData(),
            id: newPostID
        ) { newPostDownloadURL in
            guard let url = newPostDownloadURL else {
                print("error: failed to upload")
                return
            }
            
            // New Post
            let newPost = Post(
                id: newPostID,
                caption: caption,
                postedDate: stringDate,
                postUrlString: url.absoluteString,
                likers: []
            )
            
            // Update Database
            DatabaseManager.shared.createPost(newPost: newPost) { [weak self] finished in
                guard finished else {
                    return
                }
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0
                    self?.navigationController?.popToRootViewController(animated: false)
                    
                    NotificationCenter.default.post(name: .didPostNotification,
                                                    object: nil)
                }
            }
        }

        // Update Database
    }
    
    private func createNewPostID() -> String? {
        let timestamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return nil
        }
        return "\(username)_\(randomNumber)_\(timestamp)"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add caption..." {
            textView.text = nil
        }
    }

}
