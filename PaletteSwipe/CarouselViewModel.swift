//
//  CarouselViewModel.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2025-05-07.
//

import SwiftUI
import Combine

/// Struct representing an active row drag
struct RowDrag {
    let row: Int
    var dragAmount: CGFloat
}

/// Struct representing an active column drag
struct ColumnDrag {
    let column: Int
    var dragAmount: CGFloat
}

/// ViewModel for a fluid carousel-like puzzle animation
class CarouselViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var gridColors: [[Color]] =
        [[.blue, .blue, .blue],
         [.blue, .blue, .blue],
         [.blue, .blue, .blue]]
    @Published var topOverflow: [Color] = [.purple, .purple, .purple]
    @Published var bottomOverflow: [Color] = [.green, .green, .green]
    @Published var leftOverflow: [Color] = [.yellow, .yellow, .yellow]
    @Published var rightOverflow: [Color] = [.red, .red, .red]
    
    // Drag state - only one can be active at a time
    @Published var activeRowDrag: RowDrag? = nil
    @Published var activeColumnDrag: ColumnDrag? = nil
    
    // Is the view model currently processing an animation?
    @Published var isProcessingAnimation = false
    
    // Game-related properties
    @Published var gameState: GameState?
    @Published var isGameActive: Bool = false
    
    // Solution state for testing
    private var solutionState: PuzzleState?
    
    // Square size and animation configuration
    let squareSize: CGFloat = 50.0
    let overflowFactor: CGFloat = 0.2
    
    // MARK: - Animation Constants
    
    // The progress threshold at which a drag becomes a swipe (0.0-1.0)
    let swipeThreshold: CGFloat = 0.3
    
    // MARK: - Game Integration
    
    /// Initialize a new game with the specified difficulty
    func initializeGame(difficulty: PuzzleGenerator.Difficulty = .medium) {
        // Generate a new puzzle with standard colors
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        let generator = PuzzleGenerator(colors: colors)
        let (puzzle, solution) = generator.generatePuzzle(difficulty: difficulty)
        
        // Store the solution for testing
        self.solutionState = solution
        
        // Create game state
        gameState = GameState(difficulty: difficulty)
        isGameActive = true
        
        // Apply the generated puzzle to our grid
        gridColors = puzzle.gridColors
        topOverflow = puzzle.topOverflow
        bottomOverflow = puzzle.bottomOverflow
        leftOverflow = puzzle.leftOverflow
        rightOverflow = puzzle.rightOverflow
    }
    
    /// Register a completed move with the game state
    func registerMove() {
        gameState?.registerMove()
        
        // Check if the move completes the game
        checkWinCondition()
    }
    
    /// Check if the current state represents a win
    func checkWinCondition() {
        gameState?.checkWinCondition(
            grid: gridColors,
            topOverflow: topOverflow,
            leftOverflow: leftOverflow,
            rightOverflow: rightOverflow,
            bottomOverflow: bottomOverflow
        )
    }
    
    /// Apply the solution for testing purposes
    func applySolution() {
        guard let solution = solutionState else { return }
        
        // Apply the solution state with animation
        withAnimation(.easeInOut(duration: 0.5)) {
            gridColors = solution.gridColors
            topOverflow = solution.topOverflow
            bottomOverflow = solution.bottomOverflow
            leftOverflow = solution.leftOverflow
            rightOverflow = solution.rightOverflow
        }
        
        // Check win condition after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.checkWinCondition()
        }
    }
    
    // MARK: - Swipe Methods
    
    /// Apply a swipe in the specified direction
    func applySwipe(atRow row: Int, column: Int, direction: SwipeDirection) {
        switch (row, column, direction) {
        case (0, _, .right): swipeTopRowRight()
        case (0, _, .left): swipeTopRowLeft()
        case (2, _, .right): swipeBottomRowRight()
        case (2, _, .left): swipeBottomRowLeft()
        case (_, 0, .down): swipeLeftColumnDown()
        case (_, 0, .up): swipeLeftColumnUp()
        case (_, 2, .down): swipeRightColumnDown()
        case (_, 2, .up): swipeRightColumnUp()
        default: break // Ignore other combinations
        }
        
        // Register the move with game state if a game is active
        if isGameActive {
            registerMove()
        }
    }
    
    // MARK: - Helper Functions for Grid Updates
    
    private func swipeTopRowRight() {
        let lastMain = gridColors[0].removeLast()
        gridColors[0].insert(leftOverflow[0], at: 0)
        leftOverflow[0] = rightOverflow[0]
        rightOverflow[0] = lastMain
    }
    
    private func swipeTopRowLeft() {
        let firstMain = gridColors[0].removeFirst()
        gridColors[0].append(rightOverflow[0])
        rightOverflow[0] = leftOverflow[0]
        leftOverflow[0] = firstMain
    }
    
    private func swipeBottomRowRight() {
        let lastMain = gridColors[2].removeLast()
        gridColors[2].insert(leftOverflow[2], at: 0)
        leftOverflow[2] = rightOverflow[2]
        rightOverflow[2] = lastMain
    }
    
    private func swipeBottomRowLeft() {
        let firstMain = gridColors[2].removeFirst()
        gridColors[2].append(rightOverflow[2])
        rightOverflow[2] = leftOverflow[2]
        leftOverflow[2] = firstMain
    }
    
    private func swipeLeftColumnDown() {
        var leftColumn = gridColors.map { $0[0] }
        let lastMain = leftColumn.removeLast()
        leftColumn.insert(topOverflow[0], at: 0)
        topOverflow[0] = bottomOverflow[0]
        bottomOverflow[0] = lastMain
        for i in 0..<gridColors.count {
            gridColors[i][0] = leftColumn[i]
        }
    }
    
    private func swipeLeftColumnUp() {
        var leftColumn = gridColors.map { $0[0] }
        let firstMain = leftColumn.removeFirst()
        leftColumn.append(bottomOverflow[0])
        bottomOverflow[0] = topOverflow[0]
        topOverflow[0] = firstMain
        for i in 0..<gridColors.count {
            gridColors[i][0] = leftColumn[i]
        }
    }
    
    private func swipeRightColumnDown() {
        var rightColumn = gridColors.map { $0[2] }
        let lastMain = rightColumn.removeLast()
        rightColumn.insert(topOverflow[2], at: 0)
        topOverflow[2] = bottomOverflow[2]
        bottomOverflow[2] = lastMain
        for i in 0..<gridColors.count {
            gridColors[i][2] = rightColumn[i]
        }
    }
    
    private func swipeRightColumnUp() {
        var rightColumn = gridColors.map { $0[2] }
        let firstMain = rightColumn.removeFirst()
        rightColumn.append(bottomOverflow[2])
        bottomOverflow[2] = topOverflow[2]
        topOverflow[2] = firstMain
        for i in 0..<gridColors.count {
            gridColors[i][2] = rightColumn[i]
        }
    }
    
    // MARK: - Animation Calculation Helpers
    
    /// Calculate the dragging progress for a row (0.0 to 1.0)
    func rowDragProgress(forRow row: Int) -> CGFloat {
        guard let activeRowDrag = activeRowDrag, activeRowDrag.row == row else {
            return 0.0
        }
        
        return min(1.0, abs(activeRowDrag.dragAmount / squareSize))
    }
    
    /// Calculate the dragging progress for a column (0.0 to 1.0)
    func columnDragProgress(forColumn column: Int) -> CGFloat {
        guard let activeColumnDrag = activeColumnDrag, activeColumnDrag.column == column else {
            return 0.0
        }
        
        return min(1.0, abs(activeColumnDrag.dragAmount / squareSize))
    }
    
    /// Get the drag direction for a row
    func rowDragDirection(forRow row: Int) -> SwipeDirection? {
        guard let activeRowDrag = activeRowDrag, activeRowDrag.row == row else {
            return nil
        }
        
        return activeRowDrag.dragAmount > 0 ? .right : .left
    }
    
    /// Get the drag direction for a column
    func columnDragDirection(forColumn column: Int) -> SwipeDirection? {
        guard let activeColumnDrag = activeColumnDrag, activeColumnDrag.column == column else {
            return nil
        }
        
        return activeColumnDrag.dragAmount > 0 ? .down : .up
    }
}
