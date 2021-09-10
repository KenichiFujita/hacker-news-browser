//
//  StoryStore.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 2/15/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import Foundation

class StoryStore {
    
    private let api: APIClient
    private var nextPageInfos: [StoryQueryType: (queryItems: [URLQueryItem], exists: Bool)] = [:]

    init(api: APIClient = APIClient()) {
        self.api = api
    }

    func stories(for type: StoryQueryType,
                 toRefresh: Bool,
                 completionHandler: @escaping (Result<[Story], Error>) -> Void ) {
        var queryItems: [URLQueryItem]?
        if !toRefresh, let nextPageQueryItems = nextPageInfos[type] {
            if nextPageQueryItems.exists {
                queryItems = nextPageQueryItems.queryItems
            } else {
                return
            }
        }
        api.stories(for: .stories(for: type, queryItems: queryItems)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (stories, urlQueryItemsOfNextPage)):
                    self?.nextPageInfos[type] = (queryItems: urlQueryItemsOfNextPage ?? [],
                                                      exists: urlQueryItemsOfNextPage != nil)
                    completionHandler(.success(stories))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
}
