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

    private let store: StoryStore

    private let type: StoryQueryType

    init(storyQueryType type: StoryQueryType, storyStore: StoryStore, storyImageInfoStore: StoryImageInfoStore, favoritesStore: FavoritesStore) {
        self.type = type
        self.store = storyStore
        self.storyImageInfoStore = storyImageInfoStore
        self.favoritesStore = favoritesStore
    }

    private func load(toRefresh: Bool = false) {
        store.stories(for: type, toRefresh: toRefresh) { [weak self] (result) in
            switch result {
            case .success(let receivedStories):
                if toRefresh {
                    self?.stories = receivedStories
                } else {
                    self?.stories.append(contentsOf: receivedStories)
                }
            case .failure(let error):
                self?.didReceiveServiceError(error)
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
            self.load(toRefresh: true)
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
