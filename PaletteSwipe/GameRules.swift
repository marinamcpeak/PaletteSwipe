//
//  GameRules.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2025-05-08.
//

import Foundation
import SwiftUI

/// Defines the rules for the combination Colour Sudoku + Rubik's cube game
struct GameRules {
    /// Validates if a given grid state satisfies Sudoku rules (no repeated colors in rows/columns)
    static func isSudokuValid(grid: [[Color]]) -> Bool {
        let size = grid.count
        
        // Check each row
        for row in 0..<size {
            if hasDuplicates(colors: grid[row]) {
                return false
            }
        }
        
        // Check each column
        for col in 0..<size {
            let column = grid.map { $0[col] }
            if hasDuplicates(colors: column) {
                return false
            }
        }
        
        return true
    }
    
    /// Checks if the current state represents a winning condition
    /// This only validates the main 3x3 grid for Sudoku completeness
    /// The overflow areas are not included in the win condition
    static func isWinningState(
        grid: [[Color]],
        topOverflow: [Color],
        leftOverflow: [Color],
        rightOverflow: [Color],
        bottomOverflow: [Color]
    ) -> Bool {
        // Win condition: valid Sudoku arrangement (no duplicate colors in rows/columns)
        // Only check the main grid, not the overflow areas
        return isSudokuValid(grid: grid)
    }
    
    /// Helper function to check for duplicate colors in an array
    private static func hasDuplicates(colors: [Color]) -> Bool {
        // Create a set to track unique colors by their string representation
        var seen = Set<String>()
        
        for color in colors {
            // Convert SwiftUI Color to string representation
            let colorString = colorToString(color)
            
            if seen.contains(colorString) {
                return true
            }
            seen.insert(colorString)
        }
        
        return false
    }
    
    /// Convert a SwiftUI Color to a string representation for comparison
    private static func colorToString(_ color: Color) -> String {
        // We don't have direct access to Color's components in SwiftUI
        // This is a simple workaround that uses the description
        // Note: This is not perfect for all colors but works for basic color comparison
        return "\(color)"
    }
    
    /// Determines if a position is fixed (immovable)
    static func isFixedPosition(row: Int, column: Int) -> Bool {
        // Check main grid center
        if row == 1 && column == 1 {
            return true
        }
        
        // Check overflow centers
        if (row == -1 && column == 1) || // Top center
           (row == 3 && column == 1) ||  // Bottom center
           (row == 1 && column == -1) || // Left center
           (row == 1 && column == 3) {   // Right center
            return true
        }
        
        return false
    }
}
