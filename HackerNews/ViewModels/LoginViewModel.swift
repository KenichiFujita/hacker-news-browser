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
    func didTapLoginButton(userName: String, password: String)
}

protocol LoginViewModelOutputs: AnyObject {
    var loggedIn: () -> Void { get set }
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
        if Account.isLoggedIn {
            loggedIn()
        }
    }

    var loggedIn: () -> Void = {}
    var didReceiveError: (Error) -> Void = { _ in }
    func didTapLoginButton(userName: String, password: String) {
        api.logIn(userName: userName, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if Account.isLoggedIn {
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

}
