//
//  FlexSightApp.swift
//  FlexSight
//
//  Created by Drew McCalla on 8/26/26.
//

import SwiftUI

@main
struct FlexSightApp: App {
    @State private var sessionStore = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sessionStore)
        }
    }
}
