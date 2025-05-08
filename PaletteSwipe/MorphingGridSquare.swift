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
                .opacity(calculateOpacity())
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
        // Don't allow dragging during animation
        if viewModel.isProcessingAnimation {
            return false
        }
        
        // Main grid outer squares can be dragged (except center)
        if !isOverflow && (row == 0 || row == 2 || column == 0 || column == 2) && !(row == 1 && column == 1) {
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
                let activeRowDragExists = viewModel.activeRowDrag != nil
                let isRowBeingDragged = activeRowDragExists && viewModel.activeRowDrag!.row == row
                
                if (row == 0 || row == 2) && isRowBeingDragged {
                    let dragAmount = viewModel.activeRowDrag!.dragAmount
                    let progress = min(1.0, abs(dragAmount / squareSize))
                    let direction = dragAmount > 0 ? SwipeDirection.right : SwipeDirection.left
                    
                    // Check for expanding condition
                    let isExpandingLeft = (column == -1) && (direction == .right)
                    let isExpandingRight = (column == 3) && (direction == .left)
                    
                    // Check for compressing condition
                    let isCompressingLeft = (column == -1) && (direction == .left)
                    let isCompressingRight = (column == 3) && (direction == .right)
                    
                    if isExpandingLeft || isExpandingRight {
                        // Expanding - Morph from narrow to wide as we drag in
                        return squareSize * overflowFactor + (squareSize - squareSize * overflowFactor) * progress
                    } else if isCompressingLeft || isCompressingRight {
                        // Compressing - Shrink as we push against it
                        return max(0, squareSize * overflowFactor * (1.0 - progress))
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
                let activeColumnDragExists = viewModel.activeColumnDrag != nil
                let isColumnBeingDragged = activeColumnDragExists && viewModel.activeColumnDrag!.column == column
                
                if (column == 0 || column == 2) && isColumnBeingDragged {
                    let dragAmount = viewModel.activeColumnDrag!.dragAmount
                    let progress = min(1.0, abs(dragAmount / squareSize))
                    let direction = dragAmount > 0 ? SwipeDirection.down : SwipeDirection.up
                    
                    // Check for expanding condition
                    let isExpandingTop = (row == -1) && (direction == .down)
                    let isExpandingBottom = (row == 3) && (direction == .up)
                    
                    // Check for compressing condition
                    let isCompressingTop = (row == -1) && (direction == .up)
                    let isCompressingBottom = (row == 3) && (direction == .down)
                    
                    if isExpandingTop || isExpandingBottom {
                        // Expanding - Morph from short to tall as we drag in
                        return squareSize * overflowFactor + (squareSize - squareSize * overflowFactor) * progress
                    } else if isCompressingTop || isCompressingBottom {
                        // Compressing - Shrink as we push against it
                        return max(0, squareSize * overflowFactor * (1.0 - progress))
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
    
    /// Calculate opacity based on animation state
    private func calculateOpacity() -> Double {
        // Default opacity
        var opacity: Double = 1.0
        
        // Make overflow squares fade as they compress
        if isOverflow {
            if !isHorizontal {
                // Vertical overflow (left/right)
                if let rowDrag = viewModel.activeRowDrag, row == rowDrag.row {
                    let dragAmount = abs(rowDrag.dragAmount)
                    let dragProgress = min(1.0, dragAmount / squareSize)
                    let direction = rowDrag.dragAmount > 0 ? SwipeDirection.right : SwipeDirection.left
                    
                    // Check for compressing condition
                    let isCompressingLeft = (column == -1) && (direction == .left)
                    let isCompressingRight = (column == 3) && (direction == .right)
                    
                    if isCompressingLeft || isCompressingRight {
                        // Fade out overflow square that's being pushed against
                        opacity = max(0.2, 1.0 - dragProgress)
                    }
                }
            } else if isHorizontal {
                // Horizontal overflow (top/bottom)
                if let columnDrag = viewModel.activeColumnDrag, column == columnDrag.column {
                    let dragAmount = abs(columnDrag.dragAmount)
                    let dragProgress = min(1.0, dragAmount / squareSize)
                    let direction = columnDrag.dragAmount > 0 ? SwipeDirection.down : SwipeDirection.up
                    
                    // Check for compressing condition
                    let isCompressingTop = (row == -1) && (direction == .up)
                    let isCompressingBottom = (row == 3) && (direction == .down)
                    
                    if isCompressingTop || isCompressingBottom {
                        // Fade out overflow square that's being pushed against
                        opacity = max(0.2, 1.0 - dragProgress)
                    }
                }
            }
        }
        
        return opacity
    }
    
    /// Calculate the offset based on drag state
    private func calculateOffset() -> CGSize {
        var offset = CGSize.zero
        
        // Handle row drags for main grid squares
        let isInMainGrid = !isOverflow
        let isInOuterRow = row == 0 || row == 2
        let activeRowDragExists = viewModel.activeRowDrag != nil
        let isActiveRowDragForThisRow = activeRowDragExists && viewModel.activeRowDrag!.row == row
        
        if isInMainGrid && isInOuterRow && isActiveRowDragForThisRow {
            let dragAmount = viewModel.activeRowDrag!.dragAmount
            offset.width = dragAmount
        }
        
        // Handle column drags for main grid squares
        let isInOuterColumn = column == 0 || column == 2
        let activeColumnDragExists = viewModel.activeColumnDrag != nil
        let isActiveColumnDragForThisColumn = activeColumnDragExists && viewModel.activeColumnDrag!.column == column
        
        if isInMainGrid && isInOuterColumn && isActiveColumnDragForThisColumn {
            let dragAmount = viewModel.activeColumnDrag!.dragAmount
            offset.height = dragAmount
        }
        
        // Handle overflow drags - when main grid is dragged
        if isOverflow {
            // Handle horizontal overflow during row drags
            let isVerticalOverflow = !isHorizontal
            let isInOuterRow = row == 0 || row == 2
            let isActiveRowDragForThisRow = activeRowDragExists && viewModel.activeRowDrag!.row == row
            
            if isVerticalOverflow && isInOuterRow && isActiveRowDragForThisRow {
                // Only move the overflow square if it's being pulled in, not pushed out
                let dragAmount = viewModel.activeRowDrag!.dragAmount
                let direction = dragAmount > 0 ? SwipeDirection.right : SwipeDirection.left
                
                // Check for condition where we're pulling the square in
                let isPullingInLeft = (column == -1) && (direction == .right)
                let isPullingInRight = (column == 3) && (direction == .left)
                
                // If we're pulling the square in (not pushing out), move it
                if isPullingInLeft || isPullingInRight {
                    offset.width = dragAmount * 0.5 // Half speed for smoother effect
                }
            }
            
            // Handle vertical overflow during column drags
            let isHorizontalOverflow = isHorizontal
            let isInOuterColumn = column == 0 || column == 2
            let isActiveColumnDragForThisColumn = activeColumnDragExists && viewModel.activeColumnDrag!.column == column
            
            if isHorizontalOverflow && isInOuterColumn && isActiveColumnDragForThisColumn {
                // Only move the overflow square if it's being pulled in, not pushed out
                let dragAmount = viewModel.activeColumnDrag!.dragAmount
                let direction = dragAmount > 0 ? SwipeDirection.down : SwipeDirection.up
                
                // Check for condition where we're pulling the square in
                let isPullingInTop = (row == -1) && (direction == .down)
                let isPullingInBottom = (row == 3) && (direction == .up)
                
                // If we're pulling the square in (not pushing out), move it
                if isPullingInTop || isPullingInBottom {
                    offset.height = dragAmount * 0.5 // Half speed for smoother effect
                }
            }
        }
        
        return offset
    }
    
    /// Create a drag gesture for interactive squares
    private func createDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 1.0)
            .onChanged { value in
                guard canDrag() else { return }
                
                // Determine drag direction based on primary movement axis
                let translation = value.translation
                
                // Limit the maximum drag distance to prevent grid distortion
                let maxDragDistance = squareSize * 1.0 // Limit to one square size
                
                if abs(translation.width) > abs(translation.height) {
                    // Horizontal drag - only for top and bottom rows
                    if row == 0 || row == 2 {
                        // Clear any column drag first
                        viewModel.activeColumnDrag = nil
                        
                        // Apply the limited drag amount
                        let limitedDragAmount = max(-maxDragDistance, min(maxDragDistance, translation.width))
                        viewModel.activeRowDrag = RowDrag(row: row, dragAmount: limitedDragAmount)
                    }
                } else {
                    // Vertical drag - only for leftmost and rightmost columns
                    if column == 0 || column == 2 {
                        // Clear any row drag first
                        viewModel.activeRowDrag = nil
                        
                        // Apply the limited drag amount
                        let limitedDragAmount = max(-maxDragDistance, min(maxDragDistance, translation.height))
                        viewModel.activeColumnDrag = ColumnDrag(column: column, dragAmount: limitedDragAmount)
                    }
                }
            }
            .onEnded { value in
                guard canDrag() else { return }
                
                // Handle row drags
                if let activeRowDrag = viewModel.activeRowDrag, activeRowDrag.row == row {
                    // Mark that we're processing an animation
                    viewModel.isProcessingAnimation = true
                    
                    let direction: SwipeDirection = activeRowDrag.dragAmount > 0 ? .right : .left
                    let threshold = squareSize * 0.3 // 30% of square size
                    
                    if abs(activeRowDrag.dragAmount) > threshold {
                        // Apply the swipe with animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.applySwipe(atRow: row, column: column, direction: direction)
                            viewModel.activeRowDrag = nil
                        }
                    } else {
                        // Spring back without applying changes
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            viewModel.activeRowDrag = nil
                        }
                    }
                    
                    // Reset animation state after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.isProcessingAnimation = false
                    }
                }
                
                // Handle column drags
                if let activeColumnDrag = viewModel.activeColumnDrag, activeColumnDrag.column == column {
                    // Mark that we're processing an animation
                    viewModel.isProcessingAnimation = true
                    
                    let direction: SwipeDirection = activeColumnDrag.dragAmount > 0 ? .down : .up
                    let threshold = squareSize * 0.3 // 30% of square size
                    
                    if abs(activeColumnDrag.dragAmount) > threshold {
                        // Apply the swipe with animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.applySwipe(atRow: row, column: column, direction: direction)
                            viewModel.activeColumnDrag = nil
                        }
                    } else {
                        // Spring back without applying changes
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            viewModel.activeColumnDrag = nil
                        }
                    }
                    
                    // Reset animation state after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.isProcessingAnimation = false
                    }
                }
            }
    }
}
