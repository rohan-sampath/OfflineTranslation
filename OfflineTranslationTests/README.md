# LanguagePairView Tests

## Overview

This directory contains tests for the `LanguagePairView` component, which handles language selection in the Offline Translation app.

## Test File Structure

The unit tests cover the following aspects of `LanguagePairView`:

1. **Initialization and Default Values**
   - Verifies that the view initializes with the expected default values

2. **Utility Functions**
   - Tests the `compareLanguages` function which compares two `Locale.Language` objects
   - Tests the `languageShortNameMatches` function which compares language short names

3. **Language Detection**
   - Tests how the view handles detected languages

4. **Default Language Setting**
   - Tests that default target language is set when the view appears

## Framework Selection

There are two implementations of the tests:

### 1. Using Apple's Testing Framework (iOS 18+)

```swift
import Testing
import SwiftUI
@testable import OfflineTranslation

struct LanguagePairViewTests {
    @Test func testExample() {
        // Test implementation
        #expect(true)
    }
}
```

### 2. Using XCTest Framework (Traditional)

```swift
import XCTest
import SwiftUI
@testable import OfflineTranslation

final class LanguagePairViewTests: XCTestCase {
    func testExample() {
        // Test implementation
        XCTAssertTrue(true)
    }
}
```

## Which Framework To Use

- **Use Testing Framework**: If you're targeting iOS 18+ exclusively and have enabled the Swift Testing feature
- **Use XCTest Framework**: For broader compatibility or if the Testing framework is not properly set up

## Running the Tests

1. **Through Xcode**:
   - Select the test target (OfflineTranslationTests)
   - Press Cmd+U or go to Product > Test

2. **Through Command Line**:
   - Run `xcodebuild test -scheme OfflineTranslation -destination 'platform=iOS Simulator,name=iPhone 15'`

## Troubleshooting

If you encounter "No such module" errors:
1. Check that the test target has the proper framework linked
2. For the Testing framework: Make sure you have the Swift Testing feature enabled in Xcode 16+
3. For XCTest: Make sure XCTest.framework is linked in the test target

## Note on SwiftUI Testing Limitations

Some aspects of `LanguagePairView` (like `onChange` and `onAppear` modifiers) are challenging to test with standard unit tests. Consider using ViewInspector or UI Testing for complete testing coverage. 