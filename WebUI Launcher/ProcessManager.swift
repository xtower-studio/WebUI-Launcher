//
//  ProcessManager.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import Foundation
import Combine

class ProcessManager: ObservableObject {
    @Published var isRunning = false
    @Published var output: String = ""

    private var process: Process?
    private var outputPipe = Pipe()

    func runScript(at path: String) {
        guard !isRunning else {
            print("Process is already running.")
            return
        }

        // The script needs to be run from its directory
        let scriptURL = URL(fileURLWithPath: path)
        let directoryURL = scriptURL.deletingLastPathComponent()

        // Ensure the script is executable
        // In a real app, you might want to handle this more gracefully
        // For example: `chmod +x /path/to/your/webui.sh`
        
        process = Process()
        process?.executableURL = URL(fileURLWithPath: "/bin/sh")
        process?.arguments = [scriptURL.lastPathComponent]
        process?.currentDirectoryURL = directoryURL

        // Capture output
        outputPipe = Pipe()
        process?.standardOutput = outputPipe
        process?.standardError = outputPipe

        // Use a background thread to read the output
        let fileHandle = outputPipe.fileHandleForReading
        fileHandle.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let newOutput = String(data: data, encoding: .utf8), !newOutput.isEmpty {
                DispatchQueue.main.async {
                    self?.output += newOutput
                }
            }
        }

        // Termination handler
        process?.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isRunning = false
                self?.output += "\n--- Process Terminated ---\n"
                // Clean up the handler
                self?.outputPipe.fileHandleForReading.readabilityHandler = nil
            }
        }

        do {
            output = "--- Starting WebUI Process ---\n"
            try process?.run()
            isRunning = true
        } catch {
            output = "Error starting process: \(error.localizedDescription)"
            isRunning = false
        }
    }

    func stopScript() {
        guard isRunning, let process = process else {
            print("Process is not running or doesn't exist.")
            return
        }
        
        print("Terminating process...")
        process.terminate() // Sends SIGTERM signal
        self.process = nil
    }
}
