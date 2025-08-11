//
//  HomeView.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var statsViewModel = StatsViewModel()
    @State private var showingStats = false
    @State private var showingSettings = false
    @State private var showingHowTo = false
    @State private var selectedDifficulty: Word.Difficulty? = nil
    @State private var showingDifficultySelection = false
    @State private var showingGame = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.primaryDark
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo and Title
                    VStack(spacing: 20) {
                        Circle()
                            .fill(Color.purpleAccent)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("W?")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 10) {
                            Text("WORD OR NOT")
                                .font(AppTypography.title)
                                .foregroundColor(.white)
                            
                            Text("Swipe to decide!")
                                .font(AppTypography.subtitle)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Daily Challenge
                    dailyChallengeCard

                    // Support buttons
                    HStack(spacing: 12) {
                        Button(action: { showingHowTo = true }) {
                            HStack { Image(systemName: "questionmark.circle"); Text("How to Play") }
                                .font(AppTypography.caption)
                                .padding(.vertical, 8).padding(.horizontal, 12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.08)))
                        }
                        Button(action: { showingSettings = true }) {
                            HStack { Image(systemName: "gearshape"); Text("Settings") }
                                .font(AppTypography.caption)
                                .padding(.vertical, 8).padding(.horizontal, 12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.08)))
                        }
                    }
                    
                    // Resume if available
                    if DataManager.shared.loadGameState() != nil && !gameViewModel.isGameActive {
                        Button(action: {
                            showingGame = true
                        }) {
                            Text("RESUME")
                                .primaryButtonStyle(color: .purpleAccent)
                        }
                        .padding(.horizontal, 40)
                    }

                    // Play Button
                    Button(action: {
                        gameViewModel.startMixedGame()
                        showingGame = true
                    }) {
                        Text("PLAY")
                            .primaryButtonStyle(color: .successGreen)
                    }
                    .padding(.horizontal, 40)
                    
                    // Stats Summary
                    statsCard
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingStats) {
            StatsView(statsViewModel: statsViewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHowTo) {
            HowToPlayView()
        }
        .actionSheet(isPresented: $showingDifficultySelection) {
            ActionSheet(
                title: Text("Choose Difficulty"),
                message: Text("Select the word difficulty level"),
                buttons: [
                    .default(Text("Easy")) {
                        selectedDifficulty = .easy
                        gameViewModel.startEasyGame()
                        showingGame = true
                    },
                    .default(Text("Medium")) {
                        selectedDifficulty = .medium
                        gameViewModel.startMediumGame()
                        showingGame = true
                    },
                    .default(Text("Hard")) {
                        selectedDifficulty = .hard
                        gameViewModel.startHardGame()
                        showingGame = true
                    },
                    .cancel()
                ]
            )
        }
        .fullScreenCover(isPresented: $showingGame) {
            GameView(gameViewModel: gameViewModel)
                .onDisappear {
                    // Refresh stats when game view closes (after Game Over or back)
                    statsViewModel.refreshStats()
                }
        }
        .onAppear {
            statsViewModel.refreshStats()
        }
    }
    
    private var dailyChallengeCard: some View {
        VStack(spacing: 15) {
            Text("DAILY CHALLENGE")
                .font(AppTypography.caption)
                .foregroundColor(.purpleAccent)
            
            Text("20 WORDS")
                .font(AppTypography.score.weight(.bold))
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < 2 ? Color.successGreen : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(AppLayout.padding)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(Color.purpleAccent, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .fill(Color.purpleAccent.opacity(0.1))
                )
        )
        .padding(.horizontal, AppLayout.padding)
    }
    
    private var statsCard: some View {
        HStack(spacing: 30) {
            statItem(title: "STREAK", value: "\(statsViewModel.gameStats.streakCount)", color: .streakGold)
            statItem(title: "BEST SCORE", value: statsViewModel.formattedBestScore, color: .white)
            statItem(title: "ACCURACY", value: statsViewModel.formattedOverallAccuracy, color: .successGreen)
        }
        .padding(AppLayout.padding)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(Color.secondaryDark)
        )
        .padding(.horizontal, AppLayout.padding)
    }
    
    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(AppTypography.button)
                .foregroundColor(color)
        }
    }
    

}

// MARK: - Blur Effect Helper

struct BlurEffect: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension View {
    func backdrop(_ blurEffect: BlurEffect) -> some View {
        self.background(blurEffect)
    }
}

#Preview {
    HomeView()
}
