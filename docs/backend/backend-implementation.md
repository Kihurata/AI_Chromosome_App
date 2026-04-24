# Backend Implementation Plan (Flutter Core/Domain/Data/Logic)

## Overview
Implement the non-UI layers (`core`, `domain`, `data`, `logic`) for the Flutter Web project based on the Clean Architecture structure defined in `docs/core/implementation_plan.md`. This plan ensures the foundation is solid before any UI screens are built.

## Project Type
MOBILE (Flutter Clean Architecture)

## Success Criteria
- Core network (`Dio`), Dependency Injection (`get_it`), and routing mechanisms (`go_router`) are fully functional.
- Domain entities and repository interfaces accurately reflect the business rules.
- Data models, datasources, and repository implementations successfully map to the defined API endpoints.
- Logic layer (BLoC/Cubit) is implemented and correctly manages application state and role-based access.

## Tech Stack
- **State Management**: `flutter_bloc`
- **Networking**: `dio`
- **Routing**: `go_router`
- **Dependency Injection**: `get_it`, `injectable`
- **Data Mapping**: `freezed`, `json_serializable`
- **Functional Programming**: `dartz` (for `Either` error handling)

## File Structure
Following the structure defined in `docs/core/implementation_plan.md`:
- `lib/core/`
- `lib/domain/`
- `lib/data/`
- `lib/logic/`

## Task Breakdown

### Phase 1: Core Foundation (P0) 
| Task ID | Name | Agent | Skill | Priority | Dependencies | INPUT → OUTPUT → VERIFY |
|---|---|---|---|---|---|---|
| B1 | Setup DI & Network | `mobile-developer` | `flutter-architecting-apps` | P0 | None | IN: Base API URL → OUT: `core/network/` & `core/di/` setup → VERIFY: Dio instance injects successfully. |
| B2 | Setup Error Handling | `mobile-developer` | `flutter-architecting-apps` | P0 | None | IN: API Error format → OUT: `core/errors/` Failure classes → VERIFY: Map Dio exceptions to Failures. |
| B3 | Routing Foundation | `mobile-developer` | `flutter-implementing-navigation-and-routing` | P0 | None | IN: Role logic → OUT: `core/router/app_router.dart` with Route Guards → VERIFY: Redirects based on user role. |

### Phase 2: Domain Layer (P1)
| Task ID | Name | Agent | Skill | Priority | Dependencies | INPUT → OUTPUT → VERIFY |
|---|---|---|---|---|---|---|
| B4 | Entities & Models | `mobile-developer` | `flutter-handling-http-and-json` | P1 | None | IN: JSON schemas → OUT: `domain/entities/` and `data/models/` → VERIFY: `fromJson`/`toJson` generation passes. |
| B5 | Repository Interfaces | `mobile-developer` | `flutter-architecting-apps` | P1 | B4 | IN: Endpoints list → OUT: `domain/repositories/` → VERIFY: Abstract classes match API specs. |
| B6 | Usecases Setup | `mobile-developer` | `flutter-architecting-apps` | P1 | B5 | IN: Business logic → OUT: `domain/usecases/` → VERIFY: Logic calls repository methods correctly. |

### Phase 3: Data Layer (P1)
| Task ID | Name | Agent | Skill | Priority | Dependencies | INPUT → OUTPUT → VERIFY |
|---|---|---|---|---|---|---|
| B7 | API DataSources | `mobile-developer` | `flutter-handling-http-and-json` | P1 | B1, B4 | IN: Dio client → OUT: `data/datasources/` → VERIFY: HTTP calls return mapped Models. |
| B8 | Repository Impl | `mobile-developer` | `flutter-architecting-apps` | P1 | B5, B7 | IN: DataSources → OUT: `data/repositories/` → VERIFY: Returns `Either<Failure, Entity>`. |

### Phase 4: Logic Layer (P1)
| Task ID | Name | Agent | Skill | Priority | Dependencies | INPUT → OUTPUT → VERIFY |
|---|---|---|---|---|---|---|
| B9 | Auth BLoC | `mobile-developer` | `flutter-managing-state` | P1 | B8 | IN: Login Usecase → OUT: `logic/auth/auth_bloc.dart` → VERIFY: State updates `userRole`. |
| B10 | Feature BLoCs | `mobile-developer` | `flutter-managing-state` | P1 | B8 | IN: Feature Usecases → OUT: `logic/patient/`, `logic/appointment/`, etc. → VERIFY: State transitions (Loading/Loaded/Error). |

## Phase X: Verification
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
