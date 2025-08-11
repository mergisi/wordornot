//
//  GameOverView.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDetails = false
    @State private var animateScore = false
    @State private var animateAccuracy = false
    
    var body: some View {
        ZStack {
            // Background
            Color.primaryDark
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer(minLength: 10)

                // Title
                Text("GAME OVER")
                    .font(AppTypography.title)
                    .foregroundColor(.streakGold)

                // Score + quick stats card
                resultsSummary

                // CTA buttons and daily streak section
                ctaSection

                Spacer(minLength: 20)
            }
            .padding(.horizontal, AppLayout.padding)
        }
        .onAppear {
            print("DEBUG: GameOverView appeared!")
            print("DEBUG: gameViewModel.isGameOver = \(gameViewModel.isGameOver)")
            print("DEBUG: gameViewModel.isGameActive = \(gameViewModel.isGameActive)")
            animateResults()
        }
        .onDisappear {
            print("DEBUG: GameOverView disappeared!")
            print("DEBUG: gameViewModel.isGameOver = \(gameViewModel.isGameOver)")
            print("DEBUG: gameViewModel.isGameActive = \(gameViewModel.isGameActive)")
        }
    }

    // MARK: - CTA + Daily Streak Section (matches provided design)
    private var ctaSection: some View {
        VStack(spacing: 20) {
            // Share Score
            Button(action: {
                shareScore()
            }) {
                Text("SHARE SCORE")
                    .primaryButtonStyle(color: .purpleAccent)
            }

            // Play Again
            Button(action: {
                gameViewModel.restartGame()
            }) {
                Text("PLAY AGAIN")
                    .primaryButtonStyle(color: .successGreen)
            }

            // Daily Streak Card
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(Color.secondaryDark)
                .frame(height: 140)
                .overlay(
                    VStack(spacing: 10) {
                        Text("DAILY STREAK")
                            .font(AppTypography.caption)
                            .foregroundColor(.white.opacity(0.7))

                        Text("5 DAYS")
                            .font(AppTypography.score.weight(.bold))
                            .foregroundColor(.streakGold)

                        Text("Come back tomorrow!")
                            .font(AppTypography.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                )
        }
        .padding(.horizontal, AppLayout.padding)
    }
    
    private var resultsSummary: some View {
        VStack(spacing: 20) {
            // Score card
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(Color.secondaryDark)
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 15) {
                        Text("FINAL SCORE")
                            .font(AppTypography.subtitle)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(gameViewModel.gameSession.score)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(animateScore ? 1.0 : 0.1)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateScore)
                        
                        // Quick stats
                        VStack(spacing: 8) {
                            HStack {
                                Text("Accuracy:")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text(String(format: "%.0f%%", gameViewModel.gameSession.accuracy * 100))
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Best Streak:")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("\(gameViewModel.gameSession.maxStreak)")
                                        .foregroundColor(.streakGold)
                                        .fontWeight(.bold)
                                    Text("🔥")
                                }
                            }
                            
                            HStack {
                                Text("Words:")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(gameViewModel.gameSession.correctAnswers)/\(gameViewModel.gameSession.totalWords)")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                        .font(AppTypography.caption)
                        .padding(.horizontal, 20)
                    }
                )
                .padding(.horizontal, AppLayout.padding)
        }
    }
    
    private var performanceBreakdown: some View {
        VStack(spacing: 15) {
            Text("Performance Breakdown")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(getDifficultyBreakdown(), id: \.difficulty) { breakdown in
                    difficultyCard(breakdown: breakdown)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var actionButtons: some View {
        VStack(spacing: 15) {
            // Show/Hide details button
            Button(action: {
                withAnimation(.spring()) {
                    showingDetails.toggle()
                }
            }) {
                HStack {
                    Text(showingDetails ? "Hide Details" : "Show Details")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Image(systemName: showingDetails ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.2))
                )
            }
            
            VStack(spacing: 15) {
                // Share Score button
                Button(action: {
                    shareScore()
                }) {
                    Text("SHARE SCORE")
                        .primaryButtonStyle(color: .purpleAccent)
                }
                .padding(.horizontal, AppLayout.padding)
                
                // Play Again button
                Button(action: {
                    gameViewModel.restartGame()
                }) {
                    Text("PLAY AGAIN")
                        .primaryButtonStyle(color: .successGreen)
                }
                .padding(.horizontal, AppLayout.padding)
                
                // Daily Streak Section
                VStack(spacing: 15) {
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .fill(Color.secondaryDark)
                        .frame(height: 100)
                        .overlay(
                            VStack(spacing: 8) {
                                Text("DAILY STREAK")
                                    .font(AppTypography.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("5 DAYS")
                                    .font(AppTypography.score.weight(.bold))
                                    .foregroundColor(.streakGold)
                                
                                Text("Come back tomorrow!")
                                    .font(AppTypography.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        )
                }
                .padding(.horizontal, AppLayout.padding)
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, animate: Bool = false) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .scaleEffect(animate ? 1.0 : 0.1)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4), value: animate)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.15))
        )
    }
    
    private func difficultyCard(breakdown: DifficultyBreakdown) -> some View {
        VStack(spacing: 8) {
            Text(breakdown.difficulty.displayName)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("\(breakdown.correct)/\(breakdown.total)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(difficultyColor(breakdown.difficulty))
            
            Text(String(format: "%.1f%%", breakdown.accuracy * 100))
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private func gameButton(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(color.opacity(0.8))
        )
    }
    
    // MARK: - Helper Methods
    
    private func shareScore() {
        let scoreText = """
        🎮 Word or Not Score 🎮
        
        Score: \(gameViewModel.gameSession.score)
        Accuracy: \(String(format: "%.0f%%", gameViewModel.gameSession.accuracy * 100))
        Best Streak: \(gameViewModel.gameSession.maxStreak) 🔥
        Words: \(gameViewModel.gameSession.correctAnswers)/\(gameViewModel.gameSession.totalWords)
        
        Can you beat my score? 🤔
        """
        
        let activityController = UIActivityViewController(activityItems: [scoreText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            // Find the topmost view controller
            var topController = rootViewController
            while let presentedController = topController.presentedViewController {
                topController = presentedController
            }
            
            topController.present(activityController, animated: true)
        }
    }
    
    private func animateResults() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.1)) {
            animateScore = true
        }
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.3)) {
            animateAccuracy = true
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
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
    
    private func getDifficultyBreakdown() -> [DifficultyBreakdown] {
        var breakdowns: [Word.Difficulty: DifficultyBreakdown] = [:]
        
        // Initialize with all difficulties
        for difficulty in Word.Difficulty.allCases {
            breakdowns[difficulty] = DifficultyBreakdown(
                difficulty: difficulty,
                total: 0,
                correct: 0
            )
        }
        
        // Count results by difficulty
        for wordResult in gameViewModel.gameSession.words {
            let difficulty = wordResult.word.difficulty
            breakdowns[difficulty]?.total += 1
            if wordResult.isCorrect {
                breakdowns[difficulty]?.correct += 1
            }
        }
        
        // Return only difficulties that had words
        return breakdowns.values.filter { $0.total > 0 }.sorted { $0.difficulty.rawValue < $1.difficulty.rawValue }
    }
}

// MARK: - Supporting Types

struct DifficultyBreakdown {
    let difficulty: Word.Difficulty
    var total: Int
    var correct: Int
    
    var accuracy: Double {
        guard total > 0 else { return 0.0 }
        return Double(correct) / Double(total)
    }
}

#Preview {
    GameOverView(gameViewModel: GameViewModel())
}
