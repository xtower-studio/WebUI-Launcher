//
//  ContentView.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var stateManager: ProcessStateManager
    
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
    }
}

#Preview {
    ContentView(stateManager: ProcessStateManager())
}
