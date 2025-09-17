//
//  stopped.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import SwiftUI

struct ProcessControlViewStopped: View {
    @ObservedObject var stateManager: ProcessStateManager
    
    // Animation state variables
    @State private var isVisible = false
    @State private var startButtonHovered = false
    @State private var pathButtonHovered = false
    // State for log viewer modal
    @State private var showLogViewer = false
    @State private var logUpdateTrigger = false
    @State private var stoppedTextPulse = false
    @State private var statusIndicatorRotation = 0.0
    @State private var backgroundFloat = false
    @State private var sparkleOffset = false
    @State private var breathingEffect = false
    @State private var floatingAnimation = false
    @State private var pathFieldFocus = false
    
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
            // Animated background with floating effect
            lightGrayBackground.ignoresSafeArea()
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(backgroundFloat ? 1.005 : 1.0)
                .animation(.easeInOut(duration: 0.8), value: isVisible)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: backgroundFloat)
            
            // Subtle background gradient overlay
            LinearGradient(
                colors: [
                    brightGreen.opacity(0.02),
                    Color.clear,
                    brightGreen.opacity(0.01)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 1.2).delay(0.5), value: isVisible)

            VStack(spacing: 0) {
                // Top section containing status and start button
                HStack(alignment: .top, spacing: 30) {
                    statusView
                        .offset(x: isVisible ? 0 : -100)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.2), value: isVisible)
                    Spacer()
                    startButton
                        .offset(x: isVisible ? 0 : 100)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.4), value: isVisible)
                }

                Spacer(minLength: 20)

                // Bottom section for path configuration
                pathConfigurationView
                    .opacity(isVisible ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.6), value: isVisible)
            }
            .padding(30)
        }
        .onAppear {
            isVisible = true
            startContinuousAnimations()
            startLogUpdateAnimation()
        }
        // Sheet for full log viewer
        .sheet(isPresented: $showLogViewer) {
            LogViewerView(logText: stateManager.logOutput)
        }
    }

    // MARK: - Animation Functions
    
    private func startContinuousAnimations() {
        // Start all continuous animations with slight delays
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            stoppedTextPulse = true
            backgroundFloat = true
            floatingAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            breathingEffect = true
        }
        
        // Start rotating status indicator
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            statusIndicatorRotation = 360
        }
        
        // Start sparkle animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(1.0)) {
            sparkleOffset = true
        }
    }
    
    private func startLogUpdateAnimation() {
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                logUpdateTrigger.toggle()
            }
        }
    }

    // MARK: - Subviews

    private var statusView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                // Animated status indicator
                Circle()
                    .fill(brightRed)
                    .frame(width: 12, height: 12)
                    .scaleEffect(breathingEffect ? 1.2 : 0.8)
                    .opacity(breathingEffect ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: breathingEffect)
                    .overlay(
                        Circle()
                            .stroke(brightRed.opacity(0.4), lineWidth: 2)
                            .scaleEffect(stoppedTextPulse ? 2.0 : 1.0)
                            .opacity(stoppedTextPulse ? 0 : 0.8)
                            .animation(.easeOut(duration: 2).repeatForever(autoreverses: false), value: stoppedTextPulse)
                    )
                
                Text("Current status")
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .foregroundColor(.gray)
                    .scaleEffect(isVisible ? 1 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0).delay(0.3), value: isVisible)
            }

            Text("Stopped")
                .font(.system(size: 80, weight: .bold, design: .default))
                .foregroundColor(brightRed)
                .padding(.top, -10)
                .padding(.leading, -4) // Move text slightly to the left for better alignment
                .brightness(stoppedTextPulse ? 0.1 : 0.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: stoppedTextPulse)
                .overlay(
                    Text("Stopped")
                        .font(.system(size: 80, weight: .bold, design: .default))
                        .foregroundColor(brightRed.opacity(0.3))
                        .blur(radius: 8)
                        .padding(.leading, -4) // Apply same alignment to blur overlay
                        .brightness(stoppedTextPulse ? 0.1 : 0.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: stoppedTextPulse)
                )

            Button(action: {
                showLogViewer = true
            }) {
                Text(stateManager.logOutput.isEmpty ? "Ready to start WebUI process..." : recentLogOutput)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundColor(.black.opacity(0.65))
                    .lineSpacing(4)
                    .padding(.top, 30)
                    .frame(maxHeight: 100)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.001)) // Ensure tappable area
                    .contentShape(Rectangle())
                    .clipped()
                    .opacity(logUpdateTrigger ? 1 : 0.8)
                    .scaleEffect(logUpdateTrigger ? 1 : 0.98)
                    .offset(x: logUpdateTrigger ? 0 : -5)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: logUpdateTrigger)
            }
            .buttonStyle(.plain)
            .onChange(of: stateManager.logOutput) {
                startLogUpdateAnimation()
            }
        }
    }

    private var startButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                stateManager.startProcess()
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                HStack {
                    Text("Start")
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .scaleEffect(startButtonHovered ? 1.1 : 1.0)
                        .offset(x: startButtonHovered ? -5 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: startButtonHovered)
                    
                    if startButtonHovered {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                            .rotationEffect(.degrees(statusIndicatorRotation))
                            .scaleEffect(startButtonHovered ? 1.0 : 0.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: startButtonHovered)
                    }
                }
                
                Text("Run the Stable Diffusion WebUI process.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(startButtonHovered ? 1.0 : 0.8)
                    .offset(x: startButtonHovered ? 5 : 0)
                    .animation(.easeInOut(duration: 0.2), value: startButtonHovered)
            }
            .foregroundColor(.white)
            .padding(30)
            .frame(width: 280, height: 280, alignment: .bottomLeading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 45)
                        .fill(brightGreen)
                        .shadow(color: brightGreen.opacity(0.5), radius: startButtonHovered ? 20 : 10, x: 0, y: startButtonHovered ? 8 : 4)
                    
                    // Animated gradient overlay
                    RoundedRectangle(cornerRadius: 45)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(startButtonHovered ? 0.2 : 0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .animation(.easeInOut(duration: 0.3), value: startButtonHovered)
                }
            )
            .scaleEffect(startButtonHovered ? 1.02 : 1.0)
            .rotationEffect(.degrees(startButtonHovered ? 1 : 0))
            .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: startButtonHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            startButtonHovered = hovering
        }
    }

    private var pathConfigurationView: some View {
        HStack(spacing: 12) {
            Text(stateManager.webuiPath.isEmpty ? "No path selected" : stateManager.webuiPath)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal, 20)
                .frame(height: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Capsule()
                        .fill(textFieldBackground)
                        .overlay(
                            Capsule()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
                .scaleEffect(isVisible ? 1 : 0.9)
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0).delay(0.7), value: isVisible)

            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                    selectFolder()
                }
            }) {
                HStack(spacing: 8) {
                    Text("Path Configuration")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Image(systemName: "folder.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.black.opacity(0.6))
                        .rotationEffect(.degrees(pathButtonHovered ? 180 : 0))
                        .scaleEffect(pathButtonHovered ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: pathButtonHovered)
                }
                .padding(.horizontal, 25)
                .frame(height: 50)
                .background(
                    ZStack {
                        Capsule()
                            .fill(buttonBackground)
                        
                        // Shimmer effect
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(pathButtonHovered ? 0.4 : 0.0),
                                        Color.white.opacity(pathButtonHovered ? 0.1 : 0.0),
                                        Color.white.opacity(pathButtonHovered ? 0.4 : 0.0)
                                    ],
                                    startPoint: sparkleOffset ? .leading : .trailing,
                                    endPoint: sparkleOffset ? .trailing : .leading
                                )
                            )
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: sparkleOffset)
                    }
                )
                .scaleEffect(pathButtonHovered ? 1.03 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: pathButtonHovered)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                pathButtonHovered = hovering
            }
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

// MARK: - Preview

struct ProcessControlViewStopped_Previews: PreviewProvider {
    static var previews: some View {
        ProcessControlViewStopped(stateManager: ProcessStateManager())
            .frame(width: 1000, height: 600)
    }
}
