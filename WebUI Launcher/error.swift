//
//  error.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import SwiftUI

struct ProcessControlViewError: View {
    @ObservedObject var stateManager: ProcessStateManager
    let errorMessage: String
    
    // Custom colors to match the UI
    private let brightRed = Color(red: 1.0, green: 0.1, blue: 0.1)
    private let mediumGray = Color.gray
    private let lightGrayBackground = Color(white: 0.97)
    private let textFieldBackground = Color(white: 0.94)
    private let buttonBackground = Color(white: 0.9)

    // Computed property to get the last few lines of log output
    private var recentLogOutput: String {
        let lines = stateManager.logOutput.components(separatedBy: .newlines)
        let lastLines = Array(lines.suffix(8)) // Show more lines for error diagnosis
        return lastLines.joined(separator: "\n")
    }

    var body: some View {
        ZStack {
            // Set the overall background color
            lightGrayBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top section containing only the status view
                HStack(alignment: .top) {
                    statusView
                    Spacer() // Pushes the status view to the left
                }

                Spacer(minLength: 20)

                // Bottom section for path configuration
                pathConfigurationView
            }
            .padding(30)
        }
    }

    // MARK: - Subviews

    private var statusView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(" Current status")
                .font(.system(size: 20, weight: .medium, design: .default))
                .foregroundColor(.gray)

            Text("Error")
                .font(.system(size: 80, weight: .bold, design: .default))
                .foregroundColor(brightRed)
                .padding(.top, -10)

            // Error message
            Text(errorMessage)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(brightRed)
                .padding(.top, 10)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button(action: {
                    stateManager.resetFromError()
                }) {
                    HStack(spacing: 12) {
                        Text("Reset")
                        Image(systemName: "arrow.clockwise")
                    }
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(mediumGray)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: {
                    stateManager.resetFromError()
                    stateManager.startProcess()
                }) {
                    HStack(spacing: 12) {
                        Text("Retry")
                        Image(systemName: "play.circle")
                    }
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(brightRed)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 20)

            // Log output for debugging
            Text(recentLogOutput)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(.black.opacity(0.65))
                .lineSpacing(4)
                .padding(.top, 30)
                .frame(maxHeight: 120)
                .clipped()
        }
    }

    private var pathConfigurationView: some View {
        HStack(spacing: 12) {
            TextField("Enter path here", text: $stateManager.webuiPath)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal, 20)
                .frame(height: 50)
                .background(textFieldBackground)
                .clipShape(Capsule())
                .textFieldStyle(.plain)

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

#Preview {
    ProcessControlViewError(
        stateManager: ProcessStateManager(),
        errorMessage: "Startup timeout: No startup completion detected after 10 minutes"
    )
}