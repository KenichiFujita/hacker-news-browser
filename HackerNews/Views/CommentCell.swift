//
//  StoryViewCell.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 12/4/19.
//  Copyright © 2019 Kenichi Fujita. All rights reserved.
//

import UIKit

protocol CommentCellDelegate: class {
    func commentCell(_ commentCell: CommentCell, linkTapped url: URL)
}

class CommentCell: UITableViewCell {
    
    weak var delegate: CommentCellDelegate?

    private var tier: Int = 0
    
    private let htmlView: HTMLView = {
        let htmlView = HTMLView(frame: CGRect.zero)
        htmlView.translatesAutoresizingMaskIntoConstraints = false
        return htmlView
    }()
    
    private let topHorizontalSeparatorView: UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .systemGray4
        return separatorView
    }()
    
    private let userAndTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    private let vStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    private let indentLineStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var indentLineStackWidthAnchor: NSLayoutConstraint = {
        let constraint = indentLineStack.widthAnchor.constraint(equalToConstant: 0)
        constraint.isActive = true
        return constraint
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .systemBackground
        htmlView.delegate = self

        vStack.addArrangedSubview(userAndTimeLabel)
        vStack.addArrangedSubview(htmlView)

        contentView.addSubview(indentLineStack)
        contentView.addSubview(vStack)
        contentView.addSubview(topHorizontalSeparatorView)

        NSLayoutConstraint.activate([
            indentLineStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            indentLineStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            indentLineStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            vStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            vStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            vStack.leadingAnchor.constraint(equalTo: indentLineStack.trailingAnchor),
            topHorizontalSeparatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topHorizontalSeparatorView.heightAnchor.constraint(equalToConstant: 2),
            topHorizontalSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topHorizontalSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with comment: Comment) {
        htmlView.html = comment.text
        userAndTimeLabel.text = comment.info
        tier = comment.tier
        topHorizontalSeparatorView.isHidden = comment.tier != 0
        addIndentLineView(withTier: comment.tier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        indentLineStackWidthAnchor.constant = CGFloat(tier) * contentView.directionalLayoutMargins.leading
    }

    private func addIndentLineView(withTier tier: Int) {
        if tier > 0 {
            for _ in 1...tier {
                indentLineStackWidthAnchor.constant += 1
                let separatorView = UIView()
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                separatorView.backgroundColor = .systemGray4
                separatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true
                indentLineStack.addArrangedSubview(separatorView)
            }
            let dummyView = UIView()
            dummyView.translatesAutoresizingMaskIntoConstraints = false
            dummyView.widthAnchor.constraint(equalToConstant: 0).isActive = true
            indentLineStack.addArrangedSubview(dummyView)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        htmlView.html = nil
        userAndTimeLabel.text = nil
        indentLineStack.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }

}

extension CommentCell: HTMLViewDelegate {
    func htmlView(_ htmlView: HTMLView, linkTapped url: URL) {
        delegate?.commentCell(self, linkTapped: url)
    }
}
