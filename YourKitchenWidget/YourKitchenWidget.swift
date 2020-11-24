//
//  YourKitchenWidget.swift
//  YourKitchenWidget
//
//  Created by Markus Moltke on 03/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), mealplan: Mealplan(meals: [MealItem(date: Date.start, recipe: Recipe.none), MealItem(date: Date.start.addDays(value: 1), recipe: Recipe.none), MealItem(date: Date.start.addDays(value: 2), recipe: Recipe.none)], id: "none"), images: [:], familySize: context.family, error: "Placeholder error")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), mealplan: Mealplan(meals: [MealItem(date: Date.start, recipe: Recipe(name: "Burger", image: "")), MealItem(date: Date.start.addDays(value: 1), recipe: Recipe(name: "Pizza", image: "")), MealItem(date: Date.start.addDays(value: 2), recipe: Recipe(name: "Tart", image: ""))], id: "none"), images: [:], familySize: context.family, error: "Placeholder error")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

        print("Loading mealplan..")

        guard let userID = userID else {
            let entry = SimpleEntry(date: currentDate, mealplan: nil, images: [:], familySize: context.family, error: "You need to log in")
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            return
        }
        MealplanLoader.fetch(userID: userID) { result in
            var images = [String: UIImage]()
            if case let .success(mealplan) = result {
                print("Success")
                if context.family == .systemSmall || context.family == .systemLarge {
                    if let meal = mealplan.meals.first {
                        if meal.recipe.image != "" && URL(string: meal.recipe.image + (meal.recipe.image.contains("?") ? "&" : "?") + "w=60&h=60") != nil {
                            NetworkManager.shared.requestImage(url: meal.recipe.image + (meal.recipe.image.contains("?") ? "&" : "?") + "w=60&h=60") { image in
                                if let image = image {
                                    images[meal.recipe.id] = image
                                }
                                print("Loaded image")
                                let entry = SimpleEntry(date: currentDate, mealplan: mealplan, images: images, familySize: context.family, error: "")
                                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                                completion(timeline)
                            }
                            return
                        }
                    }
                }
                let entry = SimpleEntry(date: currentDate, mealplan: mealplan, images: images, familySize: context.family, error: "")
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
            } else if case let .failure(error) = result {
                print("Failed")
                let entry = SimpleEntry(date: currentDate, mealplan: nil, images: images, familySize: context.family, error: error.localizedDescription)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
            }
        }
    }

    var userID: String? = {
        if let userid = UserDefaults(suiteName: "group.com.unknownstudios.yk")!.string(forKey: "userID") {
            print(userid)
            return userid
        } else if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.unknownstudios.yk") {
            if let data = try? Data(contentsOf: url.appendingPathComponent("userID.plist")), let string = String(data: data, encoding: .utf8) {
                return string
            }
        }
        return nil
    }()
}

enum MealplanLoader {
    static func fetch(userID: String, completion: @escaping (Result<Mealplan, Error>) -> Void) {
        let branchContentsURL = URL(string: "https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/getMealplan?owner=" + userID)!
        print("Fetching: " + branchContentsURL.absoluteString)
        let task = URLSession.shared.dataTask(with: branchContentsURL) { data, _, error in
            guard error == nil else {
                print("Some error happened")
                completion(.failure(error!))
                return
            }
            if let data = data {
                print("Getting data")
                do {
                    let mealplan = try JSONDecoder().decode(Mealplan.self, from: data)
                    completion(.success(mealplan))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mealplan: Mealplan?
    let images: [String: UIImage]
    let familySize: WidgetFamily
    let error: String
}

struct YourKitchenWidgetEntryView: SwiftUI.View {
    var entry: Provider.Entry

    var body: some SwiftUI.View {
        ZStack {
            AppConstants.Colors.YKColor
            if let mealplan = entry.mealplan {
                VStack {
                    if entry.familySize == .systemSmall {
                        if let image = entry.images[mealplan.meals.first?.recipe.id ?? ""] {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .clipped()
                        } else {
                            Image("Placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .clipped()
                        }
                        Text(mealplan.meals.first?.recipe.name ?? "test")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        Text("Today's meal")
                            .font(.system(size: 15))
                            .foregroundColor(Color(UIColor.systemGray5))
                    } else if entry.familySize == .systemMedium {
                        VStack {
                            ForEach(0 ..< min(mealplan.meals.count, 3)) { index in
                                if let meal = mealplan.meals[index] {
                                    HStack {
                                        Text(self.convertToShortDate(date: meal.date))
                                            .padding(5)
                                            .frame(width: 50)
                                            .background(Color.white.opacity(0.25))
                                            .cornerRadius(6)
                                            .foregroundColor(Color.white)
                                        Text(meal.recipe.name)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }.padding(2)
                                } else {
                                    EmptyView()
                                }
                            }
                        }.padding(.horizontal, 8)
                    } else {
                        if let image = entry.images[mealplan.meals.first?.recipe.id ?? ""] {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .clipped()
                        } else {
                            Image("Placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .clipped()
                        }
                        Text(mealplan.meals.first?.recipe.name ?? "test")
                            .foregroundColor(.white)
                        Text("Today's meal")
                            .font(.system(size: 15))
                            .foregroundColor(Color(UIColor.systemGray5))
                        VStack {
                            ForEach(1 ..< min(mealplan.meals.count, 6)) { index in
                                if let meal = mealplan.meals[index] {
                                    HStack {
                                        Text(self.convertToShortDate(date: meal.date))
                                            .padding(5)
                                            .frame(width: 50)
                                            .background(Color.white.opacity(0.25))
                                            .cornerRadius(6)
                                            .foregroundColor(Color.white)
                                        Text(meal.recipe.name)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }.padding(2)
                                } else {
                                    EmptyView()
                                }
                            }
                        }.padding(.horizontal, 8)
                    }
                }
            } else {
                Text(entry.error)
                    .foregroundColor(.white)
            }
        }.widgetURL(URL(string: "YourKitchen://mealplan"))
    }

    func convertToShortDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: date)
    }
}

@main
struct YourKitchenWidget: Widget {
    let kind: String = "YourKitchenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            YourKitchenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("YourKitchen")
        .description("View your meal plan with this widget.")
    }
}

public struct MealItem: Codable {
    public var date: Date
    public var recipe: Recipe

    init(date: Date, recipe: Recipe) {
        self.date = date
        self.recipe = recipe
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let intDate = try? values.decode(Double.self, forKey: .date) {
            self.date = Date(timeIntervalSince1970: intDate)
        } else if let tmpDate = try? values.decode(String.self, forKey: .date), let date = dateFormatter.date(from: tmpDate) {
            self.date = date
        } else {
            let date = try values.decode(Date.self, forKey: .date) // If this fails we shouldn't produce the mealitem
            self.date = date
        }
        recipe = try values.decode(Recipe.self, forKey: .recipe)
    }

    enum CodingKeys: String, CodingKey {
        case date
        case recipe
    }
}

public struct Mealplan: Codable {
    public var meals = [MealItem]()
    public var id: String
}
