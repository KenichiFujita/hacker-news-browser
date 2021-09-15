//
//  HackerNewsWidget.swift
//  HackerNewsWidget
//
//  Created by Kenichi Fujita on 1/11/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import KingfisherSwiftUI


private struct StoryTimeline: TimelineProvider {

    private let api: APIClient = APIClient()
    typealias Entry = StoriesEntry

    func placeholder(in context: Context) -> StoriesEntry {
        return StoriesEntry(date: Date(), stories: Array(repeating: Story.dummyStory, count: 5))
    }

    func getSnapshot(in context: Context, completion: @escaping (StoriesEntry) -> Void) {
        stories { (stories) in
            let entry = StoriesEntry(date: Date(), stories: stories)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StoriesEntry>) -> Void) {
        stories { (stories) in
            let entry = StoriesEntry(date: Date(), stories: stories)
            completion(Timeline(entries: [entry], policy: .atEnd))
        }
    }

    private func stories(completionHandler: @escaping ([Story]) -> Void) {
        api.stories(for: .top, page: 1) { result in
            switch result {
            case .success(let stories):
                completionHandler(stories)
            case .failure(_):
                completionHandler([])
            }
        }
    }

}

struct StoriesEntry: TimelineEntry {
    public let date: Date
    public let stories: [Story]
}

private struct HackerNewsWidgetView: View {

    let entry: StoryTimeline.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        if !entry.stories.isEmpty {
            switch family {
            case .systemSmall:
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(entry.stories[0...min(1, entry.stories.count - 1)]) { story in
                        StoryInfoView(story: story, family: .systemSmall)
                    }
                }.padding()
            case .systemMedium:
                VStack(alignment: .leading, spacing: 3) {
                    StoriesHeaderView()
                    ForEach(entry.stories[0...min(1, entry.stories.count - 1)]) { story in
                        StoryInfoView(story: story, family: .systemMedium)
                    }
                }.padding()
            case .systemLarge:
                VStack(alignment: .leading, spacing: 3) {
                    StoriesHeaderView()
                    ForEach(entry.stories[0...min(3, entry.stories.count - 1)]) { story in
                        StoryInfoView(story: story, family: .systemLarge)
                    }
                }.padding()
            default:
                Text("Default")
            }
        } else {
            Text("Sorry. Something went wrong...")
        }
    }
}


@main

private struct HackerNewsWidget: Widget {
    private let kind: String = "HackerNewsWidget"
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StoryTimeline(), content: { entry in
            HackerNewsWidgetView(entry: entry)
        })
        .configurationDisplayName("Top Stories")
        .description("Get the latest top stories from Hacker News.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])

    }
}

private struct StoryInfoView: View {

    let story: Story
    let family: WidgetFamily

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 3) {
                    if let urlString = story.url {
                        KFImage(urlString.favconURL)
                            .placeholder {
                                Image(uiImage: story.defaultTouchIcon())
                                    .renderingMode(.original)
                                    .resizable()
                                    .cornerRadius(2)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 10, height: 10, alignment: .center)
                            }
                            .renderingMode(.original)
                            .resizable()
                            .cornerRadius(2)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10, alignment: .center)
                        Text(URL(string: urlString)?.hostWithoutWWW?.uppercased() ?? "")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 10))
                            .foregroundColor(Color(.secondaryLabel))
                            .lineLimit(1)
                    }
                }
                Text(story.title)
                    .font(.system(.caption2))
                    .fontWeight(.bold)
                    .lineLimit(3)
                    .frame(maxHeight: .infinity, alignment: .top)
            }.frame(maxHeight: .infinity)
            if family != .systemSmall {
                Spacer()
                CommentImageView(numberOfComments: story.descendants)
            }
        }
    }

}

private struct StoriesHeaderView: View {

    var body: some View {
        HStack {
            Text("HNB Top Stories")
                .font(.system(.footnote))
                .foregroundColor(Color(red: 242 / 255, green: 124 / 255, blue: 74 / 255))
                .fontWeight(.heavy)
            Spacer()
         Image("WidgetIcon")
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 20, height: 20, alignment: .top)
        }
    }

}

private struct CommentImageView: View {

    let numberOfComments: Int

    var body: some View {
        ZStack {
            Image("commentButtonImage")
                .renderingMode(.template)
                .colorMultiply(Color(.label))
            Text(String(numberOfComments))
                .font(.system(size: 10))
                .lineLimit(1)
        }.padding(.top, 7)
    }

}


private struct HackerNewsWidget_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            HackerNewsWidgetView(entry: StoriesEntry(date: Date(), stories: Array(repeating: Story.dummyStory, count: 5)))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}


private extension Story {
    static let dummyStory: Story = Story(by: "DummyStory",
                                                     descendants: 0,
                                                     id: 0,
                                                     score: 0,
                                                     date: Date(),
                                                     title: "DummyStory-----------------------------------------------------------------------------------------------------------------------------",
                                                     url: "https://dummy.hnb",
                                                     text: nil)
}

private extension String {
    var favconURL: URL? {
        guard let url = URL(string: self), let host = url.host else {
            return nil
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.google.com"
        components.path = "/s2/favicons"
        components.queryItems = [URLQueryItem(name: "domain", value: host)]
        return components.url
    }
}
