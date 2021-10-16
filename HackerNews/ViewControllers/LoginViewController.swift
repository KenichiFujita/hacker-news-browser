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

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome Back!"
        label.font = UIFont.preferredFont(forTextStyle: .title1).bold()
        label.textAlignment = .center
        return label
    }()

    private let descriptionTextView: UITextView = {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label,
            .paragraphStyle: style,
        ]
        let linkText = "Hacker News"
        let attributedText = NSMutableAttributedString(
            string: "Enter username and password of\n your \(linkText) account.",
            attributes: attributes
        )
        let linkRange = (attributedText.string as NSString).range(of: linkText)
        attributedText.addAttributes([
            .link: "https://news.ycombinator.com/",
            .font : UIFont.preferredFont(forTextStyle: .body).bold()
        ], range: linkRange)

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.sizeToFit()
        textView.attributedText = attributedText
        textView.linkTextAttributes = [.foregroundColor: UIColor.systemOrange]
        return textView
    }()

    private let invalidUsernameErrorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: UIFont.preferredFont(forTextStyle: .caption2).lineHeight).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: UIFont.preferredFont(forTextStyle: .caption2).lineHeight).isActive = true
        return imageView
    }()

    private let invalidUsernameErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .systemOrange
        label.sizeToFit()
        return label
    }()

    private let invalidUsernameErrorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .top
        stackView.spacing = 4
        stackView.isHidden = true
        return stackView
    }()

    private let usernameTextField: LoginTextField = {
        let textField = LoginTextField(
            leftImage: UIImage(systemName: "person"),
            isSecureTextEntry: false,
            placeholder: "Username"
        )
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        return textField
    }()

    private let passwordTextField: LoginTextField = {
        let textField = LoginTextField(
            leftImage: UIImage(systemName: "lock"),
            isSecureTextEntry: true,
            placeholder: "Password"
        )
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        return textField
    }()

    private let forgotPasswordTextView: UITextView = {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.right
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .link: "https://news.ycombinator.com/forgot",
            .paragraphStyle: style,
        ]
        let attributedText = NSMutableAttributedString(
            string: "Forgot password?",
            attributes: attributes
        )

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.sizeToFit()
        textView.attributedText = attributedText
        textView.contentInset = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return textView
    }()

    private lazy var loginButton: LoginButton = {
        let button = LoginButton(backgroundColor: .systemOrange)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign in", for: .normal)
        button.addTarget(
            self,
            action: #selector(didTapLoginButton),
            for: .touchUpInside
        )
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        button.isEnabled = false
        return button
    }()

    private let signUpTextView: UITextView = {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UIColor.secondaryLabel,
            .paragraphStyle: style,
        ]
        let linkText = "Sign up"
        let attributedText = NSMutableAttributedString(
            string: "Need an account?   \(linkText)",
            attributes: attributes
        )
        let linkRange = (attributedText.string as NSString).range(of: linkText)
        attributedText.addAttributes([
            .link: "https://news.ycombinator.com/login",
            .font : UIFont.preferredFont(forTextStyle: .footnote)
        ], range: linkRange)

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.sizeToFit()
        textView.attributedText = attributedText
        return textView
    }()

    init(api: APIClient, favoritesStore: FavoritesStore) {
        self.viewModel = LoginViewModel(api: api, favoritesStore: favoritesStore)
        super.init(nibName: nil, bundle: nil)

        navigationItem.title = "Sign In"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        invalidUsernameErrorStackView.addArrangedSubview(invalidUsernameErrorImageView)
        invalidUsernameErrorStackView.addArrangedSubview(invalidUsernameErrorLabel)
        view.addSubview(welcomeLabel)
        view.addSubview(descriptionTextView)
        view.addSubview(invalidUsernameErrorStackView)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(forgotPasswordTextView)
        view.addSubview(loginButton)
        view.addSubview(signUpTextView)

        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            descriptionTextView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            invalidUsernameErrorStackView.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor, constant: 8),
            invalidUsernameErrorStackView.trailingAnchor.constraint(lessThanOrEqualTo: usernameTextField.trailingAnchor),
            invalidUsernameErrorStackView.bottomAnchor.constraint(equalTo: usernameTextField.topAnchor),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40),
            usernameTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -40),
            usernameTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            forgotPasswordTextView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor),
            forgotPasswordTextView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            forgotPasswordTextView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            loginButton.topAnchor.constraint(equalTo: forgotPasswordTextView.bottomAnchor, constant: 32),
            loginButton.widthAnchor.constraint(equalToConstant: view.bounds.width / 2),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            signUpTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addGestureRecognizer(tapGestureRecognizer)
        usernameTextField.delegate = self
        passwordTextField.delegate = self

        bind()
        viewModel.inputs.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        loginButton.layer.cornerRadius = loginButton.bounds.height / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        usernameTextField.text = nil
        passwordTextField.text = nil
        invalidUsernameErrorLabel.text = nil
        invalidUsernameErrorStackView.isHidden = true
    }

    private func bind() {

        viewModel.outputs.loggedIn = { [weak self] in
            guard let strongSelf = self else { return }
            self?.invalidUsernameErrorLabel.text = nil
            let accountViewController = AccountViewController(
                api: strongSelf.viewModel.outputs.api,
                favoritesStore: strongSelf.viewModel.outputs.favoritesStore
            )
            self?.navigationController?.pushViewController(accountViewController, animated: true)
        }

        viewModel.outputs.fieldEmpty = { [weak self] in
            self?.loginButton.isEnabled = false
        }

        viewModel.outputs.fieldFilled = { [weak self] in
            self?.loginButton.isEnabled = true
        }

        viewModel.outputs.invalidUsernameSent = { [weak self] errorMessage in
            guard let strongSelf = self else { return }
            self?.invalidUsernameErrorLabel.text = errorMessage
            self?.invalidUsernameErrorStackView.isHidden = false
            self?.shake(view: strongSelf.usernameTextField)
        }

        viewModel.outputs.didReceiveError = { [weak self] error in
            let alertViewController = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .alert
            )
            alertViewController.addAction(
                UIAlertAction(title: "OK",
                              style: .default,
                              handler: nil)
            )
            switch error {
            case is LoginError:
                alertViewController.title = "Sign in failed"
                alertViewController.message = "Your username or password may be incorrect."
            case is APIClientError:
                alertViewController.title = "Network error"
                alertViewController.message = "Please try again later."
            default:
                alertViewController.title = "Unknown error"
                alertViewController.message = "Please try again later."
            }
            self?.present(alertViewController, animated: true, completion: nil)
        }

    }

    @objc private func didTapView() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard
            let userIDText = usernameTextField.text,
            let passwordText = passwordTextField.text
        else { return }
        viewModel.inputs.textFieldDidChange(userIDText: userIDText, passwordText: passwordText)
    }

    @objc private func didTapLoginButton() {
        view.endEditing(true)
        guard
            let userName = usernameTextField.text,
            let password = passwordTextField.text
        else { return }
        viewModel.inputs.didTapLoginButton(userName: userName, password: password)
    }

    private func shake(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.01
        animation.repeatCount = 6
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 5, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 5, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

final private class LoginTextField: UITextField {
    fileprivate init(leftImage: UIImage?, isSecureTextEntry: Bool, placeholder: String) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        tintColor = .systemGray
        font = UIFont.preferredFont(forTextStyle: .body)
        self.placeholder = placeholder
        keyboardType = .asciiCapable
        autocapitalizationType = .none
        returnKeyType = .done
        autocorrectionType = .no
        leftView = imageView(with: leftImage)
        leftViewMode = .always
        if isSecureTextEntry {
            self.isSecureTextEntry = true
            rightView = secureTextEntryToggleButton()
            rightViewMode = .always
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSecureTextEntry: Bool {
        didSet {
            let image = isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash")
            (rightView as? UIButton)?.setImage(image, for: .normal)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        addBottomBorder()
    }

    private func imageView(with image: UIImage?) -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(weight: .thin)
        let imageView = UIImageView(image: image?.withConfiguration(configuration))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }

    private func secureTextEntryToggleButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        return button
    }

    @objc private func didTapButton() {
        isSecureTextEntry = !isSecureTextEntry
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

    private var iconViewWidth: CGFloat {
        return bounds.height
    }

    private var iconViewHeight: CGFloat {
        return bounds.height
    }

    private var padding: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: iconViewWidth + 8, bottom: 0, right: iconViewHeight + 8)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: iconViewWidth, height: iconViewHeight)
            .inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - iconViewWidth, y: 0, width: iconViewWidth, height: iconViewHeight)
            .inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
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

final private class LoginButton: UIButton {
    init(backgroundColor: UIColor) {
        defaultBackgroundColor = backgroundColor
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let defaultBackgroundColor: UIColor

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? defaultBackgroundColor : .systemGray4
        }
    }

    override var isHighlighted: Bool {
        didSet {
            let highlightedColor = defaultBackgroundColor.adjustAlpha(to: 60)
            backgroundColor = isHighlighted ? highlightedColor : defaultBackgroundColor
        }
    }
}
