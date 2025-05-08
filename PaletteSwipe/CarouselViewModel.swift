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
    
    // Square size and animation configuration
    let squareSize: CGFloat = 50.0
    let overflowFactor: CGFloat = 0.2
    
    // MARK: - Animation Constants
    
    // The progress threshold at which a drag becomes a swipe (0.0-1.0)
    let swipeThreshold: CGFloat = 0.3
    
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
    }
    
    // MARK: - Helper Functions for Grid Updates
    
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
