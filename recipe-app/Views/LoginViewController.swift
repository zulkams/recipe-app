//
//  LoginViewController.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import UIKit

class LoginViewController: UIViewController {
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 18
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let usernameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.masksToBounds = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.masksToBounds = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(nil, action: #selector(loginTapped), for: .touchUpInside)
        return btn
    }()
    
    private let statusLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .systemRed
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        title = "Login"
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(usernameField)
        cardView.addSubview(passwordField)
        cardView.addSubview(loginButton)
        cardView.addSubview(statusLabel)
        
        cardView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().inset(24)
            make.height.greaterThanOrEqualTo(340)
        }
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        usernameField.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(usernameField.snp.bottom).offset(16)
            make.left.right.height.equalTo(usernameField)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(24)
            make.left.right.equalTo(usernameField)
            make.height.equalTo(48)
        }
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.left.right.equalTo(usernameField)
            make.bottom.lessThanOrEqualToSuperview().inset(20)
        }
    }
    
    @objc private func loginTapped() {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            statusLabel.text = "Please enter username and password."
            return
        }
        statusLabel.text = "Logging in..."
        AuthAPI.shared.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.statusLabel.text = "Login successful!"
                    self?.dismiss(animated: true)
                case .failure(let error):
                    self?.statusLabel.text = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    @objc private func logoutTapped() {
        statusLabel.text = "Logging out..."
        AuthAPI.shared.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.statusLabel.text = "Logged out."
                    // Show login screen again
                    let loginVC = LoginViewController()
                    loginVC.modalPresentationStyle = .fullScreen
                    self?.present(loginVC, animated: true)
                case .failure(let error):
                    self?.statusLabel.text = "Logout failed: \(error.localizedDescription)"
                }
            }
        }
    }
    

}
