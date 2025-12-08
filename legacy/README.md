# Legacy Code Archive

**Date**: December 8, 2025
**Purpose**: Archive of non-Flux Ledger functionality moved during cleanup process
**Cleanup Branch**: 001-flux-ledger-cleanup

## Overview

This directory contains all code and assets that were moved from the active codebase during the Flux Ledger cleanup process. The cleanup follows Elon Musk's First Principles methodology:

1. **Question every requirement** - Audit what truly belongs in Flux Ledger
2. **Delete anything not absolutely necessary** - Move non-Flux code to legacy
3. **Simplify and optimize what's left** - Streamline remaining Flux code

## Retention Rationale

### What Was Retained in Active Codebase
- **Flux Ledger Core**: main_flux.dart, flux_router.dart, flux_navigation_screen.dart
- **Unified Transaction Entry Screen**: Complete AI-powered transaction entry functionality
- **Essential Dependencies**: Providers, services, themes required by retained features
- **Build Infrastructure**: pubspec.yaml, analysis_options.yaml, basic project structure

### What Was Moved to Legacy
- Traditional entry points (main.dart, main_simple.dart)
- Family info management features
- Financial planning modules
- Transaction flow screens (except unified_transaction_entry_screen)
- Demo and test screens
- Non-Flux related utilities and widgets

## Archive Structure

```
legacy/
├── README.md                    # This file - archive documentation
├── dependencies.md             # Dependency preservation plan (to be created)
├── main.dart                    # Traditional app entry point
├── main_simple.dart            # Simplified app entry point
├── features/
│   ├── family_info/            # Family information management
│   ├── financial_planning/     # Financial planning modules
│   └── transaction_flow/       # Transaction flow screens
├── screens/                    # Traditional screens
├── core/                       # Non-Flux core components
├── widgets/                    # Non-Flux widgets
├── services/                   # Non-Flux services
├── theme/                      # Non-Flux theme components
└── [other directories]         # Additional archived components
```

## Restoration Process

If any archived functionality needs to be restored:

1. **Identify Dependencies**: Check dependencies.md for required components
2. **Copy Back**: Move files from legacy/ back to appropriate lib/ locations
3. **Update Imports**: Fix any import path references
4. **Test Functionality**: Verify restored features work correctly

## Contact

For questions about this archive or restoration needs, refer to the cleanup specification:
- **Spec**: specs/001-flux-ledger-cleanup/spec.md
- **Tasks**: specs/001-flux-ledger-cleanup/tasks.md
- **Branch**: 001-flux-ledger-cleanup

## Cleanup Statistics

*To be updated during cleanup process*

- **Files Moved**: [TBD]
- **Directories Archived**: [TBD]
- **Import Paths Updated**: [TBD]
- **Git Tracking Removed**: [TBD]
