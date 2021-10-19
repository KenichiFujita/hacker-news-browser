//
//  HNWebParser.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 9/6/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import SwiftSoup
import Foundation

private struct HNWebStory {
    var kids: [Int]?
    var text: String?
    var by: String?
    var descendants: Int?
    var id: Int?
    var score: Int?
    var date: Date = Date()
    var title: String?
    var url: String?
    var voteLink: String?
    var age: String?
}

final class HNWebParser {

    static func parseForStories(_ html: String) throws -> [Story] {
        var stories: [Story] = []
        do {
            guard let itemList = try SwiftSoup.parse(html).getElementsByClass("itemlist").first() else { return [] }
            let athings = try itemList.getElementsByClass("athing").array()
            let subtexts = try itemList.getElementsByClass("subtext").array()
            if athings.count == subtexts.count {
                for i in 0..<athings.count {
                    var hnWebStory = HNWebStory()
                    hnWebStory.id = Int(athings[i].id())
                    try athings[i].children().forEach { element in
                        if element.hasClass("title") {
                            try element.children().forEach { child in
                                if child.hasClass("titlelink") {
                                    hnWebStory.title = try child.select("a").text()
                                    hnWebStory.url = try child.select("a").attr("href")
                                }
                            }
                        } else if element.hasClass("votelinks") {
                            hnWebStory.voteLink = try element.select("a").attr("href")
                        }
                    }
                    try subtexts[i].children().forEach { subtext in
                        if subtext.hasClass("score") {
                            hnWebStory.score = (try subtext.text() as NSString).integerValue
                        } else if subtext.hasClass("age") {
                            hnWebStory.age = try subtext.text()
                            hnWebStory.date = DateFormatter.storyDate(from: try subtext.attr("title")) ?? Date()
                        } else if subtext.hasClass("hnuser") {
                            hnWebStory.by = try subtext.text()
                        } else if try subtext.className() == "" {
                            if try subtext.text() == "discussion" {
                                hnWebStory.descendants = 0
                            } else if try subtext.text().hasSuffix("comments") {
                                hnWebStory.descendants = Int(try subtext.text().replacingOccurrences(of: "\u{00A0}", with: "").dropLast(8))
                            }
                        }
                    }
                    stories.append(Story(hnWebStory))
                }
            }
        }
        catch(let error) {
            throw error
        }
        return stories
    }

}

private extension DateFormatter {
    static func storyDate(from date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: date)
    }
}

private extension Story {
    init(_ item: HNWebStory) {
        self.by = item.by ?? ""
        self.descendants = item.descendants ?? 0
        self.id = item.id ?? 0
        self.commentIDs = item.kids ?? []
        self.score = item.score ?? 0
        self.date = item.date
        self.title = item.title ?? ""
        self.url = item.url
        self.text = item.text
        self.age = item.age
        self.createdAt = Int(item.date.timeIntervalSince1970)
    }
}
