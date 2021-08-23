//
//  HTMLView.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 1/14/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit
import SwiftSoup
import WebKit

protocol HTMLViewDelegate: class {
    func htmlView(_ htmlView: HTMLView, linkTapped url: URL)
}

class HTMLView: UIView {
    
    weak var delegate: HTMLViewDelegate?
    var html: String? {
        didSet{
            htmlTextView.attributedText = paragraphs(forHTML: html).joined(with: "\n\n")
        }
    }
    
    let htmlTextView: UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        htmlTextView.delegate = self
        self.addSubview(htmlTextView)

        NSLayoutConstraint.activate([
            htmlTextView.topAnchor.constraint(equalTo: topAnchor),
            htmlTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            htmlTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            htmlTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func paragraphs(forHTML html: String?) -> [NSAttributedString] {
        guard let html = html,
            let document = try? SwiftSoup.parse(html),
            let body = try? document.select("body").first() else {
                return []
        }
        return body.getChildNodes().hackerNewsTexts()
    }
    
}


private protocol HackerNewsNode {
    var hnText: NSAttributedString { get }
    var isContainer: Bool { get }
}


extension TextNode: HackerNewsNode {
    var hnText: NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: UIFont.preferredFont(forTextStyle: .subheadline)]
        return NSAttributedString(string: text(), attributes: attributes)
    }
    
    var isContainer: Bool { return false }
}


extension Element: HackerNewsNode {
    
    var hnText: NSAttributedString {
        guard let text = rawText else {
            return NSAttributedString()
        }
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .subheadline),
                                                         .foregroundColor: UIColor.label]
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        let range = NSRange(location: 0, length: text.count)
        
        switch tagName() {
        case "a":
            guard let value = try? attr("href") else {
                return NSAttributedString()
            }
            attributedString.addAttributes([.link: value], range: range)
            return attributedString
        case "i":
            attributedString.addAttributes([.font: UIFont.preferredFont(forTextStyle: .subheadline).italic()], range: range)
            return attributedString
        case "code":
            guard let customFont = UIFont(name: "CourierNewPSMT", size: 14) else {
                return NSAttributedString()
            }
            attributedString.addAttributes([.font: UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: customFont)], range: range)
            return attributedString
        default:
            return NSAttributedString()
        }
    }
    
    var rawText: String? {
        if let textNodes = getChildNodes().filter({ $0 is TextNode }) as? [TextNode] {
            return textNodes.compactMap({ try? $0.outerHtml() }).joined()
        }
        return nil
    }
    
    var isContainer: Bool {
        return ["p", "pre"].contains(tagName())
    }
    
}


private extension Array where Element: Node {
    
    func hackerNewsTexts() -> [NSAttributedString] {
        var current: [NSAttributedString] = []
        var texts: [NSAttributedString] = []
        for node in self.compactMap({ $0 as? HackerNewsNode }) {
            if node.isContainer {
                if !current.isEmpty {
                    texts.append(current.joined())
                    current = []
                }
                if let container = node as? SwiftSoup.Element {
                    texts.append(container.getChildNodes().hackerNewsTexts().joined())
                }
            } else {
                current.append(node.hnText)
            }
        }
        if !current.isEmpty {
            texts.append(current.joined())
        }
        return texts
    }
}

private extension Array where Element: NSAttributedString {
    func joined(with separator: String = "") -> NSAttributedString {
        let joinedAttributedString = NSMutableAttributedString()
        var i = 0
        for hackerNewsText in self {
            if i < self.count - 1, hackerNewsText != NSAttributedString(string: "") {
                joinedAttributedString.append(hackerNewsText)
                joinedAttributedString.append(NSAttributedString(string: separator, attributes: [.font: UIFont.preferredFont(forTextStyle: .subheadline)]))
                i += 1
            } else {
                joinedAttributedString.append(hackerNewsText)
            }
        }
        return joinedAttributedString
    }
}

extension HTMLView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.htmlView(self, linkTapped: URL)
        return false
    }
}
