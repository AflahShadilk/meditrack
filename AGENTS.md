# MediTrack - Architecture and Rules

PROJECT:
MediTrack Medicine Reminder

ARCHITECTURE:
Feature-first Clean Architecture.

STATE MANAGEMENT:
BLoC only.

DATA:
Hive offline-first.

NOTIFICATIONS:
flutter_local_notifications.

NAVIGATION:
go_router.

RESPONSIVE:
LayoutBuilder through centralized ResponsiveLayout.

UI:
Material 3 and centralized design system.

CODING STYLE:
Beginner-friendly, readable Dart.

NAMING:
lower_snake_case files.
UpperCamelCase classes.
lowerCamelCase variables/methods.

RULE:
No business logic inside widgets.

RULE:
No setState for application state.

RULE:
No Riverpod, Provider, GetX or alternative state management.

RULE:
Do not directly access Hive from presentation.

RULE:
Do not directly call notification APIs from widgets.

RULE:
Use repositories and use cases for feature business logic.

RULE:
Do not over-engineer.

RULE:
Do not introduce packages without a reason.

RULE:
Use LayoutBuilder for responsive page layouts.

RULE:
Reuse centralized design components.

RULE:
Do not duplicate page layout structures.

RULE:
Historical DoseOccurrence data must eventually be treated as immutable snapshots.

RULE:
Ongoing medicines must eventually use rolling scheduling rather than unlimited future records.

RULE:
Every future notification must map to an individual DoseOccurrence.

MODULE DEVELOPMENT ORDER:
1. Project Foundation
2. Medicine Management
3. Dose Occurrence Generation
4. Dashboard
5. Notification System
6. Reminder Actions
7. History
8. Settings
9. Ongoing Medicine / Scheduling Recovery
10. Testing / Polish / Release
