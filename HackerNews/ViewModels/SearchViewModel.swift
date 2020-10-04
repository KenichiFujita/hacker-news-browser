//
//  SearchViewModel.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 10/3/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import Foundation

protocol SearchViewModelType {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

protocol SearchViewModelInputs {
    func viewDidLoad()
    func searchTextDidChange(_ searchText: String)
}

protocol SearchViewModelOutputs: AnyObject {
    var delegate: SearchViewModelDelegate? { get set }
}

protocol SearchViewModelDelegate {
    func show(tableView shouldShowTableView: Bool,
              informationLabel shouldShowInformationLabel: Bool)
    func update(informationText: String)
    func reload(with stories: [Story])
}

class SearchViewModel: SearchViewModelType, SearchViewModelOutputs {

    var inputs: SearchViewModelInputs { return self }
    var outputs: SearchViewModelOutputs { return self }
    var delegate: SearchViewModelDelegate?
    var favoritesStore: FavoritesStore
    private let api: APIClient

    private struct InformationText {
        static let instructionText = "Search stories and results to show up here"
        static let emptyText = "No stories found"
        static let errorText = "Sorry. Something went wrong..."
    }

    init(favoritesStore: FavoritesStore, api: APIClient = APIClient()) {
        self.favoritesStore = favoritesStore
        self.api = api
    }

}

extension SearchViewModel: SearchViewModelInputs {

    func viewDidLoad() {
        delegate?.update(informationText: InformationText.instructionText)
        delegate?.show(tableView: false, informationLabel: true)
    }

    func searchTextDidChange(_ searchText: String) {

        api.searchStories(searchText: searchText) { (result) in

            if searchText == "" {
                self.delegate?.reload(with: [])
                self.delegate?.update(informationText: InformationText.instructionText)
                self.delegate?.show(tableView: false, informationLabel: true)
                return
            }

            DispatchQueue.main.async {
                switch result {
                case .success(let stories):
                    self.delegate?.reload(with: stories)
                    self.delegate?.update(informationText: InformationText.emptyText)
                    self.delegate?.show(tableView: stories.count > 0, informationLabel: stories.count == 0)
                case .failure(let error):
                    if error == APIClientError.cancel {
                        break
                    } else {
                        self.delegate?.reload(with: [])
                        self.delegate?.update(informationText: InformationText.errorText)
                        self.delegate?.show(tableView: false, informationLabel: true)
                    }
                }
            }
        }
    }

}
