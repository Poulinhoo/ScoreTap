import SwiftUI

// MARK: - MatchView

struct MatchView: View {

    @StateObject private var vm = MatchViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 8) {
            switch vm.matchState {
            case .playing:
                MiniScoreboardView(
                    completedSets: vm.completedSets,
                    playerGames: vm.playerGames,
                    opponentGames: vm.opponentGames,
                    playerSets: vm.playerSets,
                    opponentSets: vm.opponentSets
                )
                
                HStack(spacing: 8) {
                    TapZone(
                        label: Player.player.label,
                        score: vm.playerPoints.display,
                        gradient: LinearGradient(
                            colors: [Color.blue, Color(red: 0.1, green: 0.35, blue: 0.85)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    ) {
                        vm.addPoint(to: .player)
                    }

                    TapZone(
                        label: Player.opponent.label,
                        score: vm.opponentPoints.display,
                        gradient: LinearGradient(
                            colors: [Color(white: 0.25), Color(white: 0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    ) {
                        vm.addPoint(to: .opponent)
                    }
                }
                .frame(maxHeight: .infinity)
                
            case .tiebreak:
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(.caption2))
                            .foregroundStyle(.orange)
                        Text("TIEBREAK")
                            .font(.system(.caption2, design: .rounded))
                            .bold()
                            .foregroundStyle(.orange)
                        
                        Spacer()
                        
                        if vm.tiebreakPlayerPoints == 0 && vm.tiebreakOpponentPoints == 0 {
                            Button(action: vm.cycleTiebreakTargetPoints) {
                                HStack(spacing: 2) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(.caption2))
                                    Text("\(vm.tiebreakTargetPoints) pts")
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
                            Text("\(vm.tiebreakTargetPoints) pts")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    MiniScoreboardView(
                        completedSets: vm.completedSets,
                        playerGames: vm.playerGames,
                        opponentGames: vm.opponentGames,
                        playerSets: vm.playerSets,
                        opponentSets: vm.opponentSets
                    )
                }
                
                HStack(spacing: 8) {
                    TapZone(
                        label: Player.player.label,
                        score: "\(vm.tiebreakPlayerPoints)",
                        gradient: LinearGradient(
                            colors: [Color.orange, Color(red: 0.85, green: 0.45, blue: 0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    ) {
                        vm.addPoint(to: .player)
                    }

                    TapZone(
                        label: Player.opponent.label,
                        score: "\(vm.tiebreakOpponentPoints)",
                        gradient: LinearGradient(
                            colors: [Color(white: 0.25), Color(white: 0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    ) {
                        vm.addPoint(to: .opponent)
                    }
                }
                .frame(maxHeight: .infinity)

            case .finished(let winner):
                MatchFinishedView(winner: winner, onRematch: vm.reset, onQuit: { dismiss() })
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 2)
        .navigationTitle(vm.matchState == .tiebreak ? "Tiebreak" : "Match")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: vm.undo) {
                    Image(systemName: "arrow.uturn.backward")
                }
            }
        }
    }
}

// MARK: - MiniScoreboardView

private struct MiniScoreboardView: View {
    let completedSets: [SetScore]
    let playerGames: Int
    let opponentGames: Int
    let playerSets: Int
    let opponentSets: Int

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                HStack(spacing: 2) {
                    Text("Sets:")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text("\(playerSets) - \(opponentSets)")
                        .font(.system(.caption2, design: .rounded))
                        .bold()
                        .foregroundStyle(.yellow)
                }
                
                Spacer()
                
                if !completedSets.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(completedSets.indices, id: \.self) { idx in
                            Text("\(completedSets[idx].playerGames)-\(completedSets[idx].opponentGames)")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.white.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }
            .padding(.horizontal, 6)
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            HStack {
                Text("Jeux:")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(playerGames)")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundStyle(.blue)
                
                Text("–")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Text("\(opponentGames)")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 6)
        }
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - TapZone

private struct TapZone: View {
    let label: String
    let score: String
    let gradient: LinearGradient
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(.caption2, design: .rounded))
                    .bold()
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(score)
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

// MARK: - MatchFinishedView

struct MatchFinishedView: View {
    let winner: Player
    let onRematch: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.title2)
                .foregroundStyle(.yellow)
                .padding(.top, 4)

            Text(winner == .player ? "Victoire !" : "Adversaire gagne !")
                .font(.system(.headline, design: .rounded))
                .multilineTextAlignment(.center)

            VStack(spacing: 6) {
                Button(action: onRematch) {
                    Text("Rejouer")
                        .font(.system(.footnote, design: .rounded))
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.green.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Button(action: onQuit) {
                    Text("Quitter")
                        .font(.system(.footnote, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.red.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MatchView()
    }
}
