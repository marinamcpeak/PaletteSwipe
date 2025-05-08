//
//  GameState.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2025-05-08.
//

import SwiftUI
import Combine

/// Manages game state and progress tracking
class GameState: ObservableObject {
    // MARK: - Game Progress
    @Published var moveCount: Int = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var isGameComplete: Bool = false
    
    // Timer publisher for real-time display
    private var timerCancellable: AnyCancellable?
    private var startTime: Date?
    
    // Current difficulty
    private(set) var difficulty: PuzzleGenerator.Difficulty
    
    // MARK: - Initialization
    
    init(difficulty: PuzzleGenerator.Difficulty = .medium) {
        self.difficulty = difficulty
        startTimer()
    }
    
    deinit {
        timerCancellable?.cancel()
    }
    
    // MARK: - Methods
    
    /// Start a new game
    func startNewGame(difficulty: PuzzleGenerator.Difficulty) {
        // Reset game state
        moveCount = 0
        elapsedTime = 0
        isGameComplete = false
        self.difficulty = difficulty
        
        // Restart timer
        startTimer()
    }
    
    /// Register a valid move
    func registerMove() {
        moveCount += 1
    }
    
    /// Check if the current state is a winning state
    func checkWinCondition(
        grid: [[Color]],
        topOverflow: [Color],
        leftOverflow: [Color],
        rightOverflow: [Color],
        bottomOverflow: [Color]
    ) {
        // Check win condition using the rules
        let isWin = GameRules.isWinningState(
            grid: grid,
            topOverflow: topOverflow,
            leftOverflow: leftOverflow,
            rightOverflow: rightOverflow,
            bottomOverflow: bottomOverflow
        )
        
        if isWin {
            isGameComplete = true
            timerCancellable?.cancel()
            timerCancellable = nil
        }
    }
    
    /// Start the game timer using Combine for more reliable real-time updates
    private func startTimer() {
        timerCancellable?.cancel()
        startTime = Date()
        
        // Create a publisher that emits values at regular intervals on the main thread
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let startTime = self.startTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
    }
    
    /// Format elapsed time as a string
    var formattedTime: String {
        let totalSeconds = Int(elapsedTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let tenths = Int((elapsedTime - Double(totalSeconds)) * 10)
        
        return String(format: "%02d:%02d.%01d", minutes, seconds, tenths)
    }
}
