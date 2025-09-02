//
//  stopped.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import SwiftUI

struct ProcessControlViewStopped: View {
    @ObservedObject var stateManager: ProcessStateManager
    
    // Custom colors to match the UI
    private let brightGreen = Color(red: 0, green: 0.8, blue: 0)
    private let brightRed = Color(red: 1.0, green: 0.1, blue: 0.1)
    private let lightGrayBackground = Color(white: 0.97)
    private let textFieldBackground = Color(white: 0.94)
    private let buttonBackground = Color(white: 0.9)

    // Computed property to get the last few lines of log output
    private var recentLogOutput: String {
        let lines = stateManager.logOutput.components(separatedBy: .newlines)
        let lastLines = Array(lines.suffix(5)) // Show last 5 lines
        return lastLines.joined(separator: "\n")
    }

    var body: some View {
        ZStack {
            // Set the overall background color
            lightGrayBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top section containing status and start button
                HStack(alignment: .top, spacing: 30) {
                    statusView
                    Spacer()
                    startButton
                }

                Spacer(minLength: 20) // Reduced from 50 to 20

                // Bottom section for path configuration
                pathConfigurationView
            }
            .padding(30) // Reduced from 50 to 30
        }
    }

    // MARK: - Subviews

    private var statusView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(" Current status")
                .font(.system(size: 20, weight: .medium, design: .default))
                .foregroundColor(.gray)

            Text("Stopped")
                .font(.system(size: 80, weight: .bold, design: .default))
                .foregroundColor(brightRed)
                .padding(.top, -10) // Adjust spacing to be tighter

            Text(stateManager.logOutput.isEmpty ? "Ready to start WebUI process..." : recentLogOutput)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(.black.opacity(0.65))
                .lineSpacing(4)
                .padding(.top, 30)
                .frame(maxHeight: 100) // Add maximum height constraint instead of fixedSize
                .clipped() // Clip content that exceeds the frame
        }
    }

    private var startButton: some View {
        Button(action: {
            stateManager.startProcess()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Spacer() // Pushes content to the bottom
                Text("Start")
                    .font(.system(size: 48, weight: .bold, design: .default))
                
                Text("Run the Stable Diffusion WebUI process.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(.white)
            .padding(30)
            .frame(width: 280, height: 280, alignment: .bottomLeading)
            .background(brightGreen)
            .cornerRadius(45)
        }
        .buttonStyle(.plain)
    }

    private var pathConfigurationView: some View {
        HStack(spacing: 12) {
            Text(stateManager.webuiPath.isEmpty ? "No path selected" : stateManager.webuiPath)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal, 20)
                .frame(height: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(textFieldBackground)
                .clipShape(Capsule())

            Button(action: {
                stateManager.selectWebuiPath()
            }) {
                Text("Path Configuration")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.horizontal, 25)
                    .frame(height: 50)
                    .background(buttonBackground)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

struct ProcessControlViewStopped_Previews: PreviewProvider {
    static var previews: some View {
        ProcessControlViewStopped(stateManager: ProcessStateManager())
            .frame(width: 1000, height: 600)
    }
}
