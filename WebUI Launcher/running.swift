//
//  running.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import SwiftUI

struct ProcessControlViewRunning: View {
    @ObservedObject var stateManager: ProcessStateManager
    
    // Custom colors to match the UI
    private let brightGreen = Color(red: 0.1, green: 0.85, blue: 0.1)
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
                // Top section containing status and stop button
                HStack(alignment: .top, spacing: 30) {
                    statusView
                    Spacer()
                    stopButton
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

            Text("Running")
                .font(.system(size: 80, weight: .bold, design: .default))
                .foregroundColor(brightGreen)
                .padding(.top, -10) // Adjust spacing to be tighter

            Button(action: {
                stateManager.openWebUI()
            }) {
                HStack(spacing: 12) {
                    Text("Open")
                    Image(systemName: "arrow.up.right.square")
                }
                .font(.system(size: 22, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.horizontal, 35)
                .padding(.vertical, 15)
                .background(brightGreen)
                .clipShape(Capsule())
            }
            .padding(.top, 20)
            .buttonStyle(.plain)

            Text(recentLogOutput)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(.black.opacity(0.65))
                .lineSpacing(4)
                .padding(.top, 30)
                .frame(maxHeight: 100) // Add maximum height constraint instead of fixedSize
                .clipped() // Clip content that exceeds the frame
        }
    }

    private var stopButton: some View {
        Button(action: {
            stateManager.stopProcess()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Spacer() // Pushes content to the bottom
                Text("Stop")
                    .font(.system(size: 48, weight: .bold, design: .default))
                
                Text("Terminate the currently running Stable Diffusion WebUI process.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(.white)
            .padding(30)
            .frame(width: 280, height: 280, alignment: .bottomLeading)
            .background(brightRed)
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

struct ProcessControlViewRunning_Previews: PreviewProvider {
    static var previews: some View {
        ProcessControlViewRunning(stateManager: ProcessStateManager())
            .frame(width: 1000, height: 600)
    }
}
