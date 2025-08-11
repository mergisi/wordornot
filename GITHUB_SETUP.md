# GitHub Setup Guide for AI Word or Not?

## Step 1: Initialize Git Repository
```bash
cd /Users/mustafaergisi/Documents/wordornot
git init
```

## Step 2: Add All Files
```bash
git add .
```

## Step 3: Make Initial Commit
```bash
git commit -m "Initial commit: AI Word or Not? iOS game with SwiftUI"
```

## Step 4: Set Main Branch
```bash
git branch -M main
```

## Step 5: Add Remote Repository
```bash
git remote add origin https://github.com/mergisi/wordornot.git
```

## Step 6: Push to GitHub
```bash
git push -u origin main
```

## Step 7: Create Support and Privacy Pages (Optional)
If you want to add the support and privacy pages to GitHub:

```bash
# Create support page
echo "# Support

## Contact Information
Email: support@wordornah.app

## Frequently Asked Questions
- How to play the game
- Technical issues
- Account problems

For immediate assistance, please contact us via email." > SUPPORT.md

# Create privacy policy page
echo "# Privacy Policy

Last updated: $(date +%Y-%m-%d)

## Information We Collect
We do not collect any personal information. All game data is stored locally on your device.

## Data Storage
- Game statistics and progress are stored locally
- No data is transmitted to external servers
- No personal information is collected or shared

## Contact Us
If you have questions about this Privacy Policy, please contact us at privacy@wordornah.app" > PRIVACY.md

# Add and commit these files
git add SUPPORT.md PRIVACY.md
git commit -m "Add support and privacy policy pages"
git push
```

## Troubleshooting

### If you get authentication errors:
1. Make sure you're logged into GitHub CLI:
   ```bash
   gh auth login
   ```

2. Or use personal access token:
   - Go to GitHub.com → Settings → Developer settings → Personal access tokens
   - Generate new token with repo permissions
   - Use token as password when prompted

### If repository already exists with content:
```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### To check repository status:
```bash
git status
git log --oneline
git remote -v
```

## Your Repository URLs
- **Repository**: https://github.com/mergisi/wordornot
- **Support URL**: https://github.com/mergisi/wordornot/blob/main/SUPPORT.md
- **Privacy URL**: https://github.com/mergisi/wordornot/blob/main/PRIVACY.md

## Next Steps
1. Update your App Store Connect settings with the GitHub URLs
2. Consider adding screenshots to your repository
3. Update README.md with app description and features
4. Add release tags for version tracking

## Git Best Practices for Future Updates
```bash
# For future changes:
git add .
git commit -m "Descriptive commit message"
git push

# For new features:
git checkout -b feature/new-feature
# make changes
git add .
git commit -m "Add new feature"
git checkout main
git merge feature/new-feature
git push
```
