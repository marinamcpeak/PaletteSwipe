//
//  PuzzleViewModel.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2023-11-02.
//

import SwiftUI

/// ViewModel for the puzzle. Manages the state of the grid and processes swipe gestures.
class PuzzleViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var gridColors: [[Color]] =
        [[.blue, .blue, .blue],
         [.blue, .blue, .blue],
         [.blue, .blue, .blue]]
    @Published var topOverflow: [Color] = [.purple, .purple, .purple]
    @Published var bottomOverflow: [Color] = [.green, .green, .green]
    @Published var leftOverflow: [Color] = [.yellow, .yellow, .yellow]
    @Published var rightOverflow: [Color] = [.red, .red, .red]
    
    // MARK: - Swipe Methods
    
    /// Responds to a swipe gesture on a grid square.
    /// - Parameters:
    ///   - row: The row index of the swiped square.
    ///   - column: The column index of the swiped square.
    ///   - direction: The direction of the swipe.
    func swipe(atRow row: Int, column: Int, direction: SwipeDirection) {
        // Guard against invalid swipe attempts on non-swipeable areas
        guard (row == 0 || row == 2 || column == 0 || column == 2) else { return }
        
        switch (row, column, direction) {
        case (0, _, .right): swipeTopRowRight()
        case (0, _, .left): swipeTopRowLeft()
        case (2, _, .right): swipeBottomRowRight()
        case (2, _, .left): swipeBottomRowLeft()
        case (_, 0, .down): swipeLeftColumnDown()
        case (_, 0, .up): swipeLeftColumnUp()
        case (_, 2, .down): swipeRightColumnDown()
        case (_, 2, .up): swipeRightColumnUp()
        default: break // Ignore other combinations as they are not valid swipe actions.
        }
    }
    
    // MARK: - Helper Functions
    
    // Swipe helper methods. Each method handles the logic for a swipe
    // in a specific direction and updates the grid accordingly.
    
    private func swipeTopRowRight() {
        let lastMain = gridColors[0].removeLast()
        gridColors[0].insert(leftOverflow.removeFirst(), at: 0)
        leftOverflow.insert(rightOverflow.removeFirst(), at: 0)
        rightOverflow.insert(lastMain, at: 0)
    }
    
    private func swipeTopRowLeft() {
        let firstMain = gridColors[0].removeFirst()
        gridColors[0].append(rightOverflow.removeFirst())
        rightOverflow.insert(leftOverflow.removeFirst(), at: 0)
        leftOverflow.insert(firstMain, at: 0)
    }
    
    private func swipeBottomRowRight() {
        let lastMain = gridColors[2].removeLast()
        gridColors[2].insert(leftOverflow.removeLast(), at: 0)
        leftOverflow.insert(rightOverflow.removeLast(), at: 2)
        rightOverflow.insert(lastMain, at: 2)
    }
    
    private func swipeBottomRowLeft() {
        let firstMain = gridColors[2].removeFirst()
        gridColors[2].append(rightOverflow.removeLast())
        rightOverflow.insert(leftOverflow.removeLast(), at: 2)
        leftOverflow.insert(firstMain, at: 2)
    }
    
    private func swipeLeftColumnDown() {
        var leftColumn = gridColors.map { $0[0] }
        let lastMain = leftColumn.removeLast()
        leftColumn.insert(topOverflow.removeFirst(), at: 0)
        topOverflow.insert(bottomOverflow.removeFirst(), at: 0)
        bottomOverflow.insert(lastMain, at: 0)
        for i in 0..<gridColors.count {
            gridColors[i][0] = leftColumn[i]
        }
    }
    
    private func swipeLeftColumnUp() {
        var leftColumn = gridColors.map { $0[0] }
        let firstMain = leftColumn.removeFirst()
        leftColumn.append(bottomOverflow.removeFirst())
        bottomOverflow.insert(topOverflow.removeFirst(), at: 0)
        topOverflow.insert(firstMain, at: 0)
        for i in 0..<gridColors.count {
            gridColors[i][0] = leftColumn[i]
        }
    }
    
    private func swipeRightColumnDown() {
        var rightColumn = gridColors.map { $0[2] }
        let lastMain = rightColumn.removeLast()
        rightColumn.insert(topOverflow.removeLast(), at: 0)
        topOverflow.insert(bottomOverflow.removeLast(), at: 2)
        bottomOverflow.insert(lastMain, at: 2)
        for i in 0..<gridColors.count {
            gridColors[i][2] = rightColumn[i]
        }
    }
    
    private func swipeRightColumnUp() {
        var rightColumn = gridColors.map { $0[2] }
        let firstMain = rightColumn.removeFirst()
        rightColumn.append(bottomOverflow.removeLast())
        bottomOverflow.insert(topOverflow.removeLast(), at: 2)
        topOverflow.insert(firstMain, at: 2)
        for i in 0..<gridColors.count {
            gridColors[i][2] = rightColumn[i]
        }
    }
}
