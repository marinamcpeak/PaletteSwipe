//
//  PuzzleGenerator.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2025-05-08.
//

import SwiftUI

/// Generates puzzles for the Colour Sudoku + Rubik's cube game
class PuzzleGenerator {
    /// Difficulty levels for the puzzles
    enum Difficulty {
        case easy
        case medium
        case hard
        
        var scrambleMoves: Int {
            switch self {
            case .easy: return 5
            case .medium: return 10
            case .hard: return 15
            }
        }
    }
    
    /// The set of colors used in the puzzle
    private let puzzleColors: [Color]
    
    /// Initialize with a set of colors
    init(colors: [Color]) {
        self.puzzleColors = colors
    }
    
    /// Generate a new puzzle with the specified difficulty
    func generatePuzzle(difficulty: Difficulty) -> (puzzle: PuzzleState, solution: PuzzleState) {
        // Generate a solution first
        let solution = generateSolution()
        
        // Create a copy to scramble
        var puzzleState = solution
        
        // Scramble the puzzle by applying random moves
        scramble(state: &puzzleState, moves: difficulty.scrambleMoves)
        
        return (puzzleState, solution)
    }
    
    /// Generate a solution for a puzzle - returns the solved state
    func generateSolution() -> PuzzleState {
        // Generate a valid solved grid
        let solutionGrid = generateSolvedGrid()
        
        // Create a solution state
        let solutionState = PuzzleState(
            gridColors: solutionGrid,
            topOverflow: solutionGrid[0],
            bottomOverflow: solutionGrid[2],
            leftOverflow: [solutionGrid[0][0], solutionGrid[1][0], solutionGrid[2][0]],
            rightOverflow: [solutionGrid[0][2], solutionGrid[1][2], solutionGrid[2][2]]
        )
        
        // Set fixed center positions
        var solution = solutionState
        setFixedCenterPositions(state: &solution)
        
        return solution
    }
    
    /// Set fixed center positions in the puzzle
    private func setFixedCenterPositions(state: inout PuzzleState) {
        // The center positions are already consistent in the Latin square pattern
        // No additional adjustments needed for the 3x3 Sudoku case
    }
    
    /// Generate a solved grid (Latin square for 3x3)
    private func generateSolvedGrid() -> [[Color]] {
        // Basic 3x3 Latin square pattern
        // Using the first 3 colors from the palette
        let colors = Array(puzzleColors.prefix(3))
        
        return [
            [colors[0], colors[1], colors[2]],
            [colors[1], colors[2], colors[0]],
            [colors[2], colors[0], colors[1]]
        ]
    }
    
    /// Scramble the puzzle with random moves
    private func scramble(state: inout PuzzleState, moves: Int) {
        // Keep track of the last move to avoid immediate reversals
        var lastMove: (row: Int, column: Int, direction: SwipeDirection)? = nil
        
        for _ in 0..<moves {
            // Generate a random move that isn't the reverse of the last move
            var move: (row: Int, column: Int, direction: SwipeDirection)
            
            repeat {
                move = randomMove()
            } while isReverse(move, of: lastMove)
            
            // Apply the move
            applyMove(to: &state, row: move.row, column: move.column, direction: move.direction)
            lastMove = move
        }
    }
    
    /// Generate a random move - making sure to only use movable positions
    func randomMove() -> (row: Int, column: Int, direction: SwipeDirection) {
        // Only include valid movable positions (outer rows and columns, except center)
        let positions = [
            // Top row
            (row: 0, column: 0, direction: SwipeDirection.right),
            (row: 0, column: 0, direction: SwipeDirection.left),
            
            // Bottom row
            (row: 2, column: 0, direction: SwipeDirection.right),
            (row: 2, column: 0, direction: SwipeDirection.left),
            
            // Left column
            (row: 0, column: 0, direction: SwipeDirection.down),
            (row: 0, column: 0, direction: SwipeDirection.up),
            
            // Right column
            (row: 0, column: 2, direction: SwipeDirection.down),
            (row: 0, column: 2, direction: SwipeDirection.up)
        ]
        
        return positions.randomElement()!
    }
    
    /// Check if a move is the reverse of another move
    private func isReverse(
        _ move: (row: Int, column: Int, direction: SwipeDirection)?,
        of previousMove: (row: Int, column: Int, direction: SwipeDirection)?
    ) -> Bool {
        guard let move = move, let previousMove = previousMove else {
            return false
        }
        
        // Check if the moves are on the same row/column
        let sameRow = move.row == previousMove.row
        let sameColumn = move.column == previousMove.column
        
        // Check if the directions are opposites
        let oppositeDirections = (move.direction == .left && previousMove.direction == .right) ||
                                (move.direction == .right && previousMove.direction == .left) ||
                                (move.direction == .up && previousMove.direction == .down) ||
                                (move.direction == .down && previousMove.direction == .up)
        
        return sameRow && sameColumn && oppositeDirections
    }
    
