//
//  settings.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import SwiftUI

struct ProcessControlViewSettings: View {
    @ObservedObject var stateManager: ProcessStateManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("WebUI Launcher Setup")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Please select the WebUI script file to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Configuration Section
            VStack(spacing: 16) {
                HStack {
                    Text("WebUI Script Path:")
                        .font(.headline)
                    Spacer()
                }
                
                HStack {
                    Text(stateManager.webuiPath.isEmpty ? "No file selected" : stateManager.webuiPath)
                        .font(.body)
                        .foregroundColor(stateManager.webuiPath.isEmpty ? .secondary : .primary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("Browse...") {
                        stateManager.selectWebuiPath()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("Instructions:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. Click 'Browse...' to select your webui.sh script")
                    Text("2. The app will automatically start the WebUI after selection")
                    Text("3. Your selection will be saved for future launches")
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ProcessControlViewSettings(stateManager: ProcessStateManager())
        .frame(width: 750, height: 430)
}