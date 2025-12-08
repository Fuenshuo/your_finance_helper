=== DEPENDENCY ANALYSIS FOR FLUX LEDGER CLEANUP ===

## Unified Transaction Entry Screen Dependencies

### Direct Imports from unified_transaction_entry_screen.dart:


#### Core Models (MUST PRESERVE):
- `core/models/account.dart` - Account data structures
- `core/models/flux_view_state.dart` - Timeframe and pane state management  
- `core/models/insights_drawer_state.dart` - Insights drawer state
- `core/models/parsed_transaction.dart` - AI-parsed transaction data
- `core/models/transaction.dart` - Transaction data structures

#### Core Providers (MUST PRESERVE):
- `core/providers/account_provider.dart` - Account state management
- `core/providers/budget_provider.dart` - Budget state management
- `core/providers/flux_providers.dart` - Flux-specific state management
- `core/providers/stream_insights_flag_provider.dart` - Feature flags
- `core/providers/theme_provider.dart` - Theme state management
- `core/providers/theme_style_provider.dart` - Theme style management
- `core/providers/transaction_provider.dart` - Transaction state management

#### AI Services (MUST PRESERVE):
- `core/services/ai/natural_language_transaction_service.dart` - AI parsing functionality
- `core/services/user_income_profile_service.dart` - Income profile management

#### Theme & Design (MUST PRESERVE):
- `core/theme/app_design_tokens.dart` - Design token system
- `core/theme/app_theme.dart` - App theming

#### Utils (MUST PRESERVE):
- `core/utils/logger.dart` - Logging functionality
- `core/utils/performance_monitor.dart` - Performance monitoring

#### Widgets (MUST PRESERVE):
- `core/widgets/app_primary_button.dart` - Primary button component
- `core/widgets/app_selection_controls.dart` - Selection controls
- `core/widgets/app_shimmer.dart` - Loading shimmer effects

#### Features (MUST PRESERVE):
- `features/insights/services/stream_insights_analysis_service.dart` - Insights analysis


### Broader Dependency Analysis

Total Dart files with internal imports: 194


### Critical Dependency Categories for unified_transaction_entry_screen

#### Category 1: Direct Imports (37 imports identified)
- 4 Dart SDK imports (async, collection, math, ui)
- 12 Flutter/framework imports
- 5 core model imports
- 6 core provider imports
- 2 AI service imports
- 2 theme imports
- 2 utility imports
- 3 widget imports
- 1 feature service import

### Dependency Preservation Strategy

1. **Pre-cleanup Phase**: Identify all files in categories marked MUST PRESERVE
2. **Cleanup Phase**: Move non-essential files to legacy/ first
3. **Restoration Phase**: Copy back MUST PRESERVE files from legacy/ to active lib/
4. **Verification Phase**: Ensure unified_transaction_entry_screen builds and functions
5. **Path Update Phase**: Fix any import paths referencing moved files

### Risk Mitigation
- Backup branch created before any destructive operations
- Incremental commits after each major phase
- unified_transaction_entry_screen tested after each restoration step
