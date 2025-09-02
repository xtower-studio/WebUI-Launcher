//
//  ProcessStateManager.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import SwiftUI
import Combine
import AppKit
import UniformTypeIdentifiers

enum ProcessState {
    case stopped
    case starting
    case running
    case error(String) // Add error state
}

class ProcessStateManager: ObservableObject {
    @Published var currentState: ProcessState = .stopped
    @Published var webuiPath: String = "" {
        didSet {
            // Auto-save to UserDefaults when path changes
            UserDefaults.standard.set(webuiPath, forKey: "webuiPath")
        }
    }
    @Published var logOutput: String = ""
    
    private let processManager = ProcessManager()
    private var cancellables = Set<AnyCancellable>()
    private var startupTimer: Timer?
    private var startupStartTime: Date?
    private let startupTimeoutDuration: TimeInterval = 10 * 60 // 10 minutes
    
    // Access to internal ProcessManager for AppDelegate
    var internalProcessManager: ProcessManager {
        return processManager
    }
    
    init() {
        // Load saved path from UserDefaults
        webuiPath = UserDefaults.standard.string(forKey: "webuiPath") ?? ""
        setupBindings()
    }
    
    private func setupBindings() {
        // Monitor ProcessManager's isRunning state to update our current state
        processManager.$isRunning
            .sink { [weak self] isRunning in
                if !isRunning {
                    // Process stopped - clear any timers and reset state
                    self?.clearStartupTimer()
                    if case .starting = self?.currentState {
                        // If we were starting but process stopped, it's an error
                        self?.currentState = .error("Process terminated unexpectedly during startup")
                    } else if case .running = self?.currentState {
                        // Normal stop from running state
                        self?.currentState = .stopped
                    }
                }
            }
            .store(in: &cancellables)
        
        // Forward output from ProcessManager and check for startup completion
        processManager.$output
            .sink { [weak self] output in
                self?.logOutput = output
                
                // Check if the WebUI has finished starting based on log output
                if case .starting = self?.currentState {
                    self?.checkForStartupCompletion(in: output)
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkForStartupCompletion(in output: String) {
        // More comprehensive startup detection patterns
        let startupPatterns = [
            "Running on local URL",
            "Use --listen",
            "localhost:7860",
            "startup time:",
            "Model loaded",
            "Startup time:",
            "App started successfully",
            "Server running on",
            "Running on http://",
            "WebUI started"
        ]
        
        for pattern in startupPatterns {
            if output.lowercased().contains(pattern.lowercased()) {
                DispatchQueue.main.async {
                    self.clearStartupTimer()
                    self.currentState = .running
                }
                return
            }
        }
    }
    
    private func startStartupTimer() {
        clearStartupTimer()
        startupStartTime = Date()
        
        startupTimer = Timer.scheduledTimer(withTimeInterval: startupTimeoutDuration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                if case .starting = self?.currentState {
                    self?.currentState = .error("Startup timeout: No startup completion detected after 10 minutes")
                    self?.processManager.stopScript()
                }
                self?.clearStartupTimer()
            }
        }
    }
    
    private func clearStartupTimer() {
        startupTimer?.invalidate()
        startupTimer = nil
        startupStartTime = nil
    }
    
    // MARK: - Actions
    
    func startProcess() {
        guard !webuiPath.isEmpty else { return }
        currentState = .starting
        startStartupTimer()
        processManager.runScript(at: webuiPath)
    }
    
    func stopProcess() {
        clearStartupTimer()
        processManager.stopScript()
        currentState = .stopped
    }
    
    func resetFromError() {
        clearStartupTimer()
        currentState = .stopped
    }
    
    func selectWebuiPath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.unixExecutable, .shellScript]
        panel.title = "Select WebUI Script"
        panel.message = "Choose the webui.sh script for Stable Diffusion WebUI"
        
        if panel.runModal() == .OK, let url = panel.url {
            webuiPath = url.path
        }
    }
    
    func openWebUI() {
        // Extract URL from log output instead of using hardcoded URL
        let extractedURL = extractURLFromLog()
        if let url = URL(string: extractedURL) {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func extractURLFromLog() -> String {
        // Default fallback URL
        let fallbackURL = "http://localhost:7860"
        
        // Look for the pattern "Running on local URL: http://..." in the log
        let lines = logOutput.components(separatedBy: .newlines)
        
        for line in lines {
            // Check for the specific pattern mentioned in the requirements
            if line.contains("Running on local URL:") {
                // Extract the URL part after "Running on local URL:"
                let components = line.components(separatedBy: "Running on local URL:")
                if components.count > 1 {
                    let urlPart = components[1].trimmingCharacters(in: .whitespaces)
                    // Extract just the URL (in case there's additional text after)
                    let urlComponents = urlPart.components(separatedBy: .whitespaces)
                    if let firstComponent = urlComponents.first, !firstComponent.isEmpty {
                        return firstComponent
                    }
                }
            }
            
            // Also check for other common patterns as fallbacks
            if line.contains("Running on http://") {
                if let range = line.range(of: "http://") {
                    let urlPart = String(line[range.lowerBound...])
                    let urlComponents = urlPart.components(separatedBy: .whitespaces)
                    if let firstComponent = urlComponents.first, !firstComponent.isEmpty {
                        return firstComponent
                    }
                }
            }
        }
        
        return fallbackURL
    }
}

// Use proper UTType for shell scripts
extension UTType {
    static let shellScript: UTType = {
        if let type = UTType(filenameExtension: "sh") {
            return type
        }
        return UTType.plainText // fallback
    }()
}
