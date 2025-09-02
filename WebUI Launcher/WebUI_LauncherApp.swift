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
