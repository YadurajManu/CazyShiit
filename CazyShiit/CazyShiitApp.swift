//
//  CazyShiitApp.swift
//  CazyShiit
//
//  Created by Yaduraj Singh on 19/02/25.
//

import SwiftUI

@main
struct CazyShiitApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(languageManager)
        }
    }
}
