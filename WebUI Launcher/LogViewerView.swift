import SwiftUI

struct LogViewerView: View {
    let logText: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Full Log Output")
                    .font(.title2.bold())
                    .padding()
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .padding()
            }
            Divider()
            ScrollView {
                Text(logText)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}
