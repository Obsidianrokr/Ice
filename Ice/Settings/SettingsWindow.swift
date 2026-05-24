//
//  SettingsWindow.swift
//  Ice
//

import SwiftUI

struct SettingsWindow: Scene {
    @ObservedObject var appState: AppState

    var body: some Scene {
        IceWindow(id: .settings) {
            SettingsView(navigationState: appState.navigationState)
                .frame(minWidth: 825, maxWidth: 1150, minHeight: 500, maxHeight: 750)
        }
        .commandsRemoved()
        .windowResizability(.contentSize)
        .defaultSize(width: 900, height: 625)
        .windowToolbarLabelStyle(fixed: .iconOnly)
        .environmentObject(appState)
    }
}
