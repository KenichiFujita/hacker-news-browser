//
//  StoryImageCache.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 3/18/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import Foundation
import UIKit

class StoryImageCache {

    private var storyImageInfos: [String: StoryImageInfo] = [:]
    static var key: String {
        return "touchIcon"
    }
    private let userDefaults: UserDefaults
    private let notificationCenter = NotificationCenter.default
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        if let cached = userDefaults.data(forKey: StoryImageCache.key),
            let decoded = try? JSONDecoder().decode([String: StoryImageInfo].self, from: cached) {
                self.storyImageInfos = decoded
        }
        self.notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func add(_ storyImageInfo: StoryImageInfo, forKey key: String) {
        storyImageInfos[key] = storyImageInfo
    }

    func storyImageInfo(forKey key: String) -> StoryImageInfo? {
        return storyImageInfos[key]
    }
    
    @objc func didEnterBackground() {
        save()
    }
    
    private func save() {
        let converted = try? JSONEncoder().encode(storyImageInfos)
        userDefaults.set(converted, forKey: StoryImageCache.key)
    }
    
}
