//
//  SettingsViewController.swift
//  Instagram
//
//  Created by Ann Yank on 15.12.21.
//

import SafariServices
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var sections: [SettingsSection] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.addSubview(tableView)
        configureModels()
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(didTapClose))
        createTableFooter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureModels() {
        sections.append(SettingsSection(title: "App", options: [
            SettingOption(
                title: "Rate App",
                image: UIImage(systemName: "star"),
                color: .systemOrange
            ) {
                guard let url = URL(string: "https://apps.apple.com/ru/app/instagram/id389801252") else {
                    return
                }
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            },
            SettingOption(
                title: "Share App",
                image: UIImage(systemName: "square.and.arrow.up"),
                color: .systemBlue
            ) { [weak self] in
                guard let url = URL(string: "https://apps.apple.com/ru/app/instagram/id389801252") else {
                    return
                }
                DispatchQueue.main.async {
                    let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
                    self?.present(vc, animated: true)
                }
            }
        ]))
        
        sections.append(SettingsSection(title: "Information", options: [
            SettingOption(
                title: "Terms of Service",
                image: UIImage(systemName: "doc"),
                color: .systemPink
            ) { [weak self] in
                DispatchQueue.main.async {
//                    guard let url = URL(string: "help.instagram.com/581066165581870/?helpref=uf_share") else {
//                        return
//                    }
                    
//                    guard let url = URL(string: "https://www.instagram.com/about/legal/terms/before-january-19-2013/") else {
//                        return
//                    }
                    
                    guard let url = URL(string: "https://help.instagram.com/581066165581870") else {
                        return
                    }
                    let vc = SFSafariViewController(url: url)
                    self?.present(vc, animated: true)
                }
            },
            SettingOption(
                title: "Privacy Policy",
                image: UIImage(systemName: "hand.raised"),
                color: .systemGreen
            ) { [weak self] in
                guard let url = URL(string: "https://help.instagram.com/519522125107875/?maybe_redirect_pol=0") else {
                    return
                }
                let vc = SFSafariViewController(url: url)
                self?.present(vc, animated: true)
            },
            SettingOption(
                title: "Get Help",
                image: UIImage(systemName: "message"),
                color: .systemPurple
            ) { [weak self] in
                guard let url = URL(string: "https://help.instagram.com/") else {
                    return
                }
                let vc = SFSafariViewController(url: url)
                self?.present(vc, animated: true)
            }
        ]))
    }
    
    // Table
    
    private func createTableFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height))
        footer.clipsToBounds = true
        
        let button = UIButton(frame: footer.bounds)
        footer.addSubview(button)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        
        tableView.tableFooterView = footer
    }
    
    @objc func didTapSignOut() {
        let actionSheet = UIAlertController(title: "Sign Out",
                                            message: "Are you sure?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            AuthManager.shared.signOut { success in
                if success {
                    DispatchQueue.main.async {
                        let vc = SignInViewController()
                        let navVC = UINavigationController(rootViewController: vc)
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
        present(actionSheet, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        cell.imageView?.tintColor = model.color
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
