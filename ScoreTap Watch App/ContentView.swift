import SwiftUI

// MARK: - ContentView (Home screen)

struct ContentView: View {

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                // App Logo and Titles
                VStack(spacing: 2) {
                    Image(systemName: "sportscourt.fill")
                        .font(.system(.title3))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.8, green: 0.98, blue: 0), .green],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("ScoreTap")
                        .font(.system(.headline, design: .rounded))
                        .bold()
                        .foregroundStyle(.white)
                    
                    Text("Tennis & Padel")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)

                Spacer(minLength: 4)

                // Menu Links
                VStack(spacing: 8) {
                    NavigationLink(destination: MatchView()) {
                        HStack {
                            Image(systemName: "tennisball.fill")
                                .foregroundStyle(.white)
                            Text("Mode Match")
                                .bold()
                        }
                        .font(.system(.footnote, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color(red: 0.1, green: 0.35, blue: 0.85)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1.5)
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: StandaloneTiebreakView()) {
                        HStack {
                            Image(systemName: "numbersign")
                                .foregroundStyle(.white)
                            Text("Mode Tiebreak")
                                .bold()
                        }
                        .font(.system(.footnote, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color(red: 0.85, green: 0.45, blue: 0.05)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1.5)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
