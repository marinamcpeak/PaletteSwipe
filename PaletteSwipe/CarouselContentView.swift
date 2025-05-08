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
    
    /// Available difficulty levels
    private let difficulties = [
        PuzzleGenerator.Difficulty.easy,
        PuzzleGenerator.Difficulty.medium,
        PuzzleGenerator.Difficulty.hard
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 2) {
            // Game info header
            if viewModel.isGameActive, let gameState = viewModel.gameState {
                gameInfoHeader(gameState: gameState)
            }
            
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
            
            // Game controls
            gameControls()
            
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
    
    // MARK: - Helper Views
    
    /// Game information header
    private func gameInfoHeader(gameState: GameState) -> some View {
        VStack(spacing: 8) {
            HStack {
                // Time elapsed with real-time updates
                TimeView(gameState: gameState)
                
                Spacer()
                
                // Move counter
                Label("\(gameState.moveCount) moves", systemImage: "arrow.left.and.right")
                    .font(.headline)
            }
            
            // Win message when game is complete
            if gameState.isGameComplete {
                Text("🎉 Puzzle Solved! 🎉")
                    .font(.title2)
                    .foregroundColor(.green)
                    .padding(.vertical, 4)
            }
        }
        .padding(.bottom, 12)
    }
    
    /// Helper view for real-time updating timer
    private struct TimeView: View {
        @ObservedObject var gameState: GameState
        
        var body: some View {
            Label(gameState.formattedTime, systemImage: "clock")
                .font(.headline)
                .monospacedDigit() // Use monospaced digits to prevent jumping
                // Force view to update whenever the time changes
                .id(gameState.elapsedTime)
        }
    }
    
    /// Game control buttons
    private func gameControls() -> some View {
        VStack(spacing: 12) {
            if !viewModel.isGameActive {
                // Start game section when no game is active
                Text("Start a new game")
                    .font(.headline)
                    .padding(.top, 12)
                
                HStack(spacing: 16) {
                    ForEach(difficulties, id: \.self) { difficulty in
                        Button(action: {
                            viewModel.initializeGame(difficulty: difficulty)
                        }) {
                            Text(difficultyName(difficulty))
                                .frame(minWidth: 80)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            } else {
                // Game controls when a game is active
                HStack(spacing: 12) {
                    // New game button
                    Button(action: {
                        showDifficultySheet = true
                    }) {
                        Text("New Game")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    
                    // Reset button
                    Button(action: {
                        resetCurrentGame()
                    }) {
                        Text("Reset")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    // Solution button (for testing)
                    Button(action: {
                        viewModel.applySolution()
                    }) {
                        Text("Solution")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                    .opacity(0.7) // Indicate it's for testing
                }
                .padding(.top, 12)
            }
        }
        .sheet(isPresented: $showDifficultySheet) {
            // Difficulty selection sheet
            VStack(spacing: 20) {
                Text("Select Difficulty")
                    .font(.title)
                    .padding(.top, 20)
                
                ForEach(difficulties, id: \.self) { difficulty in
                    Button(action: {
                        viewModel.initializeGame(difficulty: difficulty)
                        showDifficultySheet = false
                    }) {
                        Text(difficultyName(difficulty))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(difficultyColor(difficulty))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Button("Cancel") {
                    showDifficultySheet = false
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
    
    // MARK: - Private State & Methods
    
    /// State for the difficulty selection sheet
    @State private var showDifficultySheet = false
    
    /// Reset the current game to its initial state
    private func resetCurrentGame() {
        guard let gameState = viewModel.gameState else { return }
        viewModel.initializeGame(difficulty: gameState.difficulty)
    }
    
    /// Get a human-readable name for a difficulty level
    private func difficultyName(_ difficulty: PuzzleGenerator.Difficulty) -> String {
        switch difficulty {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }
    
    /// Get a color for a difficulty level
    private func difficultyColor(_ difficulty: PuzzleGenerator.Difficulty) -> Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .blue
        case .hard:
            return .red
        }
    }
}

#Preview {
    CarouselContentView()
}
