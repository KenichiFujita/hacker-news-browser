//
//  LoginViewController.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 9/20/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    private let viewModel: LoginViewModelType

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapView)
        )
        return tapGestureRecognizer
    }()

    private let userIDTextField: LoginTextField = {
        let textField = LoginTextField(leftImage: UIImage(systemName: "person"))
        textField.placeholder = "Username"
        return textField
    }()

    private let passwordTextField: LoginTextField = {
        let textField = LoginTextField(leftImage: UIImage(systemName: "lock"))
        textField.placeholder = "Password"
        return textField
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemTeal
        button.setTitle("LOGIN", for: .normal)
        button.addTarget(
            self,
            action: #selector(didTapLoginButton),
            for: .touchUpInside
        )
        return button
    }()

    init(api: APIClient, favoritesStore: FavoritesStore) {
        self.viewModel = LoginViewModel(api: api, favoritesStore: favoritesStore)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        view.addSubview(userIDTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            userIDTextField.heightAnchor.constraint(equalToConstant: 40),
            userIDTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -40),
            userIDTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            userIDTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 32),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            loginButton.widthAnchor.constraint(equalToConstant: view.bounds.width / 3),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addGestureRecognizer(tapGestureRecognizer)
        userIDTextField.delegate = self
        passwordTextField.delegate = self

        bind()
        viewModel.inputs.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func bind() {

        viewModel.outputs.loggedIn = { [weak self] in
            guard let strongSelf = self else { return }
            self?.userIDTextField.text = nil
            self?.passwordTextField.text = nil
            let accountViewController = AccountViewController(
                api: strongSelf.viewModel.outputs.api,
                favoritesStore: strongSelf.viewModel.outputs.favoritesStore
            )
            self?.navigationController?.pushViewController(accountViewController, animated: true)
        }

        viewModel.outputs.didReceiveError = { _ in
            #warning("Error not handled")
        }

    }

    @objc private func didTapView() {
        view.endEditing(true)
    }

    @objc private func didTapLoginButton() {
        view.endEditing(true)
        guard
            let userName = userIDTextField.text,
            let password = passwordTextField.text
        else { return }
        viewModel.inputs.didTapLoginButton(userName: userName, password: password)
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

final private class LoginTextField: UITextField {

    fileprivate init(leftImage: UIImage?) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        keyboardType = .asciiCapable
        autocapitalizationType = .none
        returnKeyType = .done
        autocorrectionType = .no
        let configuration = UIImage.SymbolConfiguration(weight: .thin)
        let imageView = UIImageView(image: leftImage?.withConfiguration(configuration))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        leftView = imageView
        leftViewMode = .always
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        addBottomBorder()
    }

    private func addBottomBorder() {
        let borderWidth: CGFloat = 1.0
        let padding: CGFloat = 8.0
        let border = CALayer()
        border.borderColor = UIColor.systemOrange.cgColor
        border.borderWidth = borderWidth
        border.frame = CGRect(
            x: padding,
            y: bounds.height - borderWidth,
            width: bounds.width - (padding * 2),
            height: borderWidth
        )
        layer.addSublayer(border)
    }

    private var leftViewWidth: CGFloat {
        return bounds.height
    }

    private var padding: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: leftViewWidth + 8, bottom: 0, right: 8)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: leftViewWidth, height: bounds.height)
            .inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
    }

    override fileprivate func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override fileprivate func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override fileprivate func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

}
