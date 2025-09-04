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

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // This is called when the user quits the app (Cmd+Q or via menu)
        print("Application is terminating, stopping script...")
        processManager?.stopScript()
        return .terminateNow
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // This is called when the user quits the app (Cmd+Q or via menu)
        // The logic has been moved to applicationShouldTerminate
    }
}


@main
struct WebUILauncherApp: App {
    // 2. Register the AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var stateManager = ProcessStateManager()

    init() {
        appDelegate.processManager = stateManager.internalProcessManager
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(stateManager: stateManager)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 500, height: 400)
    }
}
