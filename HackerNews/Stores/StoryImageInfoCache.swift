//
//  StoryImageCache.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 3/18/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import Foundation
import UIKit

protocol ImageInfoCacheProtocol {
    var imageInfos: [String: StoryImageInfo] { get }
    func addStoryImageInfo(storyHost: String, storyImageInfo: StoryImageInfo)
}

class StoryImageInfoCache: ImageInfoCacheProtocol {

    private var storyImageInfos: [String: StoryImageInfo] = [:]
    static var key: String {
        return "imageIcon"
    }
    private let userDefaults: UserDefaults
    private let notificationCenter = NotificationCenter.default
    var imageInfos: [String: StoryImageInfo] {
        return storyImageInfos
    }
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        if let cached = userDefaults.data(forKey: StoryImageInfoCache.key),
            let decoded = try? JSONDecoder().decode([String: StoryImageInfo].self, from: cached) {
                self.storyImageInfos = decoded
        }
        self.notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func addStoryImageInfo(storyHost: String, storyImageInfo: StoryImageInfo) {
        storyImageInfos[storyHost] = storyImageInfo
    }
    
    @objc func didEnterBackground() {
        save()
    }
    
    private func save() {
        let converted = try? JSONEncoder().encode(storyImageInfos)
        userDefaults.set(converted, forKey: StoryImageInfoCache.key)
    }
    
}
