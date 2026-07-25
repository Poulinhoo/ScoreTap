import SwiftUI

// MARK: - TiebreakView
// Used both as an embedded overlay in MatchView (with injected vm)
// and as a standalone screen from ContentView.

struct TiebreakView: View {

    @ObservedObject var vm: TiebreakViewModel

    var body: some View {
        VStack(spacing: 8) {
            if let winner = vm.winner {
                tiebreakWinnerView(winner: winner)
            } else {
                scoringLayout
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 2)
        .navigationTitle("Tiebreak")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: vm.undo) {
                    Image(systemName: "arrow.uturn.backward")
                }
            }
        }
    }

    // MARK: - Scoring layout

    private var scoringLayout: some View {
        VStack(spacing: 6) {
            HStack {
                if vm.playerPoints == 0 && vm.opponentPoints == 0 {
                    Button(action: vm.cycleTargetPoints) {
                        HStack(spacing: 3) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(.caption2))
                            Text("Cible: \(vm.targetPoints) pts")
                                .font(.system(.caption2, design: .rounded))
                                .bold()
                        }
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Cible: \(vm.targetPoints) pts")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(vm.playerPoints) – \(vm.opponentPoints)")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 8) {
                TiebreakTapZone(
                    label: Player.player.label,
                    score: vm.playerPoints,
                    gradient: LinearGradient(
                        colors: [Color.orange, Color(red: 0.85, green: 0.45, blue: 0.05)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                ) {
                    vm.addPoint(to: .player)
                }

                TiebreakTapZone(
                    label: Player.opponent.label,
                    score: vm.opponentPoints,
                    gradient: LinearGradient(
                        colors: [Color(white: 0.25), Color(white: 0.15)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                ) {
                    vm.addPoint(to: .opponent)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }

    // MARK: - Winner banner

    private func tiebreakWinnerView(winner: Player) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "flag.checkered")
                .font(.title2)
                .foregroundStyle(.yellow)
                .padding(.top, 4)

            Text(winner == .player ? "Victoire !" : "Adversaire gagne !")
                .font(.system(.headline, design: .rounded))
                .multilineTextAlignment(.center)

            Button(action: vm.reset) {
                Text("Rejouer")
                    .font(.system(.footnote, design: .rounded))
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
}

// MARK: - TiebreakTapZone

private struct TiebreakTapZone: View {
    let label: String
    let score: Int
    let gradient: LinearGradient
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(.caption2, design: .rounded))
                    .bold()
                    .foregroundStyle(.white.opacity(0.8))
                Text("\(score)")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - StandaloneTiebreakView

struct StandaloneTiebreakView: View {

    @StateObject private var vm = TiebreakViewModel()

    var body: some View {
        TiebreakView(vm: vm)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StandaloneTiebreakView()
    }
}
