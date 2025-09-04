import SwiftUI

struct ProcessControlViewRunning: View {
    @ObservedObject var stateManager: ProcessStateManager
    
    // Animation state variables
    @State private var isVisible = false
    @State private var stopButtonHovered = false
    @State private var openButtonHovered = false
    @State private var pathButtonHovered = false
    @State private var logUpdateTrigger = false
    @State private var runningTextPulse = false
    @State private var statusIndicatorRotation = 0.0
    @State private var backgroundFloat = false
    @State private var sparkleOffset = false
    @State private var breathingEffect = false
    @State private var textShimmer = false
    @State private var floatingAnimation = false
    @State private var pathFieldFocus = false
    
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
                // Top section containing status and stop button
                HStack(alignment: .top, spacing: 30) {
                    statusView
                        .offset(x: isVisible ? 0 : -100)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.2), value: isVisible)
                    
                    Spacer()
                    
                    stopButton
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
    }

    // MARK: - Animation Functions
    
    private func startContinuousAnimations() {
        // Start all continuous animations with slight delays
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            runningTextPulse = true
            backgroundFloat = true
            floatingAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            breathingEffect = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            textShimmer = true
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
                    .fill(brightGreen)
                    .frame(width: 12, height: 12)
                    .scaleEffect(breathingEffect ? 1.2 : 0.8)
                    .opacity(breathingEffect ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: breathingEffect)
                    .overlay(
                        Circle()
                            .stroke(brightGreen.opacity(0.4), lineWidth: 2)
                            .scaleEffect(runningTextPulse ? 2.0 : 1.0)
                            .opacity(runningTextPulse ? 0 : 0.8)
                            .animation(.easeOut(duration: 2).repeatForever(autoreverses: false), value: runningTextPulse)
                    )
                
                Text("Current status")
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .foregroundColor(.gray)
                    .scaleEffect(isVisible ? 1 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0).delay(0.3), value: isVisible)
            }

            Text("Running")
                .font(.system(size: 80, weight: .bold, design: .default))
                .foregroundColor(brightGreen)
                .padding(.top, -10)
                .padding(.leading, -4) // Move text slightly to the left for better alignment
                .brightness(runningTextPulse ? 0.1 : 0.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: runningTextPulse)
                .overlay(
                    Text("Running")
                        .font(.system(size: 80, weight: .bold, design: .default))
                        .foregroundColor(brightGreen.opacity(0.3))
                        .blur(radius: 8)
                        .padding(.leading, -4) // Apply same alignment to blur overlay
                        .brightness(runningTextPulse ? 0.1 : 0.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: runningTextPulse)
                )
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                    stateManager.openWebUI()
                }
            }) {
                HStack(spacing: 12) {
                    Text("Open")
                        .scaleEffect(openButtonHovered ? 1.1 : 1.0)
                        .offset(x: openButtonHovered ? -5 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: openButtonHovered)
                    
                    Image(systemName: "arrow.up.right.square")
                        .scaleEffect(openButtonHovered ? 1.2 : 1.0)
                        .rotationEffect(.degrees(openButtonHovered ? 15 : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: openButtonHovered)
                }
                .font(.system(size: 22, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.horizontal, 35)
                .padding(.vertical, 15)
                .background(
                    ZStack {
                        Capsule()
                            .fill(brightGreen)
                            .shadow(color: brightGreen.opacity(0.5), radius: openButtonHovered ? 15 : 8, x: 0, y: openButtonHovered ? 6 : 3)
                        
                        // Animated gradient overlay
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(openButtonHovered ? 0.3 : 0.15),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .animation(.easeInOut(duration: 0.3), value: openButtonHovered)
                    }
                )
                .scaleEffect(openButtonHovered ? 1.05 : 1.0)
                .rotationEffect(.degrees(openButtonHovered ? 2 : 0))
                .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: openButtonHovered)
            }
            .padding(.top, 20)
            .buttonStyle(.plain)
            .onHover { hovering in
                openButtonHovered = hovering
            }


            Text(recentLogOutput)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(.black.opacity(0.65))
                .lineSpacing(4)
                .padding(.top, 30)
                .frame(maxHeight: 100)
                .clipped()
                .opacity(logUpdateTrigger ? 1 : 0.8)
                .scaleEffect(logUpdateTrigger ? 1 : 0.98)
                .offset(x: logUpdateTrigger ? 0 : -5)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: logUpdateTrigger)
                .onChange(of: stateManager.logOutput) {
                    startLogUpdateAnimation()
                }
        }
    }

    private var stopButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                stateManager.stopProcess()
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                HStack {
                    Text("Stop")
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .scaleEffect(stopButtonHovered ? 1.1 : 1.0)
                        .offset(x: stopButtonHovered ? -5 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: stopButtonHovered)
                    
                    if stopButtonHovered {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                            .rotationEffect(.degrees(statusIndicatorRotation))
                            .scaleEffect(stopButtonHovered ? 1.0 : 0.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: stopButtonHovered)
                    }
                }
                
                Text("Terminate the running Stable Diffusion WebUI process.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(stopButtonHovered ? 1.0 : 0.8)
                    .offset(x: stopButtonHovered ? 5 : 0)
                    .animation(.easeInOut(duration: 0.2), value: stopButtonHovered)
            }
            .foregroundColor(.white)
            .padding(30)
            .frame(width: 280, height: 280, alignment: .bottomLeading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 45)
                        .fill(brightRed)
                        .shadow(color: brightRed.opacity(0.5), radius: stopButtonHovered ? 20 : 10, x: 0, y: stopButtonHovered ? 8 : 4)
                    
                    // Animated gradient overlay
                    RoundedRectangle(cornerRadius: 45)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(stopButtonHovered ? 0.2 : 0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .animation(.easeInOut(duration: 0.3), value: stopButtonHovered)
                }
            )
            .scaleEffect(stopButtonHovered ? 1.02 : 1.0)
            .rotationEffect(.degrees(stopButtonHovered ? -1 : 0))
            .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: stopButtonHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            stopButtonHovered = hovering
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
                    stateManager.selectWebuiPath()
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
}

// MARK: - Preview

struct ProcessControlViewRunning_Previews: PreviewProvider {
    static var previews: some View {
        ProcessControlViewRunning(stateManager: ProcessStateManager())
            .frame(width: 1000, height: 600)
    }
}
