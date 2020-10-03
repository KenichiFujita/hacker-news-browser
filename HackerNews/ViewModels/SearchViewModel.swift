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
              instructionLabel shouldShowInstructionLabel: Bool,
              emptyLabel shouldShowEmptyLabel: Bool,
              errorLabel shouldShowErrorLabel: Bool)
    func reload(with stories: [Story])
}

class SearchViewModel: SearchViewModelType, SearchViewModelOutputs {

    var inputs: SearchViewModelInputs { return self }
    var outputs: SearchViewModelOutputs { return self }
    var delegate: SearchViewModelDelegate?
    var favoritesStore: FavoritesStore
    let api: APIClient

    init(favoritesStore: FavoritesStore, api: APIClient = APIClient()) {
        self.favoritesStore = favoritesStore
        self.api = api
    }

}

extension SearchViewModel: SearchViewModelInputs {

    func viewDidLoad() {
        delegate?.show(tableView: false,
                       instructionLabel: true,
                       emptyLabel: false,
                       errorLabel: false)
    }

    func searchTextDidChange(_ searchText: String) {

        api.searchStories(searchText: searchText) { (result) in

            if searchText == "" {
                self.delegate?.reload(with: [])
                self.delegate?.show(tableView: false, instructionLabel: true, emptyLabel: false, errorLabel: false)
                return
            }

            DispatchQueue.main.async {
                switch result {
                case .success(let stories):
                    self.delegate?.reload(with: stories)
                    self.delegate?.show(tableView: stories.count > 0, instructionLabel: false, emptyLabel: stories.count == 0, errorLabel: false)
                case .failure(let error):
                    switch error {
                    case APIClientError.invalidURL,
                         APIClientError.unkonwnError,
                         APIClientError.decodingError:
                        self.delegate?.reload(with: [])
                        self.delegate?.show(tableView: false,
                                            instructionLabel: false,
                                            emptyLabel: false,
                                            errorLabel: true)
                    case APIClientError.domainError:
                        break
                    }
                }
            }
        }
    }

}