    /// Apply a move to a puzzle state
    func applyMove(
        to state: inout PuzzleState,
        row: Int,
        column: Int,
        direction: SwipeDirection
    ) {
        switch (row, column, direction) {
        case (0, _, .right): swipeTopRowRight(state: &state)
        case (0, _, .left): swipeTopRowLeft(state: &state)
        case (2, _, .right): swipeBottomRowRight(state: &state)
        case (2, _, .left): swipeBottomRowLeft(state: &state)
        case (_, 0, .down): swipeLeftColumnDown(state: &state)
        case (_, 0, .up): swipeLeftColumnUp(state: &state)
        case (_, 2, .down): swipeRightColumnDown(state: &state)
        case (_, 2, .up): swipeRightColumnUp(state: &state)
        default: break
        }
    }
    
    // Movement functions - similar to your current implementation
    private func swipeTopRowRight(state: inout PuzzleState) {
        let lastMain = state.gridColors[0].removeLast()
        state.gridColors[0].insert(state.leftOverflow[0], at: 0)
        state.leftOverflow[0] = state.rightOverflow[0]
        state.rightOverflow[0] = lastMain
    }
    
    private func swipeTopRowLeft(state: inout PuzzleState) {
        let firstMain = state.gridColors[0].removeFirst()
        state.gridColors[0].append(state.rightOverflow[0])
        state.rightOverflow[0] = state.leftOverflow[0]
        state.leftOverflow[0] = firstMain
    }
    
    private func swipeBottomRowRight(state: inout PuzzleState) {
        let lastMain = state.gridColors[2].removeLast()
        state.gridColors[2].insert(state.leftOverflow[2], at: 0)
        state.leftOverflow[2] = state.rightOverflow[2]
        state.rightOverflow[2] = lastMain
    }
    
    private func swipeBottomRowLeft(state: inout PuzzleState) {
        let firstMain = state.gridColors[2].removeFirst()
        state.gridColors[2].append(state.rightOverflow[2])
        state.rightOverflow[2] = state.leftOverflow[2]
        state.leftOverflow[2] = firstMain
    }
    
    private func swipeLeftColumnDown(state: inout PuzzleState) {
        var leftColumn = state.gridColors.map { $0[0] }
        let lastMain = leftColumn.removeLast()
        leftColumn.insert(state.topOverflow[0], at: 0)
        state.topOverflow[0] = state.bottomOverflow[0]
        state.bottomOverflow[0] = lastMain
        for i in 0..<state.gridColors.count {
            state.gridColors[i][0] = leftColumn[i]
        }
    }
    
    private func swipeLeftColumnUp(state: inout PuzzleState) {
        var leftColumn = state.gridColors.map { $0[0] }
        let firstMain = leftColumn.removeFirst()
        leftColumn.append(state.bottomOverflow[0])
        state.bottomOverflow[0] = state.topOverflow[0]
        state.topOverflow[0] = firstMain
        for i in 0..<state.gridColors.count {
            state.gridColors[i][0] = leftColumn[i]
        }
    }
    
    private func swipeRightColumnDown(state: inout PuzzleState) {
        var rightColumn = state.gridColors.map { $0[2] }
        let lastMain = rightColumn.removeLast()
        rightColumn.insert(state.topOverflow[2], at: 0)
        state.topOverflow[2] = state.bottomOverflow[2]
        state.bottomOverflow[2] = lastMain
        for i in 0..<state.gridColors.count {
            state.gridColors[i][2] = rightColumn[i]
        }
    }
    
    private func swipeRightColumnUp(state: inout PuzzleState) {
        var rightColumn = state.gridColors.map { $0[2] }
        let firstMain = rightColumn.removeFirst()
        rightColumn.append(state.bottomOverflow[2])
        state.bottomOverflow[2] = state.topOverflow[2]
        state.topOverflow[2] = firstMain
        for i in 0..<state.gridColors.count {
            state.gridColors[i][2] = rightColumn[i]
        }
    }
}

/// Structure to hold the puzzle state
struct PuzzleState {
    var gridColors: [[Color]]
    var topOverflow: [Color]
    var bottomOverflow: [Color]
    var leftOverflow: [Color]
    var rightOverflow: [Color]
}
