# Word or Nah - iOS Word Game

A fun and challenging iOS word game built with SwiftUI where players swipe to identify real vs. fake words!

## Features

### 🎮 Game Modes
- **Quick Start**: Mixed difficulty levels for variety
- **Easy Mode**: Common, everyday words
- **Medium Mode**: More challenging vocabulary
- **Hard Mode**: Advanced and archaic words

### 🎯 Gameplay
- **Swipe Mechanics**: Swipe right for real words, left for fake words
- **Touch Controls**: Alternative button controls for accessibility
- **Progressive Difficulty**: Games can increase in difficulty as you play
- **Instant Feedback**: Immediate feedback on each guess
- **Scoring System**: Points based on difficulty and speed

### 📊 Statistics & Progress
- **Comprehensive Stats**: Track accuracy, best scores, streaks
- **Time-based Analytics**: View performance over different time periods
- **Difficulty Breakdown**: See how you perform across difficulty levels
- **Game History**: Review your recent games and progress

### 🎨 UI/UX Features
- **Modern SwiftUI Design**: Beautiful, responsive interface
- **Dark Mode Support**: Optimized for both light and dark themes
- **Smooth Animations**: Engaging card swipe animations and transitions
- **Portrait-Only**: Focused mobile gaming experience
- **iOS 15+ Support**: Compatible with modern iOS devices

## Architecture

### MVVM Pattern
- **Models**: `Word`, `GameSession`, `GameStats`, `WordResult`
- **ViewModels**: `GameViewModel`, `StatsViewModel`
- **Views**: `HomeView`, `GameView`, `GameOverView`, `StatsView`
- **Services**: `DataManager`, `WordService`

### Data Management
- **JSON Storage**: Local file-based data persistence
- **Word Database**: Extensive collection of real and invented words
- **Statistics Tracking**: Comprehensive game analytics
- **Export/Import**: Backup and restore functionality

## File Structure

```
wordornot/
├── Models/
│   ├── Word.swift              # Word data model with difficulty/category
│   ├── GameSession.swift       # Game session and word result models
│   └── GameStats.swift         # Statistics and analytics models
├── ViewModels/
│   ├── GameViewModel.swift     # Game logic and state management
│   └── StatsViewModel.swift    # Statistics presentation logic
├── Views/
│   ├── HomeView.swift          # Main menu and navigation
│   ├── GameView.swift          # Gameplay interface with swipe mechanics
│   ├── GameOverView.swift      # Results and post-game actions
│   └── StatsView.swift         # Statistics and analytics display
├── Services/
│   ├── DataManager.swift       # JSON file management
│   └── WordService.swift       # Word selection and management
├── words.json                  # Word database
├── wordornotApp.swift          # App entry point
└── ContentView.swift           # Root view wrapper
```

## Game Mechanics

### Scoring System
- **Base Points**: 10 points per correct answer
- **Difficulty Multiplier**: Easy (1x), Medium (2x), Hard (3x)
- **Speed Bonus**: +5 points for answers under 3 seconds

### Word Categories
- **Common**: Everyday vocabulary
- **Technical**: Specialized terminology
- **Archaic**: Historical or obsolete words
- **Scientific**: Academic and scientific terms
- **Invented**: Creative fake words designed to sound plausible

### Statistics Tracking
- **Accuracy**: Overall and difficulty-specific performance
- **Streaks**: Consecutive successful games (70%+ accuracy)
- **Time Analytics**: Play time and average game duration
- **Progress History**: Last 100 games stored locally

## Installation & Setup

1. Open the project in Xcode 14.0+
2. Set deployment target to iOS 15.0+
3. Build and run on device or simulator
4. No additional dependencies required

## Customization

### Adding Words
- Edit `words.json` to add custom words
- Follow the JSON structure with required fields:
  - `text`: The word string
  - `isReal`: Boolean for real/fake classification
  - `difficulty`: "easy", "medium", or "hard"
  - `category`: Word category classification

### Game Settings
- Modify `totalWordsPerGame` in `GameViewModel.swift`
- Adjust scoring multipliers in `WordResult.swift`
- Customize difficulty progression in `WordService.swift`

## Future Enhancements

- [ ] Multiplayer support
- [ ] Achievement system
- [ ] Daily challenges
- [ ] Word definitions and explanations
- [ ] Social sharing of scores
- [ ] Accessibility improvements
- [ ] Additional language support

## Technical Requirements

- **iOS**: 15.0+
- **Xcode**: 14.0+
- **Swift**: 5.0+
- **Orientation**: Portrait only
- **Storage**: Local JSON files

---

Enjoy playing **Word or Nah** and challenge your vocabulary knowledge! 🎯📚
