import SwiftUI
import WatchKit

// MARK: - TiebreakViewModel

final class TiebreakViewModel: ObservableObject {

    @Published private(set) var playerPoints: Int = 0
    @Published private(set) var opponentPoints: Int = 0
    @Published private(set) var targetPoints: Int = 7
    @Published private(set) var winner: Player? = nil
    @Published private(set) var canUndo: Bool = false
    private let initialServer: Player = .player

    /// Called when someone wins the tiebreak (injected by MatchViewModel)
    var onFinish: ((Player) -> Void)?

    private var history: [(Int, Int, Int)] = []

    // MARK: - Serve

    var currentServer: Player {
        let pointNumber = playerPoints + opponentPoints + 1
        guard pointNumber > 1 else { return initialServer }
        let group = (pointNumber - 2) / 2
        return group % 2 == 0 ? opponent(of: initialServer) : initialServer
    }

    private func opponent(of player: Player) -> Player {
        player == .player ? .opponent : .player
    }

    // MARK: - Public API

    func addPoint(to player: Player) {
        guard winner == nil else { return }
        saveSnapshot()

        if player == .player {
            playerPoints += 1
        } else {
            opponentPoints += 1
        }

        WKInterfaceDevice.current().play(.click)
        checkWin()
        canUndo = true
    }

    func cycleTargetPoints() {
        // Can only cycle when score is 0-0
        guard playerPoints == 0 && opponentPoints == 0 else { return }
        
        switch targetPoints {
        case 5:  targetPoints = 7
        case 7:  targetPoints = 10
        case 10: targetPoints = 12
        case 12: targetPoints = 15
        case 15: targetPoints = 20
        default: targetPoints = 5
        }
        WKInterfaceDevice.current().play(.click)
    }

    func undo() {
        guard let last = history.popLast() else { return }
        playerPoints   = last.0
        opponentPoints = last.1
        targetPoints   = last.2
        winner         = nil
        canUndo        = !history.isEmpty
        WKInterfaceDevice.current().play(.click)
    }

    func reset() {
        playerPoints   = 0
        opponentPoints = 0
        winner         = nil
        history        = []
        canUndo        = false
        WKInterfaceDevice.current().play(.retry)
    }

    // MARK: - Win check

    /// First to targetPoints with a 2-point lead wins
    private func checkWin() {
        if playerPoints >= targetPoints && (playerPoints - opponentPoints) >= 2 {
            winner = .player
            WKInterfaceDevice.current().play(.success)
            onFinish?(.player)
        } else if opponentPoints >= targetPoints && (opponentPoints - playerPoints) >= 2 {
            winner = .opponent
            WKInterfaceDevice.current().play(.success)
            onFinish?(.opponent)
        }
    }

    // MARK: - Snapshot

    private func saveSnapshot() {
        history.append((playerPoints, opponentPoints, targetPoints))
    }
}
