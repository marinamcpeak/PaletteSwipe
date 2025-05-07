//
//  MorphingGridSquare.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2025-05-07.
//

import SwiftUI

/// A square that can morph between grid square and overflow square shapes during animation
struct MorphingGridSquare: View {
    // MARK: - Properties
    
    /// The color of the square
    let color: Color
    
    /// Position identifiers
    let row: Int
    let column: Int
    let isOverflow: Bool
    let isHorizontal: Bool // For overflow squares
    
    /// Reference to the view model
    @ObservedObject var viewModel: CarouselViewModel
    
    // Square dimensions
    let squareSize: CGFloat
    let overflowFactor: CGFloat
    
    // MARK: - View Body
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(color)
                .frame(
                    width: calculateWidth(),
                    height: calculateHeight()
                )
                .offset(calculateOffset())
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
        }
        .frame(
            width: isOverflow && isHorizontal ? squareSize : (isOverflow ? squareSize * overflowFactor : squareSize),
            height: isOverflow && !isHorizontal ? squareSize : (isOverflow ? squareSize * overflowFactor : squareSize)
        )
        .gesture(createDragGesture())
    }
    
    // MARK: - Helper Methods
    
    /// Determine if this square can be dragged
    private func canDrag() -> Bool {
        // Main grid outer squares can be dragged
        if !isOverflow && (row == 0 || row == 2 || column == 0 || column == 2) {
            return true
        }
        
        // Overflow squares cannot be dragged directly
        return false
    }
    
    /// Calculate the width based on animation state
    private func calculateWidth() -> CGFloat {
        if isOverflow {
            if isHorizontal {
                // Horizontal overflow (top/bottom) - normal width, reduced height
                return squareSize
            } else {
                // Vertical overflow (left/right) - reduced width, normal height
                
                // Check if we're in the middle of a horizontal row drag
                if (row == 0 || row == 2) && viewModel.rowDragProgress(forRow: row) > 0 {
                    let progress = viewModel.rowDragProgress(forRow: row)
                    let direction = viewModel.rowDragDirection(forRow: row)
                    
                    // If we're on the side that's being dragged toward
                    if (direction == .right && column < 0) || (direction == .left && column > 2) {
                        // Morph from narrow to wide as we drag
                        return squareSize * overflowFactor + (squareSize - squareSize * overflowFactor) * progress
                    }
                }
                
                return squareSize * overflowFactor
            }
        } else {
            // Main grid square - full width
            return squareSize
        }
    }
    
    /// Calculate the height based on animation state
    private func calculateHeight() -> CGFloat {
        if isOverflow {
            if isHorizontal {
                // Horizontal overflow (top/bottom) - normal width, reduced height
                
                // Check if we're in the middle of a vertical column drag
                if (column == 0 || column == 2) && viewModel.columnDragProgress(forColumn: column) > 0 {
                    let progress = viewModel.columnDragProgress(forColumn: column)
                    let direction = viewModel.columnDragDirection(forColumn: column)
                    
                    // If we're on the side that's being dragged toward
                    if (direction == .down && row < 0) || (direction == .up && row > 2) {
                        // Morph from short to tall as we drag
                        return squareSize * overflowFactor + (squareSize - squareSize * overflowFactor) * progress
                    }
                }
                
                return squareSize * overflowFactor
            } else {
                // Vertical overflow (left/right) - reduced width, normal height
                return squareSize
            }
        } else {
            // Main grid square - full height
            return squareSize
        }
    }
    
    /// Calculate the offset based on drag state
    private func calculateOffset() -> CGSize {
        var offset = CGSize.zero
        
        // Handle row drags
        if !isOverflow && (row == 0 || row == 2) && viewModel.activeRowDrag?.row == row {
            let dragAmount = viewModel.activeRowDrag!.dragAmount
            
            // Apply different drag factors based on position
            var dragFactor: CGFloat = 1.0
            
            // Calculate offset for row drags
            offset.width += dragAmount * dragFactor
        }
        
        // Handle column drags
        if !isOverflow && (column == 0 || column == 2) && viewModel.activeColumnDrag?.column == column {
            let dragAmount = viewModel.activeColumnDrag!.dragAmount
            
            // Apply different drag factors based on position
            var dragFactor: CGFloat = 1.0
            
            // Calculate offset for column drags
            offset.height += dragAmount * dragFactor
        }
        
        // Handle overflow drags - when main grid is dragged
        if isOverflow {
            if !isHorizontal && (row == 0 || row == 2) && viewModel.activeRowDrag?.row == row {
                // Left/right overflow during row drag
                let dragAmount = viewModel.activeRowDrag!.dragAmount
                let dragFactor: CGFloat = 0.5 // Overflow moves at half speed
                
                offset.width += dragAmount * dragFactor
            }
            
            if isHorizontal && (column == 0 || column == 2) && viewModel.activeColumnDrag?.column == column {
                // Top/bottom overflow during column drag
                let dragAmount = viewModel.activeColumnDrag!.dragAmount
                let dragFactor: CGFloat = 0.5 // Overflow moves at half speed
                
                offset.height += dragAmount * dragFactor
            }
        }
        
        return offset
    }
    
    /// Create a drag gesture for interactive squares
    private func createDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 1.0)
            .onChanged { value in
                guard canDrag() else { return }
                
                // Determine drag direction
                let translation = value.translation
                
                if abs(translation.width) > abs(translation.height) {
                    // Horizontal drag
                    if row == 0 || row == 2 {
                        viewModel.activeRowDrag = RowDrag(row: row, dragAmount: translation.width)
                    }
                } else {
                    // Vertical drag
                    if column == 0 || column == 2 {
                        viewModel.activeColumnDrag = ColumnDrag(column: column, dragAmount: translation.height)
                    }
                }
            }
            .onEnded { value in
                guard canDrag() else { return }
                
                // Process row drags
                if let activeRowDrag = viewModel.activeRowDrag, activeRowDrag.row == row {
                    let dragAmount = activeRowDrag.dragAmount
                    let threshold = squareSize * viewModel.swipeThreshold
                    
                    if abs(dragAmount) > threshold {
                        // Apply the swipe with animation
                        let direction: SwipeDirection = dragAmount > 0 ? .right : .left
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.applySwipe(atRow: row, column: column, direction: direction)
                            viewModel.activeRowDrag = nil
                        }
                    } else {
                        // Spring back
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            viewModel.activeRowDrag = nil
                        }
                    }
                }
                
                // Process column drags
                if let activeColumnDrag = viewModel.activeColumnDrag, activeColumnDrag.column == column {
                    let dragAmount = activeColumnDrag.dragAmount
                    let threshold = squareSize * viewModel.swipeThreshold
                    
                    if abs(dragAmount) > threshold {
                        // Apply the swipe with animation
                        let direction: SwipeDirection = dragAmount > 0 ? .down : .up
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.applySwipe(atRow: row, column: column, direction: direction)
                            viewModel.activeColumnDrag = nil
                        }
                    } else {
                        // Spring back
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            viewModel.activeColumnDrag = nil
                        }
                    }
                }
            }
    }
}
