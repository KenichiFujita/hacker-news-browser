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
        
        guard let idsForType = self.idsForTypes[type] else {
            api.ids(for: type) { (result) in
                switch result {
                case .success(let ids):
                    self.idsForTypes[type] = ids
                    self.api.stories(for: Array(ids[offset..<(min(offset + limit, ids.count))])) { (stories) in
                        completionHandler(.success(stories))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
            return
        }
        if idsForType.count > offset {
            self.api.stories(for: Array(idsForType[offset..<min((offset + limit), idsForType.count)])) { (stories) in
                completionHandler(.success(stories))
            }
        } else {
            completionHandler(.success([]))
        }
        
    }
    
}
