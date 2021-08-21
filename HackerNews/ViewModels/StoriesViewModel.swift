//
//  StoriesViewModel.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 2/3/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit

protocol StoriesViewModelDelegate: AnyObject {
    func storiesViewModelUpdated(_ viewModel: StoriesViewModelType)
}

protocol StoriesViewModelType: AnyObject {
    var inputs: StoriesViewModelInputs { get }
    var outputs: StoriesViewModelOutputs { get }
    var stories: [Story] { get }
    var hasMore: Bool { get }
    var delegate: StoriesViewModelDelegate? { get set }
    var canShowInstruction: Bool { get }
    var favoritesStore: FavoritesStore { get }
    func viewDidLoad()
    func didPullToRefresh()
    func lastCellWillDisplay()
}

protocol StoriesViewModelInputs {
    func viewDidLoad()
    func didPullToRefresh()
    func lastCellWillDisplay()
    func storyCellCommentButtonTapped(at indexPath: IndexPath)
    func didSelectRowAt(_ indexPath: IndexPath)
}

protocol StoriesViewModelOutputs: AnyObject {
   var stories: [Story] { get }
   var favoritesStore: FavoritesStore { get }
   var reloadData: () -> Void { get set }
   var didReceiveServiceError: (Error) -> Void { get set }
   var openStory: (Story) -> Void { get set }
   var openURL: (URL) -> Void { get set }
}


class StoriesViewModel: StoriesViewModelType, StoriesViewModelOutputs {

    var inputs: StoriesViewModelInputs { return self }

    var outputs: StoriesViewModelOutputs { return self }

    private(set) var stories: [Story] = [] {
        didSet {
            delegate?.storiesViewModelUpdated(self)
        }
    }
    weak var delegate: StoriesViewModelDelegate?
    let store: StoryStore
    let storyImageInfoStore: StoryImageInfoStore
    let type: StoryQueryType
    var hasMore: Bool = false
    var canShowInstruction: Bool {
      return false
    }
    var favoritesStore: FavoritesStore
    var reloadData: () -> Void = { }

    var didReceiveServiceError: (Error) -> Void = { _ in }

    var openStory: (Story) -> Void = { _ in }

    var openURL: (URL) -> Void = { _ in }

    init(storyQueryType type: StoryQueryType, storyStore: StoryStore, storyImageInfoStore: StoryImageInfoStore, favoritesStore: FavoritesStore) {
        self.type = type
        self.store = storyStore
        self.storyImageInfoStore = storyImageInfoStore
        self.favoritesStore = favoritesStore
    }

    private func load(offset: Int = 0) {
        hasMore = false
        store.stories(for: self.type,
                      offset: offset,
                      limit: 10) { [weak self] (result) in
            guard let strongSelf = self else { return }
            if case .success(let stories) = result {
                if offset == 0 {
                    strongSelf.stories = stories
                } else {
                    strongSelf.stories.append(contentsOf: stories)
                }
                if stories.count < 10 {
                    strongSelf.hasMore = false
                } else {
                    strongSelf.hasMore = true
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

    }

    func lastCellWillDisplay() {
        if hasMore {
            load(offset: stories.count)
        }
    }

    func storyCellCommentButtonTapped(at indexPath: IndexPath) {
        openStory(stories[indexPath.row])
    }

    func didSelectRowAt(_ indexPath: IndexPath) {

    }
    
}
