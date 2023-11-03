//
//  ContentView.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2023-11-02.
//

import SwiftUI

/// The ContentView that displays the interactive grid for the puzzle.
struct ContentView: View {
    // MARK: - Properties
    
    /// The view model object that manages the puzzle logic.
    @StateObject private var viewModel = PuzzleViewModel()
    
    /// The size of the main square in the grid.
    private let mainSquareSize: CGFloat = 50
    
    /// The factor by which the overflow areas are smaller than the main squares.
    private let overflowFactor: CGFloat = 0.2
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            // Top overflow area.
            HStack(spacing: 2) {
                ForEach(viewModel.topOverflow, id: \.self) { color in
                    Rectangle().fill(color)
                        .frame(width: mainSquareSize, height: mainSquareSize * overflowFactor)
                }
            }
            
            // Main grid area.
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 2) {
                    // Left overflow for the current row.
                    Rectangle().fill(viewModel.leftOverflow[row])
                        .frame(width: mainSquareSize * overflowFactor, height: mainSquareSize)

                    // Grid squares.
                    ForEach(0..<3, id: \.self) { column in
                        // Gestures enabled only for outer squares.
                        if row != 1 && column != 1 {
                            GridSquare(color: viewModel.gridColors[row][column], action: { direction in
                                viewModel.swipe(atRow: row, column: column, direction: direction)
                            })
                            .frame(width: mainSquareSize, height: mainSquareSize)
                        } else {
                            // Central squares are static.
                            Rectangle().fill(viewModel.gridColors[row][column])
                                .frame(width: mainSquareSize, height: mainSquareSize)
                        }
                    }
                    
                    // Right overflow for the current row.
                    Rectangle().fill(viewModel.rightOverflow[row])
                        .frame(width: mainSquareSize * overflowFactor, height: mainSquareSize)
                }
            }
            
            // Bottom overflow area.
            HStack(spacing: 2) {
                ForEach(viewModel.bottomOverflow, id: \.self) { color in
                    Rectangle().fill(color)
                        .frame(width: mainSquareSize, height: mainSquareSize * overflowFactor)
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
