//
//  StoryImageURLCache.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 3/2/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import Foundation
import UIKit
import SwiftSoup

class StoryImageInfoStore {

    static let shared = StoryImageInfoStore()
    private let queue = DispatchQueue.global(qos: .default)
    private let session: URLSession
    private let storyImageInfoCache: ImageInfoCacheProtocol

    init(session: URLSession = URLSession(configuration: .default), storyImageInfoCache: ImageInfoCacheProtocol = StoryImageInfoCache()) {
        self.session = session
        self.storyImageInfoCache = storyImageInfoCache
    }

    func imageIconURL(for url: URL, completionHandler: @escaping (URL?) -> Void) {
        queue.async {
            guard let host = url.host else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            if let cachedStoryImageInfo = self.storyImageInfoCache.storyImageInfo(forKey: host) {
                DispatchQueue.main.async {
                    completionHandler(cachedStoryImageInfo.touchIcon)
                }
            } else {
                self.imageInfo(url: url) { (storyImageInfo) in
                    guard let storyImageInfo = storyImageInfo else {
                        DispatchQueue.main.async {
                            completionHandler(nil)
                        }
                        return
                    }
                    self.storyImageInfoCache.add(storyImageInfo, forKey: host)
                    DispatchQueue.main.async {
                        completionHandler(storyImageInfo.touchIcon)
                    }
                }
            }
        }
    }
    
    func ogImageURL(url: URL, completionHandler: @escaping (URL?) -> Void) {
        queue.async {
            self.imageInfo(url: url) { (storyImageInfo) in
                guard let storyImageInfo = storyImageInfo else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    completionHandler(storyImageInfo.ogImage)
                }
            }
        }
    }

    private func imageInfo(url: URL, completionHandler: @escaping (StoryImageInfo?) -> Void) {
        var storyImageInfo = StoryImageInfo(url: url)
        self.html(url: url) { (html) in
            guard let html = html else {
                completionHandler(nil)
                return
            }
            let document: Document? = try? SwiftSoup.parse(html, url.absoluteString)
            var elements: [Element] = []
            for node in [try? document?.select("head"), try? document?.select("body")].compactMap({ $0 }) {
                if let metaTags = try? node.select("meta").array() {
                    elements.append(contentsOf: metaTags)
                }
                if let linkTags = try? node.select("link").array() {
                    elements.append(contentsOf: linkTags)
                }
            }
            let images = self.images(elements: elements)
            for (key, (url, _)) in images {
                storyImageInfo.set(url, forKey: key)
            }
            completionHandler(storyImageInfo)
        }
    }

    private func html(url: URL, completionHandler: @escaping (String?) -> Void) {
        session.dataTask(with: url) { data, response, error in
            guard let data = data,
                let html = String(data:data, encoding: .utf8) else {
                    completionHandler(nil)
                    return
            }
            completionHandler(html)
        }.resume()
    }
    
    private func images(elements: [Element]) -> [String: (URL, Int)] {
        var images: [String: (URL, Int)] = [:]
        var currentSize: Int = -1
        for node in elements{
            if let img = node.image {
                if let _ = images[img.key], currentSize < img.size {
                    images[img.key] = (img.url, img.size)
                    currentSize = img.size
                }
                images[img.key] = (img.url, img.size)
                currentSize = img.size
            }
        }
        return images
    }

}


struct StoryImageInfo: Codable {
    var url: URL
    private var appleTouchIconPrecomposed: URL?
    private var appleTouchIcon: URL?
    private var fluidIcon: URL?
    private var icon: URL?
    private var shortcutIcon: URL?
    var ogImage: URL?

    fileprivate var touchIcon: URL? {
        return appleTouchIconPrecomposed ?? appleTouchIcon ?? fluidIcon ?? icon ?? shortcutIcon ?? nil
    }
    
    init(url: URL) {
        self.url = url
    }
    
    mutating func set(_ url: URL, forKey: String) {
        switch forKey {
        case "apple-touch-icon-precomposed":
            appleTouchIconPrecomposed = url
        case "apple-touch-icon":
            appleTouchIcon = url
        case "fluid-icon":
            fluidIcon = url
        case "icon":
            icon = url
        case "shortcut icon":
            shortcutIcon = url
        case "og:image":
            ogImage = url
        default:
            return
        }
    }


}


private extension Element {
    var image: (key: String, url: URL, size: Int)? {
        if let key = try? attr("property"), let content = try? absUrl("content"), let url = URL(string: content) {
            return (key: key, url: url, size: 0)
        } else {
            guard let key = try? attr("rel"), let href = try? absUrl("href"), let url = URL(string: href) else {
                return nil
            }
            var size: Int {
                guard let iconSize = try? attr("sizes") else {
                    return 0
                }
                let separateIndex = iconSize.firstIndex(of: "x") ?? iconSize.startIndex
                return Int(String(iconSize[..<separateIndex])) ?? 0
            }
            return (key: key, url: url, size: size)
        }
    }
}
