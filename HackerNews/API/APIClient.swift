//
//  APIClient.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 11/22/19.
//  Copyright © 2019 Kenichi Fujita. All rights reserved.
//

import Foundation

enum StoryQueryType: String {
    case top
    case ask
    case show
}

private enum API {
    case getItem(Int)
    case ids(StoryQueryType)
    case searchStories(String)
    case comment(Int)
    
    fileprivate var url: URL? {
        switch self {
        case .getItem(let id):
            return URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")
        case .ids(let queryType):
            return URL(string: "https://hacker-news.firebaseio.com/v0/\(queryType.rawValue)stories.json")
        case .searchStories(let searchText):
            return URL(string: "http://hn.algolia.com/api/v1/search?query=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&tags=story")
        case .comment(let id):
            return URL(string: "http://hn.algolia.com/api/v1/items/\(id)")
        }
    }
}

enum APIClientError: Error {
    case invalidURL
    case domainError
    case decodingError
    case unknownError
    case cancel
}

private struct Item: Decodable {
    fileprivate let id: Int?
    private let deleted: Bool?
    fileprivate let by: String?
    fileprivate let date: Date
    fileprivate let text: String?
    private let dead: Bool?
    private let parent: Int?
    private let poll: Int?
    fileprivate let kids: [Int]?
    fileprivate let url: String?
    fileprivate let score: Int?
    fileprivate let title: String?
    private let parts: [Int]?
    fileprivate let descendants: Int?
    
    private enum CodingKeys: String, CodingKey {
        case date = "time"
        case id
        case deleted
        case by
        case text
        case dead
        case parent
        case poll
        case kids
        case url
        case score
        case title
        case parts
        case descendants
    }
}

struct Story: Equatable {
    let by: String
    let descendants: Int
    let id: Int
    var commentIDs: [Int]? = nil
    let score: Int
    let date: Date
    let title: String
    let url: String?
    let text: String?
    var type: StoryType {
        if title.hasPrefix("Show HN:") {
            return .show
        } else if title.hasPrefix("Ask HN:") || url == nil {
            return .ask
        } else {
            return .normal
        }
    }
    var info: String {
        ["\(score) points", by, date.postTimeAgo].compactMap { $0 }.joined(separator: " · ")
    }
}

extension Story {
    fileprivate init(_ item: Item) {
        self.by = item.by ?? ""
        self.descendants = item.descendants ?? 0
        self.id = item.id ?? 0
        self.commentIDs = item.kids ?? []
        self.score = item.score ?? 0
        self.date = item.date
        self.title = item.title ?? ""
        self.url = item.url
        self.text = item.text
    }
}

enum StoryType: String {
    case ask
    case show
    case normal
}

struct Comment {
    let by: String?
    let deleted: Bool
    let id: Int
    let commentIDs: [Int]?
    var comments: [Comment] = []
    let parent: Int
    var text: String?
    let date: Date
    let tier: Int
    var info: String {
        [by, date.postTimeAgo].compactMap { $0 }.joined(separator: " · ")
    }
}

extension Comment {
    public var flatten: [Comment] {
        var array: [Comment] = [self]
        for comment in comments {
            array.append(contentsOf: comment.flatten)
        }
        return array
    }
}


class APIClient {
    
    private let session: URLSession
    private var hackerNewsSearchTask: URLSessionTask?
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    private func getItem(id: Int, completionHandler: @escaping (Result<Item, APIClientError>) -> Void) {
        guard let itemUrl = API.getItem(id).url else {
            completionHandler(.failure(.invalidURL))
            return
        }
        session.dataTask(with: itemUrl) { data, response, error in
            guard let data = data else {
                if let _ = error {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.domainError))
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.unknownError))
                    }
                    return
                }
            }
            do {
                let item = try JSONDecoder.hackerNews.decode(Item.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(.success(item))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    func stories(for ids: [Int], completionHandler: @escaping ([Story]) -> Void) {
        var returningIDs = ids
        var stories: [Int: Story] = [:]
        if ids.count == 0 {
            completionHandler([])
            return
        }
        for id in ids {
            self.getItem(id: id) { (result) in
                switch result {
                case .success(let item):
                    let story: Story = Story(item)
                    stories[id] = story
                case .failure(_):
                    if let indexToRemove = returningIDs.firstIndex(of: id) {
                        returningIDs.remove(at: indexToRemove)
                    }
                }
                if stories.count == returningIDs.count {
                    completionHandler(ids.compactMap { stories[$0] })
                }
            }
        }
    }
    
    func ids(for type: StoryQueryType, completionHandler: @escaping (Result<[Int], APIClientError>) -> Void) {
        guard let url = API.ids(type).url else {
            completionHandler(.failure(.invalidURL))
            return
        }
        session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let _ = error {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.domainError))
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.unknownError))
                    }
                    return
                }
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let json = json as? [Int] {
                    let ids = Array(json[0..<min(200, json.count)])
                    DispatchQueue.main.async {
                        completionHandler(.success(ids))
                    }
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(.decodingError))
                }
            }
            
        }.resume()
    }
    
}

