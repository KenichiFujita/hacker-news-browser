//
//  AccountViewController.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 9/24/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    private let viewModel: AccountViewModelType

    private lazy var signOutBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Sign out",
            style: .plain,
            target: self,
            action: #selector(didTapSignOutButton)
        )
        return button
    }()

    init(api: APIClient, favoritesStore: FavoritesStore) {
        self.viewModel = AccountViewModel(api: api, favoritesStore: favoritesStore)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .blue
        navigationItem.rightBarButtonItem = signOutBarButtonItem

        bind()
        viewModel.inputs.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func bind() {

        viewModel.outputs.loggedOut = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.outputs.logoutFailed = {
            #warning("handle logout fail")
        }

    }

    @objc private func didTapSignOutButton() {
        viewModel.inputs.didTapSignOutButton()
    }
    
}
