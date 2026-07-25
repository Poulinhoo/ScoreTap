import SwiftUI
import Combine
import WatchKit

// MARK: - Player

enum Player {
    case player
    case opponent

    var label: String {
        switch self {
        case .player:   return "Toi"
        case .opponent: return "Adv"
        }
    }
}

// MARK: - TennisPoint

enum TennisPoint: Int, CaseIterable {
    case zero      = 0
    case fifteen   = 1
    case thirty    = 2
    case forty     = 3
    case advantage = 4

    var display: String {
        switch self {
        case .zero:      return "0"
        case .fifteen:   return "15"
        case .thirty:    return "30"
        case .forty:     return "40"
        case .advantage: return "Avt"
        }
    }

    var next: TennisPoint? {
        TennisPoint(rawValue: rawValue + 1)
    }
}

// MARK: - SetScore

struct SetScore: Identifiable, Equatable {
    let id: UUID
    let playerGames: Int
    let opponentGames: Int
    
    init(id: UUID = UUID(), playerGames: Int, opponentGames: Int) {
        self.id = id
        self.playerGames = playerGames
        self.opponentGames = opponentGames
    }
}

// MARK: - MatchState

enum MatchState: Equatable {
    case playing
    case tiebreak
    case finished(winner: Player)
}

// MARK: - MatchViewModel

final class MatchViewModel: ObservableObject {

    // Current game points
    @Published private(set) var playerPoints: TennisPoint = .zero
    @Published private(set) var opponentPoints: TennisPoint = .zero

    // Games in current set
    @Published private(set) var playerGames: Int = 0
    @Published private(set) var opponentGames: Int = 0

    // Completed sets
    @Published private(set) var completedSets: [SetScore] = []

    // Sets won
    @Published private(set) var playerSets: Int = 0
    @Published private(set) var opponentSets: Int = 0

    // Overall match state
    @Published private(set) var matchState: MatchState = .playing

    // Tiebreak points
    @Published private(set) var tiebreakPlayerPoints: Int = 0
    @Published private(set) var tiebreakOpponentPoints: Int = 0
    @Published private(set) var tiebreakTargetPoints: Int = 7

    // Undo history
    private var history: [Snapshot] = []

    // MARK: - Public API

    func addPoint(to player: Player) {
        saveSnapshot()
        
        switch matchState {
        case .playing:
            resolvePoint(for: player)
        case .tiebreak:
            resolveTiebreakPoint(for: player)
        case .finished:
            break
        }
    }

    func cycleTiebreakTargetPoints() {
        // Can only cycle when tiebreak is at 0-0
        guard tiebreakPlayerPoints == 0 && tiebreakOpponentPoints == 0 else { return }
        
        switch tiebreakTargetPoints {
        case 5:  tiebreakTargetPoints = 7
        case 7:  tiebreakTargetPoints = 10
        case 10: tiebreakTargetPoints = 12
        case 12: tiebreakTargetPoints = 15
        case 15: tiebreakTargetPoints = 20
        default: tiebreakTargetPoints = 5
        }
        WKInterfaceDevice.current().play(.click)
    }

    func undo() {
        guard let snapshot = history.popLast() else { return }
        restore(from: snapshot)
        // Play subtle click on undo
        WKInterfaceDevice.current().play(.click)
    }

    func reset() {
        playerPoints = .zero
        opponentPoints = .zero
        playerGames   = 0
        opponentGames = 0
        completedSets = []
        playerSets    = 0
        opponentSets  = 0
        matchState    = .playing
        tiebreakPlayerPoints = 0
        tiebreakOpponentPoints = 0
        tiebreakTargetPoints = 7
        history       = []
        
        WKInterfaceDevice.current().play(.retry)
    }

    // MARK: - Point resolution

    private func resolvePoint(for scorer: Player) {
        let scorerPoints   = points(for: scorer)
        let receiverPoints = points(for: opponent(of: scorer))

        if scorerPoints == .advantage {
            // Scorer has advantage -> wins game
            winGame(for: scorer)
        } else if receiverPoints == .advantage {
            // Receiver has advantage -> back to deuce (40-40)
            setPoints(.forty, for: opponent(of: scorer))
            WKInterfaceDevice.current().play(.click)
        } else if scorerPoints == .forty {
            if receiverPoints == .forty {
                // Deuce -> scorer gets advantage
                setPoints(.advantage, for: scorer)
                WKInterfaceDevice.current().play(.click)
            } else {
                // Scorer has 40, receiver has < 40 -> wins game
                winGame(for: scorer)
            }
        } else {
            // Normal progression
            if let next = scorerPoints.next {
                setPoints(next, for: scorer)
                WKInterfaceDevice.current().play(.click)
            }
        }
    }

