//
//  PuzzleGenerator.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2023-11-02.
//

import Foundation
import SwiftUI

class PuzzleGenerator {
    
    enum Difficulty {
        case beginner, easy, medium, tricky, fiendish, diabolical
    }
    
    var solutionGrid: [[Color]]
        var puzzleGrid: [[Color]]
        var fixedCenterColors: [Color]
        
        init(fixedCenterColors: [Color]) {
            self.fixedCenterColors = fixedCenterColors
            self.solutionGrid = Array(repeating: Array(repeating: .clear, count: 5), count: 5)
            self.puzzleGrid = Array(repeating: Array(repeating: .clear, count: 5), count: 5)
        }
        
        func generatePuzzle(difficulty: Difficulty) {
            generateFullSolution()
            
            // Remove colors to create the puzzle with a certain difficulty
            createPuzzle(from: solutionGrid, difficulty: difficulty)
        }
        
        private func generateFullSolution() {
            // Implement backtracking algorithm to generate a full grid solution
        }
        
        private func createPuzzle(from solution: [[Color]], difficulty: Difficulty) {
            // Remove colors from the solution to create a puzzle
        }
        
//        func solve(puzzle: [[Color]]) -> Bool {
//            // Solve the puzzle using a backtracking algorithm
//            // Return true if a solution is found, false otherwise
//        }
//        
//        func calculateDifficulty(of puzzle: [[Color]]) -> Difficulty {
//            // Estimate the difficulty based on the minimum number of moves to solve
//        }
    
}
