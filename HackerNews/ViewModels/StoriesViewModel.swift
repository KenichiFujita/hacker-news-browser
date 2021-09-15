//
//  StoriesViewModel.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 2/3/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit

protocol StoriesViewModelType: AnyObject {
    var inputs: StoriesViewModelInputs { get }
    var outputs: StoriesViewModelOutputs { get }
}

protocol StoriesViewModelInputs {
    func viewDidLoad()
    func didPullToRefresh()
    func lastCellWillDisplay()
    func storyCellCommentButtonTapped(at indexPath: IndexPath)
    func didSelectRowAt(_ indexPath: IndexPath)
}

 protocol StoriesViewModelOutputs: AnyObject {
    var favoritesStore: FavoritesStore { get }
    var reloadData: ([Story]) -> Void { get set }
    var didReceiveServiceError: (Error) -> Void { get set }
    var openStory: (Story) -> Void { get set }
    var openURL: (URL) -> Void { get set }
}


class StoriesViewModel: StoriesViewModelType, StoriesViewModelOutputs {

    var inputs: StoriesViewModelInputs { return self }

    var outputs: StoriesViewModelOutputs { return self }

    private var stories: [Story] = [] {
        didSet {
            reloadData(stories)
        }
    }

    let favoritesStore: FavoritesStore

    var reloadData: ([Story]) -> Void = { _ in }

    var didReceiveServiceError: (Error) -> Void = { _ in }

    var openStory: (Story) -> Void = { _ in }

    var openURL: (URL) -> Void = { _ in }

    let storyImageInfoStore: StoryImageInfoStore

    private let type: StoryQueryType

    private let api: APIClient

    private var nextPage: Int = 1

    private var hasMore: Bool = true

    private var fetchedIDs: Set<Int> = []

    init(storyQueryType type: StoryQueryType, storyImageInfoStore: StoryImageInfoStore, favoritesStore: FavoritesStore, api: APIClient) {
        self.type = type
        self.storyImageInfoStore = storyImageInfoStore
        self.favoritesStore = favoritesStore
        self.api = api
    }

    private func load() {
        guard hasMore else { return }
        hasMore = false
        api.stories(for: type, page: nextPage) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let stories):
                    if !stories.isEmpty {
                        self?.stories.append(contentsOf: stories.filter { story in
                            !strongSelf.fetchedIDs.contains(story.id)
                        })
                        stories.forEach { self?.fetchedIDs.insert($0.id) }
                        self?.nextPage += 1
                        self?.hasMore = true
                    }
                case .failure(let error):
                    self?.didReceiveServiceError(error)
                }
            }
        }
    }

}

extension StoriesViewModel: StoriesViewModelInputs {

    func viewDidLoad() {
        load()
    }

    func didPullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.nextPage = 1
            self.hasMore = true
            self.stories = []
            self.fetchedIDs = []
            self.load()
        }
    }

    func lastCellWillDisplay() {
        load()
    }

    func storyCellCommentButtonTapped(at indexPath: IndexPath) {
        openStory(stories[indexPath.row])
    }

    func didSelectRowAt(_ indexPath: IndexPath) {
        let story = stories[indexPath.row]
        if let urlString = story.url, let url = URL(string: urlString) {
            outputs.openURL(url)
        } else {
            outputs.openStory(story)
        }
    }
    
}
