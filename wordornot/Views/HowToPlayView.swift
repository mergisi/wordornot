//
//  HowToPlayView.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import SwiftUI

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.primaryDark.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    header
                    steps
                    scoring
                    proTip
                    gotItButton
                }
                .padding(.horizontal, AppLayout.padding)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("HOW TO PLAY")
                .font(AppTypography.title)
                .foregroundColor(.white)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private var steps: some View {
        VStack(alignment: .leading, spacing: 18) {
            stepRow(number: 1, title: "Read the Word", subtitle: "A word will appear on the card")
            wordPreview
            stepRow(number: 2, title: "Decide: Real or Fake?", subtitle: "Is it a real dictionary word?")
            HStack(spacing: 12) {
                tag("FAKE", color: .errorRed)
                tag("REAL", color: .successGreen)
            }
            stepRow(number: 3, title: "Swipe Your Answer", subtitle: "Left = Fake | Right = Real")
            HStack(spacing: 30) {
                Text("←").font(.title).foregroundColor(.errorRed)
                RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.15)).frame(width: 120, height: 36)
                Text("→").font(.title).foregroundColor(.successGreen)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: AppLayout.cornerRadius).fill(Color.secondaryDark))
    }
    
    private func stepRow(number: Int, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(Color.purpleAccent)
                .frame(width: 28, height: 28)
                .overlay(Text("\(number)").font(.caption).bold().foregroundColor(.white))
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline).foregroundColor(.white)
                Text(subtitle).font(AppTypography.caption).foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
    }
    
    private var wordPreview: some View {
        Text("WORD")
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.12)))
    }
    
    private func tag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.subheadline).bold()
            .foregroundColor(.white)
            .padding(.vertical, 6).padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.9)))
    }
    
    private var scoring: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SCORING").font(.headline).foregroundColor(.streakGold)
            HStack {
                Text("✓ Correct: +10 points").foregroundColor(.white)
                Spacer()
                Text("🔥 Streak: Keep going!").foregroundColor(.streakGold)
            }
            HStack {
                Text("✗ Wrong: -1 life").foregroundColor(.errorRed)
                Spacer()
                Text("0 lives = Game Over").foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: AppLayout.cornerRadius).fill(Color.secondaryDark))
    }
    
    private var proTip: some View {
        VStack(spacing: 8) {
            Text("PRO TIP").font(AppTypography.caption).foregroundColor(.white.opacity(0.7))
            Text("Trust your instincts! If it sounds weird, it's probably fake.")
                .font(AppTypography.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: AppLayout.cornerRadius).fill(Color.white.opacity(0.08)))
    }
    
    private var gotItButton: some View {
        Button(action: { dismiss() }) {
            Text("GOT IT!")
                .primaryButtonStyle(color: .successGreen)
        }
    }
}

#Preview {
    HowToPlayView()
}


