# PrepPal Stockpile Enhancement Plan

This document outlines the plan for enhancing PrepPal's stockpile management with gamified progress tracking and offline-first capabilities.

## 1. Research Daily Needs (Summary)

*   **Water:**
    *   Minimum: 2-4 liters per person per day.
    *   Source: General emergency preparedness guidelines.
    *   For calculation, a default of **3 liters/person/day** will be used, with potential for user customization.
*   **Food:**
    *   Minimum: 1 "day of food" unit per person per day (simplified metric).
    *   Source: General emergency preparedness guidelines.
    *   This simplified metric is suitable for gamified progress. Conversion of various food items to this unit will be defined.
*   **Other Supplies:**
    *   **First Aid, Sanitation, Tools, Documents, Medication:** These categories are generally stocked as kits or individual items. They do not have easily quantifiable "daily minimums" for survival duration.
    *   **Gamified Progress:** Tracking for these categories will focus on the completeness of a recommended checklist (e.g., "First Aid Kit: 80% complete") rather than "days of supply."

## 2. Unit Categorization & Calculation Logic

The goal is to convert the `quantity` and `unit` of 'Food' and 'Water' items into a "days of supply" metric.

*   **A. Unit Review & Proposed Categorization:**
    *   Existing Units: 'pcs', 'kg', 'g', 'L', 'mL', 'can', 'bottle', 'box', 'roll', 'tube', 'kit', 'set', 'other'.
    *   **Sub-Categorization for Food/Water:**
        *   **Directly Measurable (Volume/Weight):**
            *   Water: 'L', 'mL'
            *   Food: 'kg', 'g'
        *   **Container/Countable Units (requiring user-defined conversion):**
            *   Water: 'bottle', 'can'
            *   Food: 'pcs', 'can', 'bottle', 'box'
        *   **Inapplicable for Food/Water "Days of Supply" Calculation:**
            *   'roll', 'tube', 'kit', 'set', 'other' (unless 'other' is specified convertibly).

*   **B. Calculation Logic for "Days of Supply":**
    *   **Water:**
        *   **'L', 'mL':** Direct conversion: `days_of_water = (quantity * unit_in_liters) / daily_water_need_per_person`.
        *   **'bottle', 'can':** Prompt user for "Volume per unit" (e.g., Liters per bottle) to be stored with the item.
    *   **Food:**
        *   **'kg', 'g', 'pcs', 'can', 'bottle', 'box':** User defines the "days of food" equivalence.
            *   Example prompt: "This item is [Item Name] ([Quantity] [Unit]). How many 'days of supply' does this represent for one person?"
            *   This conversion factor (total days of supply for the item quantity) will be stored per item.
    *   **User-Defined Conversion Factors:** Essential for Food and some Water units. The UI will prompt for this information during item addition/editing.

*   **C. Guiding Users & Restricting Units:**
    *   When 'Food' or 'Water' category is selected, the unit dropdown should filter/deprioritize inapplicable units.
    *   Warnings or disabled "days of supply" fields if an inappropriate unit is chosen.
    *   Helper text to guide users (e.g., "Please specify how many pieces constitute one day's food supply").

## 3. Data Model & Milestones

*   **A. `StockpileItem` Model Changes:**
    *   Consider adding fields to `StockpileItem` to support calculations:
        *   `double? unitVolumeLiters;` (For water containers: Liters per bottle/can)
        *   `double? totalDaysOfSupplyPerItem;` (Directly stores the user-defined or calculated total days of supply this item instance provides for one person. This is preferred for simplicity and direct use in gamification).
        *   `DateTime? updatedAt;` (To track last modification for sync purposes).
    *   The `addedDate` field can serve as `createdAt`.

*   **B. Storing and Tracking Progress Towards Milestones:**
    *   **Milestones:** 3 days, 15 days, 30 days, 60 days, up to 3 years for food/water. These values will be constants.
    *   **Tracking Scope:** Global progress for the user.
        *   `total_food_days = sum(item.totalDaysOfSupplyPerItem for item in stockpile where category == 'Food' and userId == currentUserId)`
        *   `total_water_days = sum(item.totalDaysOfSupplyPerItem for item in stockpile where category == 'Water' and userId == currentUserId)`
    *   **Storage of Achieved Milestones:**
        *   Locally (e.g., `SharedPreferences` or local DB) for quick UI updates (badges).
        *   In Firestore (user profile or `userProgress` collection) for persistence (e.g., `achievedFoodMilestone: 30`).
    *   **Number of People:** A user-configurable setting (`number_of_people_in_household`) stored in user preferences/profile will be used to calculate effective days of supply:
        *   `effective_days_of_supply = total_calculated_days_for_one_person / number_of_people_in_household`

## 4. Offline-First Strategy

*   **A. Local Database Choice:**
    *   **SQLite via `expo-sqlite`** is recommended for structured stockpile data.
    *   `AsyncStorage` for simpler settings/flags.

*   **B. Data Flow:**
    1.  **UI Interaction -> Write to Local SQLite DB** (item marked "needsSync"). UI updates immediately.
    2.  **Sync to Firestore:** Background process checks "needsSync" items. If online, attempts to write/update to Firestore. Clear "needsSync" on success.
    3.  **Data Fetching:** Primarily read from local SQLite. If online, fetch updates from Firestore in the background to update local SQLite.

*   **C. Conflict Handling:**
    *   **Offline Data Takes Precedence:**
        *   Strategy: Last Write Wins (LWW), where the local offline change is considered the latest if a conflict occurs during sync.
        *   When syncing, if local `updatedAt` is newer than Firestore's `updatedAt` (or if offline always wins is implemented), local overwrites Firestore.
    *   **Timestamps:** `createdAt` (from `addedDate`) and `updatedAt` fields are crucial for each record.

*   **D. Detecting Internet Connection for Syncing:**
    *   Use a package like `connectivity_plus`.
    *   Attempt syncs only when online. Listen to connectivity changes.