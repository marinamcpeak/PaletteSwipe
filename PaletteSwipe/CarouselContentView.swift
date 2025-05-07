//
//  CarouselContentView.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2025-05-07.
//

import SwiftUI

/// A content view that implements a carousel-like puzzle with morphing squares
struct CarouselContentView: View {
    // MARK: - Properties
    
    /// The view model that manages the grid state and animations
    @StateObject private var viewModel = CarouselViewModel()
    
    /// The size of the main square in the grid
    private let mainSquareSize: CGFloat = 50
    
    /// The factor by which the overflow areas are smaller than the main squares
    private let overflowFactor: CGFloat = 0.2
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 2) {
            // Top overflow area
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    MorphingGridSquare(
                        color: viewModel.topOverflow[index],
                        row: -1,  // Position identifier (-1 means top overflow)
                        column: index,
                        isOverflow: true,
                        isHorizontal: true,
                        viewModel: viewModel,
                        squareSize: mainSquareSize,
                        overflowFactor: overflowFactor
                    )
                }
            }
            
            // Main grid area with left/right overflows
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 2) {
                    // Left overflow for the current row
                    MorphingGridSquare(
                        color: viewModel.leftOverflow[row],
                        row: row,
                        column: -1,  // Position identifier (-1 means left overflow)
                        isOverflow: true,
                        isHorizontal: false,
                        viewModel: viewModel,
                        squareSize: mainSquareSize,
                        overflowFactor: overflowFactor
                    )
                    
                    // Grid squares
                    ForEach(0..<3, id: \.self) { column in
                        MorphingGridSquare(
                            color: viewModel.gridColors[row][column],
                            row: row,
                            column: column,
                            isOverflow: false,
                            isHorizontal: false,
                            viewModel: viewModel,
                            squareSize: mainSquareSize,
                            overflowFactor: overflowFactor
                        )
                    }
                    
                    // Right overflow for the current row
                    MorphingGridSquare(
                        color: viewModel.rightOverflow[row],
                        row: row,
                        column: 3,  // Position identifier (3 means right overflow)
                        isOverflow: true,
                        isHorizontal: false,
                        viewModel: viewModel,
                        squareSize: mainSquareSize,
                        overflowFactor: overflowFactor
                    )
                }
            }
            
            // Bottom overflow area
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    MorphingGridSquare(
                        color: viewModel.bottomOverflow[index],
                        row: 3,  // Position identifier (3 means bottom overflow)
                        column: index,
                        isOverflow: true,
                        isHorizontal: true,
                        viewModel: viewModel,
                        squareSize: mainSquareSize,
                        overflowFactor: overflowFactor
                    )
                }
            }
            
            // Debug information - only visible in debug builds
            #if DEBUG
            VStack(alignment: .leading, spacing: 4) {
                Text("Drag status:")
                if let rowDrag = viewModel.activeRowDrag {
                    Text("Row \(rowDrag.row) drag: \(rowDrag.dragAmount, specifier: "%.1f")")
                } else if let colDrag = viewModel.activeColumnDrag {
                    Text("Column \(colDrag.column) drag: \(colDrag.dragAmount, specifier: "%.1f")")
                } else {
                    Text("No active drag")
                }
            }
            .font(.system(size: 10))
            .foregroundColor(.gray)
            .padding(.top, 10)
            #endif
        }
        .padding()
    }
}

#Preview {
    CarouselContentView()
}
