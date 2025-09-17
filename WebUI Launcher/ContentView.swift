//
//  ContentView.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var stateManager = ProcessStateManager()

    var body: some View {
        VStack(spacing: 15) {
            Text("WebUI Launcher")
                .font(.largeTitle)
                .padding(.top, 20)

            HStack {
                TextField("Path to stable-diffusion-webui folder", text: $stateManager.webuiPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(true)
                Button("Select Folder...") {
                    selectFolder()
                }
            }
            .padding(.horizontal)

            // Show different views based on process state
            Group {
                switch stateManager.currentState {
                case .needsConfiguration:
                    Button("Select WebUI Folder to Start") {
                        selectFolder()
                    }
                    .padding()
                case .stopped:
                    ProcessControlViewStopped(stateManager: stateManager)
                case .starting:
                    ProcessControlViewStarting(stateManager: stateManager)
                case .running:
                    ProcessControlViewRunning(stateManager: stateManager)
                case .error(let message):
                    VStack {
                        Text("Error: \(message)").foregroundColor(.red)
                        Button("Retry") {
                            stateManager.currentState = .stopped
                        }
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 750, minHeight: 430)
        .onAppear {
            // On launch, try to resolve the saved bookmark and set the path if needed
            if let bookmarkPath = BookmarkManager.resolveBookmark(), stateManager.webuiPath.isEmpty {
                stateManager.webuiPath = bookmarkPath
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { _ in
            stateManager.internalProcessManager.stopScript()
        }
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            BookmarkManager.saveBookmark(for: url)
            stateManager.webuiPath = url.path
        }
    }
}

#Preview {
    ContentView()
}
