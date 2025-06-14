# AI Comment Cleanup Plan

This document outlines the plan to identify and remove/replace AI-generated comments from the PrepPal project's codebase.

## Target File Structure (Code & Key Config Files)

The following ASCII chart represents the structure of the files that will be reviewed:

```
<project_root>/
├── .gitignore
└── preppal/
    ├── .gitignore
    ├── analysis_options.yaml
    ├── pubspec.yaml
    ├── assets/
    │   └── sounds/
    │       └── milestone_achieved.wav  (*Note: Binary file, unlikely to contain reviewable comments*)
    ├── lib/
    │   ├── firebase_options.dart
    │   ├── main.dart
    │   ├── models/
    │   │   ├── stockpile_item.dart
    │   │   ├── user_preferences.dart
    │   │   └── user_profile.dart
    │   ├── providers/
    │   │   └── profile_providers.dart
    │   ├── screens/
    │   │   ├── home_screen.dart
    │   │   ├── login_screen.dart
    │   │   ├── settings_screen.dart
    │   │   ├── alerts/
    │   │   │   └── simulated_alert_screen.dart
    │   │   ├── preparedness_hub/
    │   │   │   └── hcmc_risk_info_screen.dart
    │   │   ├── profile/
    │   │   │   └── edit_profile_screen.dart
    │   │   ├── tabs/
    │   │   │   ├── add_edit_stockpile_item_dialog.dart
    │   │   │   ├── alerts_tab.dart
    │   │   │   ├── community_tab.dart
    │   │   │   ├── dashboard_tab.dart
    │   │   │   ├── preparedness_hub_tab.dart
    │   │   │   ├── profile_tab.dart
    │   │   │   ├── stockpile_tab.dart
    │   │   │   └── widgets/
    │   │   │       └── resource_progress_bar.dart
    │   │   └── well_being/
    │   │       └── climate_anxiety_support_screen.dart
    │   ├── services/
    │   │   ├── firestore_service.dart
    │   │   ├── local_preference_service.dart
    │   │   ├── profile_service.dart
    │   │   └── stockpile_repository.dart
    └── test/
        └── widget_test.dart
```

## Workflow Diagram

```mermaid
graph TD
    A[Start: User Request for Comment Cleanup] --> B{Phase 1: Planning (Architect Mode)};
    B --> C[Identify Target Code Files & Configs];
    C --> D[Generate ASCII File Structure Chart];
    D --> E[Outline Comment Review Strategy];
    E --> F{Present Plan & Chart to User};
    F -- Approve? --> G{User Approves Plan};
    G --> H{Save Plan to MD};
    H --> I{Switch to Code Mode};
    I --> J{Phase 2: Implementation (Code Mode)};
    J --> K[Iterate Through Files: Read];
    K --> L[Identify AI-like Comments];
    L --> M[Propose Changes];
    M -- Approve Changes? --> N[Apply Changes];
    N --> K;
    K -- All Files Processed? --> O[Final Review];
    O --> P[End: Comments Cleaned];
```

## Plan Summary

### Phase 1: Information Gathering & Planning (Architect Mode - Completed)
1.  **Identify Target Files:** Focused on code files within `lib/`, `assets/` (excluding binaries), `test/`, and key configuration files (`pubspec.yaml`, `.gitignore` files, `analysis_options.yaml`).
2.  **Generate ASCII File Structure Chart:** Created and approved.
3.  **Outline Comment Review Strategy:** The primary goal is to identify and remove/replace AI-generated comments, particularly those using "you," "your," or overly conversational tones.
4.  **Present Plan & Chart:** Plan approved by the user.
5.  **Save Plan:** This Markdown file.

### Phase 2: Implementation (Code Mode - Next)
1.  **Switch to Code Mode.**
2.  **Iterate Through Files:**
    *   For each text-based file identified in the ASCII chart:
        *   Read the file content.
        *   Identify comments matching the "AI-generated" criteria.
        *   Propose changes (deletion or replacement).
        *   Apply changes upon user approval.
3.  **Final Review:** Once all targeted files are processed, seek final confirmation.