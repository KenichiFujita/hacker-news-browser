//
//  LoginViewModel.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 9/20/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import Foundation

enum LoginError: Error {
    case failed
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

protocol LoginViewModelInputs {
    func viewDidLoad()
    func textFieldDidChange(userIDText: String, passwordText: String)
    func didTapLoginButton(userName: String, password: String)
}

protocol LoginViewModelOutputs: AnyObject {
    var loggedIn: () -> Void { get set }
    var fieldEmpty: () -> Void { get set }
    var fieldFilled: () -> Void { get set }
    var invalidUsernameSent: (String) -> Void { get set }
    var didReceiveError: (Error) -> Void { get set }
    var favoritesStore: FavoritesStore { get }
    var api: APIClient { get }
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {
    var inputs: LoginViewModelInputs { self }
    var outputs: LoginViewModelOutputs { self }
    let favoritesStore: FavoritesStore
    let api: APIClient

    init(api: APIClient, favoritesStore: FavoritesStore) {
        self.favoritesStore = favoritesStore
        self.api = api
    }

    func viewDidLoad() {
        if HNAccount.isLoggedIn {
            loggedIn()
        }
    }

    var fieldEmpty: () -> Void = {}
    var fieldFilled: () -> Void = {}
    func textFieldDidChange(userIDText: String, passwordText: String) {
        if userIDText.isEmpty || passwordText.isEmpty {
            fieldEmpty()
        } else {
            fieldFilled()
        }
    }

    var loggedIn: () -> Void = {}
    var invalidUsernameSent: (String) -> Void = { _ in }
    var didReceiveError: (Error) -> Void = { _ in }
    func didTapLoginButton(userName: String, password: String) {
        if let usernameTextErrorMessage = usernameTextErrorMessage(for: userName) {
            invalidUsernameSent(usernameTextErrorMessage)
            return
        }
        api.logIn(userName: userName, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if HNAccount.isLoggedIn {
                        #warning("stories not handled")
                        // TODO: Add favorite stories to FavoritesStore
                        self?.loggedIn()
                    } else {
                        self?.didReceiveError(LoginError.failed)
                    }
                case .failure(let error):
                    self?.didReceiveError(error)
                }
            }
        }
    }

    private func usernameTextErrorMessage(for userName: String) -> String? {
        var usernameTextErrorMessage: String?
        if userName.count < 2 || userName.count > 15 {
            usernameTextErrorMessage = InvalidUsernameDescription.invalidLength
        }
        if !isValidCharactersForUsername(username: userName) {
            if usernameTextErrorMessage == nil {
                usernameTextErrorMessage = InvalidUsernameDescription.containsInvalidCharacter
            } else {
                usernameTextErrorMessage?.append(contentsOf: "\n\(InvalidUsernameDescription.containsInvalidCharacter)")
            }
        }
        return usernameTextErrorMessage
    }

    private func isValidCharactersForUsername(username: String) -> Bool {
        let validCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_")
        return username.rangeOfCharacter(from: validCharacters.inverted) == nil ? true : false
    }

    private struct InvalidUsernameDescription {
        static let invalidLength = "Username must be 2-15 characters long"
        static let containsInvalidCharacter = "Please use only letters, digits, dashes and underscore"
    }

}
