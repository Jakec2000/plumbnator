# Plumbnator Production Upgrade: GoRouter, Splash Screen & Error Handling

This plan outlines the next phase of modernization for Plumbnator, transitioning the application from a custom Riverpod-based navigation shell to the robust, industry-standard `go_router`. It also introduces essential production-grade features: a branded splash screen and global error bounds.

## User Review Required

> [!IMPORTANT]
> **GoRouter Adoption:** This will fundamentally change how the app handles navigation. All `Navigator.push` and `ref.read(navProvider.notifier).setIndex()` calls will be migrated to declarative `context.go()` paths.
> **Dependency Update:** I will need to add the `go_router` and `flutter_native_splash` packages to your `pubspec.yaml`.

## Open Questions

> [!WARNING]
> Do you have any specific branding assets (e.g., logo, specific HEX color background) that you want explicitly set for the native Splash Screen? If not, I will use a premium default (Cyan/Dark Blue) matching your current Plumbnator aesthetic.

## Proposed Changes

---

### Navigation Architecture (`go_router`)

We will replace the custom `NavigationShell` in `main.dart` with a robust `StatefulShellRoute`. This enables deep linking and keeps the bottom navigation bar/sidebar persistent across nested routes.

#### [NEW] `lib/router/app_router.dart`
- Centralizes all routing definitions.
- Configures a `GoRouter` instance with paths for `/operations`, `/sizers`, `/field-docs`, and `/compliance`.
- Incorporates a `StatefulShellRoute` to wrap the active view inside the bottom navigation bar and sidebar.

#### [MODIFY] `lib/main.dart`
- Replace `home: const NavigationShell()` with `routerConfig: appRouter`.
- Add global exception handling to the app boundary (e.g., `FlutterError.onError`).

#### [MODIFY] `lib/widgets/navigation/sidebar_rail.dart` & `app_drawer.dart`
- Replace Riverpod `navProvider` index updates with `context.goBranch()` or `context.go()` calls to navigate cleanly.

---

### Production Readiness (Splash & Error Handling)

#### [NEW] `pubspec.yaml`
- Add `go_router: ^14.1.0`
- Add `flutter_native_splash: ^2.4.0`

#### [NEW] `flutter_native_splash.yaml` (Project Root)
- Defines the native splash screen colors and branding for iOS, Android, and Web to avoid the blank white screen during Firebase/app initialization.

#### [NEW] `lib/views/error/global_error_view.dart`
- A premium, branded error fallback screen that catches any routing or render errors, ensuring the user doesn't see the dreaded "Red Screen of Death" in production.

## Verification Plan

### Automated Tests
- Run `flutter pub get` and `flutter analyze` to ensure the new routing logic compiles flawlessly.

### Manual Verification
- Launch the app on Chrome/Web to verify deep linking URLs (e.g., `http://localhost:9090/#/sizers`) route directly to the correct tab.
- Test responsive resizing to ensure the `StatefulShellRoute` correctly displays either the `AppDrawer`/`NavigationBar` on mobile or the `SidebarRail` on desktop.
- Verify the splash screen appears on boot.

---

### Feature: PDF Export for Quote Generator

As requested, we will add a "Download PDF" button to the Quote Generator that allows saving the spatial quote (including BOM and compliance details) to files or photos.

#### [NEW] `lib/services/pdf_export_service.dart`
- Create a service that uses the `pdf` and `printing` packages (already in `pubspec.yaml`).
- Generate a beautifully branded PDF document using `PlumbingQuote` data.
- Include tables for the Bill of Materials and a section for AS/NZS compliance audits.

#### [MODIFY] `lib/views/hubs/ar_room_scanner_view.dart`
- Update the `_showQuoteDialog` or `_buildQuoteActionButtons` to include a "Download PDF" button.
- Wire the button to the `PdfExportService` and trigger `Printing.sharePdf()` which invokes the native share/save dialog (allowing saving to Files or Photos).
