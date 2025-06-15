# Recipe App

A simple iOS app to manage and add recipes.

## App Credentials (username:pwd)
- demo:password123

## Requirements
- Xcode 13 or later
- iOS 14.0 or later
- Swift 5.0 or later

---

## App Functional Requirements

- **Language**: Use Swift (preferred) or Objective-C.
- **Recipe Types Source**: Create a `recipetypes.json` file containing recipe types. Load data from this local file and populate a `UIPickerView`.
- **Recipe Listing**: Display all recipes in a listing page, filterable by recipe type (from `recipetypes.json`).
- **Sample Data**: Pre-populate the app with sample recipes that comply with the available recipe types.
- **Add Recipe**: Provide an Add Recipe page allowing users to select a recipe type, add a picture, ingredients, and steps. Newly added recipes update the list.
- **Recipe Detail**: Display recipe image, ingredients, and steps. Allow editing (update all fields) and deleting recipes from this page.
- **Persistence**: Use an iOS persistence method (e.g., UserDefaults, Core Data, or file storage) to store recipe data and ensure it persists across app restarts.
- **CocoaPods**: Use at least one third-party library via CocoaPods to assist development.

---

## Bonus Points (Completed)

- **Architecture Pattern**: Built using a clean architecture pattern (MVVM) for maintainable and testable code.
- **Authentication**: Login and Logout features with authentication, encryption, and session persistency until logout.
- **Networking**: API layer implemented to fetch data from self-hosted sources. For authentication, and recipe types.


## Getting Started

1. **Clone the repository**
   ```sh
   git clone <repository-url>
   cd recipe-app
   ```

2. **Install CocoaPods dependencies**
   If you haven't installed CocoaPods, run:
   ```sh
   sudo gem install cocoapods
   ```
   Then, install the pods:
   ```sh
   pod install
   ```

3. **Open the project in Xcode**
   Always open the `.xcworkspace` file (not the `.xcodeproj` file):
   ```sh
   open recipe-app.xcworkspace
   ```

4. **Build and Run**
   - Select a simulator or your device in Xcode.
   - Click the **Run** button (▶️) or press `Cmd + R`.

## Project Structure
- `recipe-app/` - Main source code (MVVM pattern)
- `recipe-appTests/` - Unit tests
- `recipe-appUITests/` - UI tests
- `Pods/` - CocoaPods dependencies

## Notes
- Make sure to run `pod install` after cloning or when dependencies change.
- If you encounter issues, try running `pod update`.
