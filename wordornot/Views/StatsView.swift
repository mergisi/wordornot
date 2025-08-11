//
//  StatsView.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var statsViewModel: StatsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTimeFrame: StatsTimeFrame = .allTime
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Time frame selector
                        timeFrameSelector
                        
                        // Summary cards
                        summaryCards
                        
                        // Performance breakdown
                        performanceSection
                        
                        // Recent games
                        recentGamesSection
                        
                        // Actions
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .alert("Reset Statistics", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                statsViewModel.resetAllStats()
            }
        } message: {
            Text("This will permanently delete all your game statistics. This action cannot be undone.")
        }
        .onAppear {
            statsViewModel.refreshStats()
        }
        .onChange(of: selectedTimeFrame) { timeFrame in
            statsViewModel.changeTimeFrame(timeFrame)
        }
    }
    
    private var timeFrameSelector: some View {
        VStack(spacing: 10) {
            Text("Time Period")
                .font(.headline)
                .foregroundColor(.primary)
            
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(StatsTimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.displayName).tag(timeFrame)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 5)
        )
    }
    
    private var summaryCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            StatCard(
                title: "Games Played",
                value: statsViewModel.totalGames,
                icon: "gamecontroller.fill",
                color: .blue
            )
            
            StatCard(
                title: "Overall Accuracy",
                value: statsViewModel.formattedOverallAccuracy,
                icon: "target",
                color: .green
            )
            
            StatCard(
                title: "Best Score",
                value: statsViewModel.formattedBestScore,
                icon: "star.fill",
                color: .yellow
            )
            
            StatCard(
                title: "Current Streak",
                value: statsViewModel.currentStreak,
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "Total Words",
                value: statsViewModel.totalWords,
                icon: "textformat.abc",
                color: .purple
            )
            
            StatCard(
                title: "Play Time",
                value: statsViewModel.formattedTotalPlayTime,
                icon: "clock.fill",
                color: .indigo
            )
        }
    }
    
    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Performance by Difficulty")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 10) {
                ForEach(statsViewModel.getDifficultyBreakdown()) { difficultyStats in
                    DifficultyPerformanceRow(stats: difficultyStats)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 5)
        )
    }
    
    private var recentGamesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Games")
                .font(.headline)
                .foregroundColor(.primary)
            
            if statsViewModel.getRecentGames().isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "gamecontroller")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("No games played yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Start a game to see your statistics here")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(statsViewModel.getRecentGames().enumerated()), id: \.offset) { index, game in
                        RecentGameRow(game: game, index: index + 1)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 5)
        )
    }
    
    private var actionsSection: some View {
        VStack(spacing: 15) {
            Button(action: {
                statsViewModel.exportStats()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Statistics")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            
            Button(action: {
                showingResetAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Reset All Statistics")
                }
                .font(.headline)
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 3)
        )
    }
}

struct DifficultyPerformanceRow: View {
    let stats: DifficultyStats
    
    var body: some View {
        HStack {
            // Difficulty indicator
            Text(stats.difficulty.displayName)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(difficultyColor(stats.difficulty))
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(stats.correctWords)/\(stats.totalWords)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(stats.formattedAccuracy)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            ProgressView(value: stats.accuracy)
                .progressViewStyle(LinearProgressViewStyle(tint: difficultyColor(stats.difficulty)))
                .frame(width: 100)
        }
        .padding(.vertical, 8)
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

struct RecentGameRow: View {
    let game: GameSession
    let index: Int
    
    var body: some View {
        HStack {
            // Game number
            Text("#\(index)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Score: \(game.score)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f%%", game.accuracy * 100))
                        .font(.subheadline)
                        .foregroundColor(game.accuracy >= 0.7 ? .green : .red)
                }
                
                Text(formatGameDate(game.startTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Performance indicator
            Image(systemName: game.accuracy >= 0.7 ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(game.accuracy >= 0.7 ? .green : .red)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private func formatGameDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    StatsView(statsViewModel: StatsViewModel())
}
