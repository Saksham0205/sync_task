# SyncTask Architecture Documentation

## Overview
This document describes the architectural improvements made to the SyncTask Flutter application to follow proper architecture patterns and improve code maintainability.

## Project Structure

```
lib/
├── config/
│   └── app_theme.dart              # Centralized theme configuration
├── constants/
│   ├── app_colors.dart             # Color constants
│   ├── app_sizes.dart              # Size and spacing constants
│   └── app_text_styles.dart        # Text style constants
├── widgets/
│   └── common/
│       ├── app_card.dart           # Reusable card widget
│       ├── custom_checkbox.dart    # Custom checkbox widget
│       ├── loading_indicator.dart  # Loading indicator widget
│       ├── page_header.dart        # Page header widget
│       ├── priority_badge.dart     # Priority badge widget
│       └── user_avatar.dart        # User avatar widget
├── screens/                        # All screen files (refactored)
├── cubits/                         # State management
├── models/                         # Data models
└── main.dart                       # App entry point
```

## Architecture Principles

### 1. Separation of Concerns
- **Constants**: All hardcoded values (colors, sizes, text styles) are centralized in dedicated files
- **Theme**: Theme configuration is extracted into a single file
- **Common Widgets**: Reusable UI components are extracted into separate widgets

### 2. DRY (Don't Repeat Yourself)
- Common UI patterns are extracted into reusable widgets
- Theme data is defined once and used throughout the app
- Constants are defined in one place and referenced everywhere

### 3. Single Source of Truth
- All colors are defined in `app_colors.dart`
- All sizes are defined in `app_sizes.dart`
- All text styles are defined in `app_text_styles.dart`
- Theme is defined in `app_theme.dart`

## Constants

### AppColors (`lib/constants/app_colors.dart`)
Defines all colors used in the app:
- Primary colors (primary, secondary)
- Background colors (background, surface, surfaceDark)
- Text colors (textPrimary, textSecondary, textTertiary)
- Status colors (success, error, warning, info)
- Priority colors (priorityHigh, priorityMedium, priorityLow)
- Helper methods for colors with opacity

### AppSizes (`lib/constants/app_sizes.dart`)
Defines all size constants:
- Padding and margins (XXS to XXXL)
- Border radius (XS to XL)
- Icon sizes (XS to XXXL)
- Avatar sizes (SM to LG)
- Button heights
- Progress indicator dimensions
- Elevation values

### AppTextStyles (`lib/constants/app_text_styles.dart`)
Defines all text styles:
- Headings (h1 to h4)
- Body text (bodyLarge, bodyMedium, bodySmall)
- Captions and labels
- Button text styles
- Special text styles (subtitle, overline, appTitle)

## Theme Configuration

### AppTheme (`lib/config/app_theme.dart`)
Centralized theme configuration that includes:
- Color scheme
- AppBar theme
- Input decoration theme
- Button themes (Elevated, Outlined, Text)
- Icon theme
- Card theme
- Dialog theme
- Text theme
- Progress indicator theme
- Divider theme

**Usage:**
```dart
MaterialApp(
  theme: AppTheme.darkTheme,
  ...
)
```

## Common Widgets

### AppCard
A reusable card widget with consistent styling.

**Features:**
- Consistent padding, margin, and border radius
- Optional onTap callback
- Customizable color and border

**Usage:**
```dart
AppCard(
  margin: EdgeInsets.only(bottom: AppSizes.paddingSM),
  child: YourWidget(),
)
```

### CustomCheckbox
A custom checkbox widget with consistent styling.

**Features:**
- Customizable size and colors
- Consistent appearance across the app

**Usage:**
```dart
CustomCheckbox(
  isChecked: isCompleted,
  onTap: () => toggleCompletion(),
)
```

### PageHeader
A reusable page header widget with title and optional subtitle.

**Features:**
- Consistent title and subtitle styling
- Optional action widget (buttons, etc.)

**Usage:**
```dart
PageHeader(
  title: 'My Tasks',
  subtitle: '5 of 10 completed',
  action: ElevatedButton(...),
)
```

### UserAvatar
A circular avatar widget with letter display.

**Features:**
- Customizable radius and colors
- Automatic font size scaling

**Usage:**
```dart
UserAvatar(
  letter: user.avatarLetter,
  radius: AppSizes.avatarMD,
)
```

### PriorityBadge
A badge widget for displaying task priorities.

**Features:**
- Automatic color mapping (High: red, Medium: orange, Low: green)
- Consistent styling

**Usage:**
```dart
PriorityBadge(priority: task.priority)
```

### LoadingIndicator
A custom loading indicator widget.

**Features:**
- Customizable size and color
- Consistent appearance

**Usage:**
```dart
LoadingIndicator()
```

## Benefits of This Architecture

### 1. Maintainability
- Easy to update colors, sizes, or styles across the entire app
- Changes in one place reflect everywhere
- Clear structure makes it easy to find code

### 2. Consistency
- All screens use the same colors, sizes, and styles
- Common widgets ensure UI consistency
- Reduced risk of styling inconsistencies

### 3. Scalability
- Easy to add new screens using existing components
- New developers can quickly understand the structure
- Reusable components reduce development time

### 4. Testability
- Common widgets can be tested independently
- Constants make it easy to test with different values
- Clear separation of concerns

### 5. Performance
- Reduced code duplication
- Smaller bundle size
- Easier to optimize specific components

## Screen Refactoring

All screens have been refactored to use:
- Constants instead of hardcoded values
- Common widgets instead of duplicated code
- Centralized theme instead of inline styles

### Example Refactoring

**Before:**
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFF1E1E1E),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
  ),
  child: Text(
    'Title',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
)
```

**After:**
```dart
AppCard(
  child: Text('Title', style: AppTextStyles.bodyLarge),
)
```

## Best Practices

### When Adding New Features

1. **Colors**: Add new colors to `app_colors.dart`
2. **Sizes**: Add new sizes to `app_sizes.dart`
3. **Text Styles**: Add new text styles to `app_text_styles.dart`
4. **Common UI Patterns**: Extract into reusable widgets in `widgets/common/`
5. **Theme Updates**: Update `app_theme.dart` for theme-level changes

### Code Review Checklist

- [ ] No hardcoded colors (use `AppColors`)
- [ ] No hardcoded sizes (use `AppSizes`)
- [ ] No inline text styles (use `AppTextStyles`)
- [ ] Common patterns extracted into reusable widgets
- [ ] Consistent naming conventions
- [ ] No duplicate code

## Migration Guide

If you need to add new screens or modify existing ones:

1. Import the necessary constants:
   ```dart
   import '../constants/app_colors.dart';
   import '../constants/app_sizes.dart';
   import '../constants/app_text_styles.dart';
   ```

2. Import common widgets:
   ```dart
   import '../widgets/common/app_card.dart';
   import '../widgets/common/page_header.dart';
   // ... other widgets
   ```

3. Replace hardcoded values with constants
4. Use common widgets instead of custom implementations
5. Follow the patterns used in existing screens

## Conclusion

This architecture provides a solid foundation for the SyncTask app, making it easier to maintain, extend, and collaborate on. The centralized constants and common widgets ensure consistency and reduce duplication, while the clear structure makes the codebase more approachable for new developers.

