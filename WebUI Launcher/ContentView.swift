//
//  ContentView.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var stateManager = ProcessStateManager()
    
    var body: some View {
        Group {
            switch stateManager.currentState {
            case .needsConfiguration:
                ProcessControlViewSettings(stateManager: stateManager)
            case .stopped:
                ProcessControlViewStopped(stateManager: stateManager)
            case .starting:
                ProcessControlViewStarting(stateManager: stateManager)
            case .running:
                ProcessControlViewRunning(stateManager: stateManager)
            case .error(let errorMessage):
                ProcessControlViewError(stateManager: stateManager, errorMessage: errorMessage)
            }
        }
        .frame(minWidth: 750, minHeight: 430) // Enforce minimum window size
        .onAppear {
            // Setup AppDelegate connection for proper cleanup
            if let delegate = NSApplication.shared.delegate as? AppDelegate {
                delegate.processManager = stateManager.internalProcessManager
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
            // Handle window close - stop the process before window closes
            print("Window is closing, stopping script...")
            stateManager.stopProcess()
        }
    }
}

#Preview {
    ContentView()
}
