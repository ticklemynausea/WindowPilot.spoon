# WindowPilot.spoon Improvement Plan

## Overview
This document outlines identified issues and planned improvements for WindowPilot.spoon, a Hammerspoon window management tool.

## Phase 1: Code Quality & Foundation (High Priority)

### Current Code Quality Issues

#### 1. ✅ Inconsistent Logging/Alerts (COMPLETED)
**Problem**: Mixed debugging and user notification approaches
- ✅ **Debug prints**: Replaced 6 `print()` statements with configurable logging system
- ✅ **Alert inconsistency**: Standardized all alerts to use `wp:showNotification()` method
- ✅ **Log levels**: Added DEBUG, INFO, WARN, ERROR levels with configurable verbosity

**Files affected**: `init.lua`, `switchWindow.lua`, `windowMovement.lua`, `windowLayout.lua`
**Solution**: Added `wp:logMessage()` and `wp:showNotification()` methods with configuration

#### 2. ✅ Error Handling Problems (COMPLETED)
**Problem**: Inconsistent and poor error handling throughout codebase
- ✅ **Parameter validation**: Added validation to critical functions like `switchToApp()` and `showNotification()`
- ✅ **Consistent messaging**: Standardized all user-facing messages through `wp:showNotification()`
- ✅ **Configuration validation**: Added `wp:validateConfiguration()` with fallbacks
- **Error locations** (now fixed):
  - `windowMovement.lua`: Standardized 5 error messages
  - `switchWindow.lua`: Added input validation for 3 error scenarios
  - `windowLayout.lua`: Unified 4 "No windows" error cases

**Solution**: Added input validation and `wp:validateConfiguration()` method

#### 3. ✅ Configuration Limitations (COMPLETED)
**Problem**: Very limited configurability
- ✅ **Expanded settings**: Added `logLevel`, `windowSizes`, `cascadeOffset`, `notificationDuration`
- ✅ **Magic numbers**: Extracted hardcoded values to configuration:
  - `windowMovement.lua`: Window and center sizes now configurable
  - `windowLayout.lua`: Cascade offset now configurable
  - Notification duration now configurable
- ✅ **Configuration validation**: Added validation with fallbacks in `wp:validateConfiguration()`

**Solution**: Expanded configuration object and extracted all magic numbers

#### 4. Missing Documentation
**Problem**: Lack of inline documentation and API references
- **Function docs**: 31 functions across 6 files with zero inline documentation
- **Parameter descriptions**: No information about valid inputs/outputs
- **Usage examples**: Limited beyond basic README configuration

#### 5. Code Organization Issues
**Problem**: Repeated patterns and inconsistent structure
- **Repeated calculations**: Margin handling duplicated in multiple files
- **No constants**: Magic numbers scattered instead of centralized
- **Inconsistent naming**: Mixed camelCase conventions
- **File complexity**: `windowLayout.lua` at 340 lines is getting unwieldy

### Priority Files for Phase 1 Improvements

1. **windowLayout.lua** (340 lines)
   - Most complex file with 11 functions
   - Multiple layout algorithms with repeated patterns
   - Heaviest use of magic numbers and calculations

2. **windowMovement.lua** (195 lines)
   - 5 different error alert messages
   - Hardcoded size presets that should be configurable
   - Complex space/screen movement logic

3. **init.lua** (90 lines)
   - 4 debug print statements
   - Central configuration loading
   - Key binding management

## Phase 2: User Experience Enhancements (Medium Priority)

### Planned Improvements
1. **Visual feedback system** - Layout previews before application
2. **Undo/redo functionality** - Track and revert window changes
3. **Window filtering** - Exclude specific apps/window types
4. **Better notifications** - User-friendly status messages
5. **Layout persistence** - Save/restore arrangements

## Phase 3: Advanced Features (Medium Priority)

### Planned Improvements
1. **Custom layout engine** - User-defined layout algorithms
2. **Performance optimization** - Caching and efficient calculations
3. **Enhanced multi-monitor** - Better complex display handling
4. **Animation system** - Smooth transitions
5. **Workspace integration** - macOS Spaces awareness

## Phase 4: Development Infrastructure (Lower Priority)

### Planned Improvements
1. **Testing framework** - Unit and integration tests
2. **API documentation** - Comprehensive function reference
3. **Configuration validation** - Input checking and defaults
4. **Modular configuration** - Organized settings structure
5. **Version management** - Proper semantic versioning

## Implementation Strategy

### ✅ Phase 1 Progress (4/5 COMPLETED)
1. ✅ Create logging system with configurable levels
2. ✅ Add comprehensive error handling framework
3. ✅ Expand configuration options for magic numbers
4. ✅ Add parameter validation to critical functions
5. 🔄 Extract constants and common utilities (PARTIAL - main magic numbers done)

### Ready for Phase 2: User Experience Enhancements

### Success Metrics
- Zero hardcoded magic numbers
- Consistent error handling across all modules
- Configurable logging levels
- Documented API for all public functions
- Input validation for all user-facing functions

## Notes
- Current codebase: ~900 lines across 7 Lua files
- 31 total functions identified
- Recent fix: switchWindowForward/Backward functions restored (commit 04947ce)
- Code formatting: Uses stylua with 2-space indentation