private struct HNSStoryResponse: Decodable {
    let hits: [HNSStory]
}

private struct HNSStory: Decodable {
    public let date: Date
    public let title: String
    public let url: String?
    public let by: String
    public let score: Int
    public let descendants: Int
    public let id: String?
    public let text: String?
    
    private enum CodingKeys: String, CodingKey {
        case date = "createdAt"
        case title
        case url
        case by = "author"
        case score = "points"
        case descendants = "numComments"
        case id = "objectID"
        case text
    }
}

private struct HNSCommentResponse: Codable {
    let children: FailableCodableArray<HNSComment>
}

private struct HNSComment: Codable {
    public let id: Int
    public let date: Date
    public let by: String
    public var text: String?
    public var parent: Int?
    public var storyID: Int?
    public var comments: [HNSComment?]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case date = "createdAt"
        case by = "author"
        case text
        case parent = "parentId"
        case storyID
        case comments = "children"
    }
}


extension APIClient {

    func searchStories(searchText: String, completionHandler: @escaping (Result<[Story], APIClientError>) -> Void) {
        hackerNewsSearchTask?.cancel()
        guard searchText != "" else {
            completionHandler(.success([]))
            return
        }
        guard let url: URL = API.searchStories(searchText).url else {
            completionHandler(.failure(.invalidURL))
            return
        }
        self.hackerNewsSearchTask = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error = error {
                    DispatchQueue.main.async {
                        if (error as NSError).code == NSURLErrorCancelled {
                            completionHandler(.failure(.cancel))
                        } else {
                            completionHandler(.failure(.domainError))
                        }
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.unknownError))
                    }
                    return
                }
            }
            do {
                let hnsStoryResponse = try JSONDecoder.hackerNewsSearch.decode(HNSStoryResponse.self, from: data)
                let hnsStories = hnsStoryResponse.hits.compactMap { $0 }
                DispatchQueue.main.async {
                    completionHandler(.success(hnsStories.compactMap { Story(hnsStory: $0) }))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(.decodingError))
                }
            }
        }
        hackerNewsSearchTask?.resume()
    }
    
    func comment(id: Int, completionHandler: @escaping (Result<[Comment], APIClientError>) -> Void) {
        guard let url = API.comment(id).url else {
            completionHandler(.failure(.invalidURL))
            return
        }
        session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let _ = error {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.domainError))
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.unknownError))
                    }
                    return
                }
            }
            do {
                let comments = try JSONDecoder.hackerNewsSearch.decode(HNSCommentResponse.self, from: data).children.elements
                DispatchQueue.main.async {
                    completionHandler(.success(comments.map { Comment(hnsComment: $0) }))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(.decodingError))
                }
            }
        }.resume()
    }
}

extension Story {
    fileprivate init(hnsStory: HNSStory) {
        self.by = hnsStory.by
        self.descendants = hnsStory.descendants
        self.id = Int(hnsStory.id ?? "0") ?? 0
        self.score = hnsStory.score
        self.date = hnsStory.date
        self.title = hnsStory.title
        self.url = hnsStory.url
        self.text = hnsStory.text
    }
}

extension Comment {
    fileprivate init(hnsComment: HNSComment, tier: Int = 0) {
        self.by = hnsComment.by
        self.deleted = false
        self.id = hnsComment.id
        self.commentIDs = []
        self.comments = hnsComment.comments.compactMap { $0 }.compactMap { Comment(hnsComment: $0, tier: tier + 1) }
        self.parent = hnsComment.parent ?? 0
        self.text = hnsComment.text
        self.date = hnsComment.date
        self.tier = tier
    }
}

extension JSONDecoder {
    static var hackerNews: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
    
    static var hackerNewsSearch: JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
}

private struct FailableCodableArray<Element: Codable>: Codable {
    fileprivate var elements: [Element]
    
    fileprivate init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        while !container.isAtEnd {
            if let element = try container.decode(FailableDecodable<Element>.self).base {
                elements.append(element)
            }
        }
        self.elements = elements
    }
    
    fileprivate func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
}

private struct FailableDecodable<Base: Codable>: Codable {
    fileprivate let base: Base?
    
    fileprivate init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}
