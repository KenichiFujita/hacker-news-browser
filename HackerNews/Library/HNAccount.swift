//
//  Account.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 10/12/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import Foundation

public struct HNAccount {
    static var loginUrl: URL {
        guard let url = URL(string: "https://news.ycombinator.com/login") else {
            fatalError("Invalid login URL")
        }
        return url
    }
    
    static var isLoggedIn: Bool {
        guard
            let url = URL(string: "https://news.ycombinator.com/login"),
            let cookies = HTTPCookieStorage.shared.cookies(for: url)
        else { return false }
        for cookie in cookies {
            if cookie.name == "user" {
                return true
            }
        }
        return false
    }
}
