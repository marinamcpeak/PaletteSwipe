//
//  GridSqure.swift
//  PaletteSwipe
//
//  Created by Marina McPeak on 2023-11-02.
//

import SwiftUI

/// A view representing a single square that responds to swipe gestures
///
/// This view displays a colored square that detects drag gestures
/// triggers an action based on the primary axis of the swipe (horizontal or vertical).
struct GridSquare: View {
    // MARK: - Properties

    /// The color of the grid square.
    let color: Color

    /// The action to be called when a swipe gesture is detected.
    /// - Parameter direction: The direction of the swipe.
    let action: (SwipeDirection) -> Void

    // MARK: - UI Constants

    /// The dimension for the width and height of the square.
    private let squareSize: CGFloat = 50

    /// The minimum distance the drag gesture must move before the gesture fails.
    private let minimumDragDistance: CGFloat = 1.0

    // MARK: - View Body

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: squareSize, height: squareSize)
            .gesture(createDragGesture())
    }

    // MARK: - Gesture Creation

    /// Creates a drag gesture that will trigger the action with a swipe direction
    /// when a drag movement is recognized.
    ///
    /// - Returns: A configured `DragGesture`.
    private func createDragGesture() -> some Gesture {
        DragGesture(minimumDistance: minimumDragDistance)
            .onEnded { value in
                let swipeDirection = determineSwipeDirection(from: value)
                action(swipeDirection)
            }
    }

    // MARK: - Helper Methods

    /// Determines the swipe direction from the drag gesture value.
    ///
    /// - Parameter value: The value containing the drag information.
    /// - Returns: The determined `SwipeDirection`.
    private func determineSwipeDirection(from value: DragGesture.Value) -> SwipeDirection {
        let horizontalAmount = value.translation.width as CGFloat
        let verticalAmount = value.translation.height as CGFloat

        if abs(horizontalAmount) > abs(verticalAmount) {
            return horizontalAmount < 0 ? .left : .right
        } else {
            return verticalAmount < 0 ? .up : .down
        }
    }
}
