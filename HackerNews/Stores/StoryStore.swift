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
    private var idsForTypes: [StoryQueryType:[Int]] = [:]

    init(api: APIClient = APIClient()) {
        self.api = api
    }
    
    func stories(for type: StoryQueryType,
                 offset: Int,
                 limit: Int,
                 completionHandler: @escaping (Result<[Story], Error>) -> Void ) {
        if offset == 0 {
            idsForTypes[type] = nil
        }
        let ids = idsForTypes[type] ?? []
        if ids.count == 0 {
            api.ids(for: type) { [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let ids):
                    strongSelf.idsForTypes[type] = ids
                    strongSelf.api.stories(for: Array(ids[offset..<(min(offset + limit, ids.count))])) { (stories) in
                        completionHandler(.success(stories))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
            return
        } else {
            if ids.count > offset {
                self.api.stories(for: Array(ids[offset..<min((offset + limit), ids.count)])) { (stories) in
                    completionHandler(.success(stories))
                }
            } else {
                completionHandler(.success([]))
            }
        }
    }
    
}
