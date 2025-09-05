//
//  WebUI_LauncherApp.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

// WebUILauncherAppswift
import SwiftUI

// 1. Create the AppDelegate class
class AppDelegate: NSObject, NSApplicationDelegate {
    var processManager: ProcessManager?

    func applicationWillTerminate(_ aNotification: Notification) {
        // This is called when the user quits the app (Cmd+Q or via menu)
        print("Application is terminating, stopping script...")
        processManager?.stopScript()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // This makes the app quit when the last window is closed (like iOS behavior)
        // If you prefer the app to stay running without windows, return false instead
        print("Last window closed, stopping script...")
        processManager?.stopScript()
        return true
    }
}


@main
struct WebUILauncherApp: App {
    // 2. Register the AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 500, height: 400)
    }
}
