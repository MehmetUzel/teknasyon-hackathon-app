//
//  serviceguruApp.swift
//  serviceguru
//
//  Created by Macbook on 8.07.2023.
//

import SwiftUI

@main
struct serviceguruApp: App {
    @StateObject var homepageModel: HomePageModel = HomePageModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(homepageModel)
        }
    }
}
