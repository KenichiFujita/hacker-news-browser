//
//  AccountViewModel.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 9/25/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import Foundation

protocol AccountViewModelType {
    var inputs: AccountViewModelInputs { get }
    var outputs: AccountViewModelOutputs { get }
}

protocol AccountViewModelInputs {
    func viewDidLoad()
    func didTapSignOutButton()
}

protocol AccountViewModelOutputs: AnyObject {
    var loggedOut: () -> Void { get set }
    var logoutFailed: () -> Void { get set }
}

final class AccountViewModel: AccountViewModelType, AccountViewModelInputs, AccountViewModelOutputs {
    var inputs: AccountViewModelInputs { self }
    var outputs: AccountViewModelOutputs { self }
    var loggedOut: () -> Void = {}
    var logoutFailed: () -> Void = {}
    private let favoritesStore: FavoritesStore
    private let api: APIClient

    init(api: APIClient, favoritesStore: FavoritesStore) {
        self.api = api
        self.favoritesStore = favoritesStore
    }

    func viewDidLoad() {}

    func didTapSignOutButton() {
        guard
            let url = URL(string: "https://news.ycombinator.com/login"),
            let cookies = HTTPCookieStorage.shared.cookies(for: url)
        else { return }
        for cookie in cookies {
            if cookie.name == "user" {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        if Account.isLoggedIn {
            logoutFailed()
        } else {
            loggedOut()
        }
    }
}
