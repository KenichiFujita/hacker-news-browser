//
//  HNWebParser.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 9/6/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import SwiftSoup
import Foundation

struct HNWebStory: StoryProtocol {
    var kids: [Int]?
    var text: String?
    var by: String?
    var rank: String?
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

    static func parseTopStories(_ html: String) throws -> (stories: [HNWebStory], urlQueryItemsOfNextPage: [URLQueryItem]?) {
        var returnValue: (stories: [HNWebStory], urlQueryItemsOfNextPage: [URLQueryItem]?) = ([], nil)
        do {
            guard let itemList = try SwiftSoup.parse(html).getElementsByClass("itemlist").first() else { return ([], nil)}
            let athings = try itemList.getElementsByClass("athing").array()
            let subtexts = try itemList.getElementsByClass("subtext").array()
            returnValue.urlQueryItemsOfNextPage = itemList.urlQueryItemsOfMoreLink()
            if athings.count == subtexts.count {
                for i in 0..<athings.count {
                    var story = HNWebStory()
                    story.id = Int(athings[i].id())
                    try athings[i].children().forEach { element in
                        if element.hasClass("title") {
                            try element.children().forEach { child in
                                if child.hasClass("rank") {
                                    story.rank = try child.text()
                                } else if child.hasClass("storylink") {
                                    story.title = try child.select("a").text()
                                    story.url = try child.select("a").attr("href")
                                }
                            }
                        } else if element.hasClass("votelinks") {
                            story.voteLink = try element.select("a").attr("href")
                        }
                    }
                    try subtexts[i].children().forEach { subtext in
                        if subtext.hasClass("score") {
                            story.score = (try subtext.text() as NSString).integerValue
                        } else if subtext.hasClass("age") {
                            story.age = try subtext.text()
                            story.date = DateFormatter.storyDate(from: try subtext.attr("title")) ?? Date()
                        } else if subtext.hasClass("hnuser") {
                            story.by = try subtext.text()
                        } else if try subtext.className() == "" {
                            if try subtext.text() == "discussion" {
                                story.descendants = 0
                            } else if try subtext.text().hasSuffix("comments") {
                                story.descendants = Int(try subtext.text().replacingOccurrences(of: "\u{00A0}", with: "").dropLast(8))
                            }
                        }
                    }
                    returnValue.stories.append(story)
                }
            }
        }
        catch {
            throw APIClientError.decodingError
        }
        return returnValue
    }

}

private extension DateFormatter {
    static func storyDate(from date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.date(from: date)
    }
}

private extension Element {
    func urlQueryItemsOfMoreLink() -> [URLQueryItem]? {
        guard let moreLink = try? self.getElementsByClass("morelink").first()?.select("a").attr("href") else { return nil }
        let urlComponents = URLComponents(string: "https://news.ycombinator.com/" + moreLink)
        return urlComponents?.queryItems
    }
}