    // MARK: - Game logic

    private func winGame(for winner: Player) {
        resetPoints()
        incrementGames(for: winner)
        
        // Play game win haptic
        WKInterfaceDevice.current().play(.directionUp)
        
        evaluateSetEnd()
    }

    private func evaluateSetEnd() {
        let p = playerGames
        let o = opponentGames

        if p == 6 && o == 6 {
            // Start tiebreak
            matchState = .tiebreak
            WKInterfaceDevice.current().play(.notification)
        } else if p >= 6 && (p - o) >= 2 {
            recordSetWin(for: .player)
        } else if o >= 6 && (o - p) >= 2 {
            recordSetWin(for: .opponent)
        }
    }

    // MARK: - Tiebreak logic

    private func resolveTiebreakPoint(for scorer: Player) {
        if scorer == .player {
            tiebreakPlayerPoints += 1
        } else {
            tiebreakOpponentPoints += 1
        }
        
        WKInterfaceDevice.current().play(.click)
        checkTiebreakWin()
    }

    private func checkTiebreakWin() {
        let p = tiebreakPlayerPoints
        let o = tiebreakOpponentPoints
        let target = tiebreakTargetPoints

        if p >= target && (p - o) >= 2 {
            playerGames = 7
            opponentGames = 6
            recordSetWin(for: .player)
            resetTiebreakPoints()
        } else if o >= target && (o - p) >= 2 {
            playerGames = 6
            opponentGames = 7
            recordSetWin(for: .opponent)
            resetTiebreakPoints()
        }
    }

    private func resetTiebreakPoints() {
        tiebreakPlayerPoints = 0
        tiebreakOpponentPoints = 0
    }

    // MARK: - Set logic

    private func recordSetWin(for winner: Player) {
        completedSets.append(SetScore(playerGames: playerGames, opponentGames: opponentGames))
        playerGames   = 0
        opponentGames = 0

        if winner == .player {
            playerSets += 1
        } else {
            opponentSets += 1
        }

        // Best of 3: first to 2 sets wins
        if playerSets == 2 {
            matchState = .finished(winner: .player)
            WKInterfaceDevice.current().play(.success)
        } else if opponentSets == 2 {
            matchState = .finished(winner: .opponent)
            WKInterfaceDevice.current().play(.success)
        } else {
            matchState = .playing
            WKInterfaceDevice.current().play(.directionUp)
        }
    }

    // MARK: - Helpers: points access

    private func points(for player: Player) -> TennisPoint {
        player == .player ? playerPoints : opponentPoints
    }

    private func setPoints(_ points: TennisPoint, for player: Player) {
        if player == .player {
            playerPoints = points
        } else {
            opponentPoints = points
        }
    }

    private func resetPoints() {
        playerPoints   = .zero
        opponentPoints = .zero
    }

    private func incrementGames(for player: Player) {
        if player == .player {
            playerGames += 1
        } else {
            opponentGames += 1
        }
    }

    private func opponent(of player: Player) -> Player {
        player == .player ? .opponent : .player
    }

    // MARK: - Snapshot (undo)

    private struct Snapshot {
        let playerPoints: TennisPoint
        let opponentPoints: TennisPoint
        let playerGames: Int
        let opponentGames: Int
        let completedSets: [SetScore]
        let playerSets: Int
        let opponentSets: Int
        let matchState: MatchState
        let tiebreakPlayerPoints: Int
        let tiebreakOpponentPoints: Int
        let tiebreakTargetPoints: Int
    }

    private func saveSnapshot() {
        history.append(Snapshot(
            playerPoints:           playerPoints,
            opponentPoints:          opponentPoints,
            playerGames:            playerGames,
            opponentGames:          opponentGames,
            completedSets:          completedSets,
            playerSets:             playerSets,
            opponentSets:           opponentSets,
            matchState:             matchState,
            tiebreakPlayerPoints:   tiebreakPlayerPoints,
            tiebreakOpponentPoints: tiebreakOpponentPoints,
            tiebreakTargetPoints:   tiebreakTargetPoints
        ))
    }

    private func restore(from snapshot: Snapshot) {
        playerPoints           = snapshot.playerPoints
        opponentPoints          = snapshot.opponentPoints
        playerGames            = snapshot.playerGames
        opponentGames          = snapshot.opponentGames
        completedSets          = snapshot.completedSets
        playerSets             = snapshot.playerSets
        opponentSets           = snapshot.opponentSets
        matchState             = snapshot.matchState
        tiebreakPlayerPoints   = snapshot.tiebreakPlayerPoints
        tiebreakOpponentPoints = snapshot.tiebreakOpponentPoints
        tiebreakTargetPoints   = snapshot.tiebreakTargetPoints
    }
}
