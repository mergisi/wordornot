//
//  GameView.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var dragOffset: CGSize = .zero
    @State private var rotationAngle: Double = 0
    @State private var cardScale: CGFloat = 1.0
    
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    
    var body: some View {
        Group {
            if gameViewModel.isGameOver {
                // SHOW GAME OVER DIRECTLY
                GameOverView(gameViewModel: gameViewModel)
            } else {
                // SHOW NORMAL GAME
                ZStack {
                    // Background
                    Color.primaryDark
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        // Header
                        headerView
                        
                        // Progress bar
                        progressBar
                        
                        Spacer()
                        
                        // Word card
                        if let currentWord = gameViewModel.currentWord {
                            wordCard(word: currentWord)
                        } else {
                            loadingCard
                        }
                        
                        Spacer()
                        
                        // Action buttons
                        actionButtons
                        
                        // Instructions
                        instructionsView
                    }
                    .padding()
                    
                    // Feedback overlay
                    if gameViewModel.showFeedback {
                        feedbackOverlay
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("DEBUG: GameView onAppear - isGameActive: \(gameViewModel.isGameActive), isGameOver: \(gameViewModel.isGameOver), gameWords.count: \(gameViewModel.gameWords.count)")
            // Start game ONLY if not already active AND not game over AND no words loaded
            if !gameViewModel.isGameActive && !gameViewModel.isGameOver && gameViewModel.gameWords.isEmpty {
                print("DEBUG: Starting new game from onAppear")
                gameViewModel.startMixedGame()
            } else {
                print("DEBUG: NOT starting game - conditions not met")
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            // Score
            VStack(alignment: .leading) {
                Text("SCORE")
                    .font(AppTypography.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(gameViewModel.currentScore)")
                    .font(AppTypography.score.weight(.bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Streak
            VStack {
                Text("STREAK")
                    .font(AppTypography.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 4) {
                    Text("🔥")
                    Text("\(gameViewModel.gameSession.currentStreak)")
                        .font(AppTypography.score.weight(.bold))
                        .foregroundColor(.streakGold)
                }
            }
            
            Spacer()
            
            // Lives
            VStack(alignment: .trailing) {
                Text("LIVES")
                    .font(AppTypography.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        Text("❤️")
                            .opacity(index < gameViewModel.gameSession.lives ? 1.0 : 0.3)
                    }
                }
            }
        }
        .padding(.horizontal, AppLayout.padding)
        .padding(.top, 10)
        .background(Color.secondaryDark)
    }
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            ProgressView(value: gameViewModel.gameProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .streakGold))
                .background(Color.white.opacity(0.2))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("\(gameViewModel.currentWordIndex + 1) / \(gameViewModel.totalWordsPerGame) words")
                .font(AppTypography.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, AppLayout.padding)
        .padding(.top, 20)
    }
    
    private func wordCard(word: Word) -> some View {
        ZStack {
            // Card Shadow
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(Color.black.opacity(0.2))
                .frame(width: AppLayout.cardWidth, height: AppLayout.cardHeight)
                .offset(x: 5, y: 5)
            
            // Card Background
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(Color.white)
                .frame(width: AppLayout.cardWidth, height: AppLayout.cardHeight)
            
            // Word Text
            Text(word.text.uppercased())
                .font(AppTypography.wordFont(for: word.text))
                .foregroundColor(.primaryDark)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.4)
                .lineLimit(3)
                .padding(.horizontal, 15)
                .allowsTightening(true)
        }
        .scaleEffect(cardScale)
        .rotationEffect(.degrees(rotationAngle))
        .offset(dragOffset)
        .overlay(
            // Swipe overlay colors
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(dragOffset.width > 50 ? Color.successGreen.opacity(0.3) : 
                      dragOffset.width < -50 ? Color.errorRed.opacity(0.3) : Color.clear)
                .frame(width: AppLayout.cardWidth, height: AppLayout.cardHeight)
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                    let translationX = value.translation.width
                    rotationAngle = Double(translationX / 10).clamped(to: -maxRotation...maxRotation)
                    cardScale = 1.0 - abs(translationX) / 1000
                }
                .onEnded { value in
                    handleSwipeEnd(value: value)
                }
        )
        .animation(AppAnimations.cardSwipe, value: dragOffset)
        .animation(AppAnimations.cardSwipe, value: rotationAngle)
        .animation(AppAnimations.cardSwipe, value: cardScale)
    }
    
    private var loadingCard: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.1))
            .frame(width: 300, height: 400)
            .overlay(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            )
    }
    
    private var actionButtons: some View {
        HStack(spacing: 80) {
            // Fake button
            VStack(spacing: 12) {
                Button(action: {
                    gameViewModel.guessFake()
                }) {
                    Circle()
                        .fill(Color.errorRed.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .foregroundColor(.errorRed)
                        )
                }
                .scaleEffect(dragOffset.width < -50 ? 1.2 : 1.0)
                .animation(AppAnimations.standard, value: dragOffset)
                
                Text("FAKE")
                    .font(AppTypography.subtitle)
                    .foregroundColor(.errorRed)
            }
            
            // Real button
            VStack(spacing: 12) {
                Button(action: {
                    gameViewModel.guessReal()
                }) {
                    Circle()
                        .fill(Color.successGreen.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .font(.title)
                                .foregroundColor(.successGreen)
                        )
                }
                .scaleEffect(dragOffset.width > 50 ? 1.2 : 1.0)
                .animation(AppAnimations.standard, value: dragOffset)
                
                Text("REAL")
                    .font(AppTypography.subtitle)
                    .foregroundColor(.successGreen)
            }
        }
        .padding(.bottom, 40)
    }
    
    private var instructionsView: some View {
        Text("Swipe left or right")
            .font(AppTypography.caption)
            .foregroundColor(.white.opacity(0.6))
    }
    
    private var feedbackOverlay: some View {
        ZStack {
            Color.primaryDark.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Success/Error Icon
                Circle()
                    .fill(gameViewModel.lastAnswerCorrect ? Color.successGreen : Color.errorRed)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: gameViewModel.lastAnswerCorrect ? "checkmark" : "xmark")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                // Feedback Text
                Text(gameViewModel.lastAnswerCorrect ? "CORRECT!" : "OOPS!")
                    .font(AppTypography.title)
                    .foregroundColor(gameViewModel.lastAnswerCorrect ? .successGreen : .errorRed)
                
                // Word Info Card
                if let currentWord = gameViewModel.currentWord {
                    VStack(spacing: 15) {
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                            .fill(Color.white.opacity(0.95))
                            .frame(width: 320, height: 130)
                            .overlay(
                                VStack(spacing: 8) {
                                    Text(currentWord.text.uppercased())
                                        .font(AppTypography.wordFont(for: currentWord.text))
                                        .foregroundColor(.primaryDark)
                                        .multilineTextAlignment(.center)
                                        .minimumScaleFactor(0.4)
                                        .lineLimit(3)
                                        .allowsTightening(true)
                                        .padding(.horizontal, 10)
                                    
                                    Text("is \(currentWord.isReal ? "a real word!" : "not a real word!")")
                                        .font(AppTypography.subtitle)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                    
                                    if !gameViewModel.lastAnswerCorrect {
                                        Text("Nice try though!")
                                            .font(AppTypography.caption)
                                            .foregroundColor(.gray.opacity(0.7))
                                    }
                                }
                            )
                        
                        // Points or life lost
                        if gameViewModel.lastAnswerCorrect {
                            Text("+10 points")
                                .font(AppTypography.subtitle)
                                .foregroundColor(.streakGold)
                        } else {
                            Text("-1 ❤️")
                                .font(AppTypography.subtitle)
                                .foregroundColor(.errorRed)
                        }
                    }
                }
            }
            .scaleEffect(gameViewModel.showFeedback ? 1.0 : 0.1)
            .opacity(gameViewModel.showFeedback ? 1.0 : 0.0)
            .animation(AppAnimations.feedback, value: gameViewModel.showFeedback)
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleSwipeEnd(value: DragGesture.Value) {
        let swipeDistance = value.translation.width
        
        if abs(swipeDistance) > swipeThreshold {
            if swipeDistance > 0 {
                // Swiped right - guess real
                gameViewModel.guessReal()
            } else {
                // Swiped left - guess fake
                gameViewModel.guessFake()
            }
        }
        
        // Reset card position
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            dragOffset = .zero
            rotationAngle = 0
            cardScale = 1.0
        }
    }
    
    private func difficultyColor(_ difficulty: Word.Difficulty) -> Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
}

// MARK: - Helper Extensions

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    GameView(gameViewModel: GameViewModel())
}
