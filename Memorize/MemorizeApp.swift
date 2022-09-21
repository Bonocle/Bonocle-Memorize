//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Begzod on 25/04/21.
//

import SwiftUI

@main
struct MemorizeApp: App {
    private let game = EmojiMemoryGame()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: game)
        }
    }
}
