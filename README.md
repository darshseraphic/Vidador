## 1. EXECUTIVE MANIFESTO & SYSTEM ARCHITECTURE PHILOSOPHY

### 1.1 The Crisis of Gamified Biometrics
In the contemporary consumer software ecosystem, health and fitness tracking applications have degenerated into gamified dopamine loops. Modern biometrics trackers deploy hyper-saturated color gradients, continuous ring-closing animations, complex multi-axis graphical charts, arbitrary behavioral badges, and aggressive push notification loops. This layout strategy is explicitly engineered to capture user attention, maximizing interaction frequency under the guise of wellness optimization. 

Ironically, this design paradigm exacerbates the exact digital fatigue and screen addiction that health software should theoretically mitigate. The user is transformed from an autonomous operator monitoring biological trends into a reactive subject seeking external validation from micro-animations and psychological manipulation triggers.

### 1.2 The Vidador Antithesis: Air-Gapped Digital Minimalism
VIDADOR is an absolute structural break from this paradigm. It is an un-gamified, air-gapped, zero-telemetry biological tracking instrument designed for absolute user autonomy, self-discipline, and minimal screen exposure. Vidador treats biometric data not as a source of digital entertainment, but as a series of raw, cold quantitative matrix entries requiring clear processing.

The system explicitly rejects the visual aesthetics of the consumer web in favor of a strict, brutalist, type-driven structural system known as the **ROCEN Design Core**. By stripping out all ornamental decorations, round corners, smooth image backdrops, and interactive animations, Vidador reduces the interaction time to the absolute minimum necessary to record and review metrics. The application does not invite you to scroll; it commands you to log, audit, and return your attention to the physical world.

### 1.3 Strategic System Priorities
To maintain this ideological and technical baseline, Vidador enforces five foundational design laws:

1. **Absolute Textual Primacy:** Information must be communicated via raw typographic strings. Icons are strictly limited to structural utilities (such as closing windows or row termination) and must never be used for purely decorative purposes.
2. **Binary Interface Inversion:** The interface operates inside an absolute light or dark state switcher. There are no tertiary accent colors, pastel shades, or colorful states. The visual hierarchy is established entirely via structural typography sizing and thin line dividers.
3. **Air-Gapped Local Architecture:** The software operates under a strict zero-telemetry policy. There are no analytical scrapers, tracking cookies, cloud synchronization bridges, or background reporting agents. All data remains physically anchored within localized device sandbox storage arrays.
4. **Deterministic Interface Flow:** Screens do not feature layout transitions or unpredictable scrolling behaviors. Views are layered using deterministic grid indexing and rigid structures that align with the platform's hardware refresh rates.
5. **Friction-As-A-Feature:** Data entry is intentionally precise. Users are required to intentionally tap, log numeric metric segments, or verify mutations through high-contrast structural dialog modules, eliminating accidental logging and emphasizing conscious documentation.

 

## 2. THE ROCEN DESIGN CORE SYSTEM MATRIX

The visual identity of Vidador is dictated by the **ROCEN Design Core System Matrix**, a strict layout design token framework built directly into the Flutter rendering engine. This section defines the precise layout tokens, typographic boundaries, and color rules that ensure visual consistency across all components.

### 2.1 Typographic Layout Matrix & Casing Protocol
Typography within Vidador is treated as a structural layout element rather than ornamental text decoration. The application enforces a strict monospace typographic paradigm using the `Courier` font family or native monospace hardware fallbacks.


```

```text
SUCCESS: README.md file generated successfully.


```

+                       --+
|  TYPOGRAPHIC SPECIFICATION HIERARCHY                                  |
+                       --+
|  LEVEL        | FONT SIZE  | WEIGHT      | LETTER SPACING | CASING    |
+     +    +    -+     -+   --+
|  H1 Header    | 16 pt      | FontWeight  | -0.02 em       | UPPERCASE |
|  H2 Section   | 12 pt      | FontWeight  | 0.05 em        | UPPERCASE |
|  Body Text    | 13 pt      | FontWeight  | 0.01 em        | Standard  |
|  Technical Id | 11 pt      | FontWeight  | 0.04 em        | UPPERCASE |
|  Micro Action | 9.5 pt     | FontWeight  | 0.06 em        | UPPERCASE |
+                       --+

```

Every string that represents an interactive element, a navigation node, a section title, or a system status code must be formatted in **EXTREME UPPERCASE**. This creates a continuous, highly structured visual cadence that communicates system state shifts with absolute clarity. Mixed-case formatting is restricted exclusively to user-generated descriptions or historical log subtexts where long-form strings are necessary for context.

### 2.2 Pure Binary Theming Matrix & Contrast Token Specification
The visual landscape is governed by a pure, high-contrast, binary environment state manager accessed natively via a Riverpod state loop (`themeProvider`). The application completely bans gray-scale midtones for primary views, restricting color assignment to specific dark/light hexadecimal markers.


```

+                       --+
|  COLOR ARRAYS FOR DARK MODE MATRIX (is_dark_mode == true)             |
+                       --+
|  TOKEN ID       | SPECIFIC VALUE     | ARCHITECTURAL ROLE             |
+     --+      --+          --+
|  bgMain         | Color(0xFF000000)  | Root App Scaffold Canvas       |
|  containerBg    | Color(0xFF0F0F0F)  | Isolated Item Bounding Boxes   |
|  textMain       | Color(0xFFFFFFFF)  | Primary Typographic Strings    |
|  textSub        | Color(0xFF888888)  | Metadata and Courier Stamps    |
|  ruleBorder     | Color(0xFF1F1F1F)  | Micro Thin Boundary Dividers   |
|  inversionAlert | Color(0xFFFFFFFF)  | Active Alarm State Container   |
+                       --+

+                       --+
|  COLOR ARRAYS FOR LIGHT MODE MATRIX (is_dark_mode == false)            |
+                       --+
|  TOKEN ID       | SPECIFIC VALUE     | ARCHITECTURAL ROLE             |
+     --+      --+          --+
|  bgMain         | Color(0xFFFFFFFF)  | Root App Scaffold Canvas       |
|  containerBg    | Color(0xFFEEEEEE)  | Isolated Item Bounding Boxes   |
|  textMain       | Color(0xFF000000)  | Primary Typographic Strings    |
|  textSub        | Color(0xFF404040)  | Metadata and Courier Stamps    |
|  ruleBorder     | Color(0xFFE5E5E5)  | Micro Thin Boundary Dividers   |
|  inversionAlert | Color(0xFF000000)  | Active Alarm State Container   |
+                       --+

```

### 2.3 Structural Geometry & Line Dividers
Vidador enforces complete geometric linearity. The usage of `BorderRadius.circular` is banned across all core components. Every container card, interactive button, dialog interface, modal pane, and layout border must terminate in a sharp, non-decorative 90-degree angle (`BorderRadius.zero`).

Elements are separated by explicit bounding lines defined natively via:
```dart
Border.all(color: ruleBorder, width: 0.8)

```

and structural segment breaks managed through:

```dart
Divider(color: borderColor, height: 32, thickness: 0.8)

```

These parameters provide a strict spatial envelope that mimics architectural technical diagrams or early command-line interfaces.

### 2.4 Layout Layering & Viewports

To avoid layout compression anomalies when virtual system components (such as software keyboards) occur, Vidador deploys flat view constraints. Elements do not float dynamically over each other with soft drop-shadow parameters; instead, layered sheets completely obscure underlying viewports using absolute right-to-left or bottom-to-top layout blocks wrapped in sharp bounding structures.

 

## 3. ECOSYSTEM MODULES & FUNCTIONAL WORKFLOWS

Vidador partitions biological and metric tracking into five isolated functional views. Each view operates independently using dedicated Riverpod storage controllers.

```
       +                  -+
       |                  MAIN INTERFACE ROUTER                |
       +                  -+
                                  |
     +    +    +--+--+    -+   --+
     |            |            |               |           |
+   +  +   +  +   +  +     +  +   -+
|  SLEEP  |  |  WATER  |  |  STEPS  |  |  MEDITATION   |  | SETTING  |
| SCREEN  |  | SCREEN  |  | SCREEN  |  |    SCREEN     |  |  SCREEN  |
+   +  +   +  +   +  +     +  +   -+

```

### 3.1 `SleepScreen` — Circadian Rhythm Quantification Engine

#### 3.1.1 Purpose and Rationale

Sleep data is typically calculated by third-party wearable sensors that run persistent background analytics to guess sleep phases. Vidador rejects continuous sensor monitoring in favor of conscious declaration. The `SleepScreen` functions as a manual logging engine where the user registers sleep onset and wake events. This forces the user to actively reflect on their sleep schedule and morning recovery state.

#### 3.1.2 Internal Data Architecture & Modeling

The state of a circadian log is mapped using the `SleepSession` model class:

```dart
class SleepSession {
  final String id;
  final DateTime sleepTime;
  final DateTime? wakeTime;

  SleepSession({
    required this.id,
    required this.sleepTime,
    this.wakeTime,
  });
}

```

This enables a flexible dual-state architecture:

1. **Active Log State (`wakeTime == null`):** The session has been opened but not terminated. The user is actively recorded as being asleep.
2. **Archived Log State (`wakeTime != null`):** The session is complete, and the elapsed time difference can be calculated.

#### 3.1.3 Interface State Flow & User Input Handshake

When the screen is built, the system evaluates the state array for any unresolved sessions via the following logic:

```dart
final activeSessionIndex = sessions.indexWhere((s) => s.wakeTime == null);
final bool isSleeping = activeSessionIndex != -1;

```

This condition switches the user interface into one of two exclusive functional modes:

* **The Wake State Configuration:** The central display card reads `STATUS: WIDE AWAKE`. The execution button `[ SLEEP ]` is active, and the `[ WAKE ]` button is disabled. Tapping `[ SLEEP ]` captures a high-resolution local timestamp and generates a new `SleepSession` entry with a null wake timestamp, pushing it into the Hive storage pipeline. The app state shifts instantly.
* **The Sleep State Configuration:** The display card reflects `STATUS: RECORDING SLEEP CYCLE` and displays the exact tracking onset hour. The execution button `[ WAKE ]` becomes active, while `[ SLEEP ]` is disabled. Tapping `[ WAKE ]` completes the session, records the terminal timestamp, and calculates the absolute session duration.

```
+                  -+
| STATE: WIDE AWAKE                                     |
| Action: [ SLEEP ] struck -> Opens active log session   |
+                  -+
                           |
                           v
+                  -+
| STATE: RECORDING SLEEP CYCLE                          |
| Action: [ WAKE ] struck -> Records end timestamp       |
+                  -+
                           |
                           v
+                  -+
| ACTION: TRIGGER POPUP MODAL                          |
| Calculates delta -> Persists final session data to Hive|
+                  -+

```

#### 3.1.4 Metrics Processing Popup Matrix

When a sleep session finishes, the system triggers a custom high-contrast verification modal via `showGeneralDialog`. This overlay bypasses standard material patterns, displaying the computed sleep metrics in a clean structural box:

```dart
final Duration delta = wake.difference(sleep);
final String hours = delta.inHours.toString().padLeft(2, '0');
final String minutes = (delta.inMinutes % 60).toString().padLeft(2, '0');

```

The operator reviews the quantitative output and presses `LOG REGISTERED` to clear the viewport and return to the primary timeline history view.

#### 3.1.5 Chronological History Sequence

Completed sleep sessions flow sequentially into a structured log history list. Each item displays the historical date string formatted as `MMM dd, yyyy` on the left, the absolute timestamp sequence (`HH:mm > HH:mm`), and the computed duration on the right (`07H 45M`). An icon-driven row terminator (`Icons.close`) allows entries to be removed from local storage instantly.

 

### 3.2 `WaterScreen` — Hydration Fluid Tracking Matrix

#### 3.2.1 Purpose and Rationale

Optimal hydration is critical for cognitive processing and cellular recovery, yet tracking fluid intake is frequently cluttered with overly complex graphical water meters and animated glass filling effects. The `WaterScreen` simplifies this process into a clear ledger system that tallies intake volumes and maps real-time progress against a fixed daily requirement constraint ($3,000\text{ ML}$).

#### 3.2.2 Internal Data Architecture & Ledger Modeling

Individual intake operations are modeled as distinct, unchangeable entries via the `WaterEntry` class:

```dart
class WaterEntry {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  WaterEntry({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });
}

```

This architecture tracks intake using real-time transactions rather than single daily increment integers, allowing the system to log the exact time of each consumption event and support instant deletions of accidental logs.

#### 3.2.3 Volumetric Aggregate Processing

To render the primary dashboard interface, the system runs an optimized filtration loop over the entire active database partition to find and aggregate entries logged within the current calendar day:

```dart
int getTodayTotal() {
  final now = DateTime.now();
  return state
      .where((e) => e.timestamp.year == now.year && e.timestamp.month == now.month && e.timestamp.day == now.day)
      .fold(0, (sum, item) => sum + item.amountMl);
}

```

The computed integer value is matched against the application's $3,000\text{ ML}$ system target.

#### 3.2.4 Tactile Control Brackets

Data logging is designed for speed via quick-increment control arrays:

* `[ +250ML ]` (Standard water glass allocation)
* `[ +500ML ]` (Standard hydration flask increment)
* `[ +750ML ]` (Large volume workout beverage container)

Tapping any button appends a new entry to the state collection and triggers an instant reactive layout refresh.

```
+                  -+
| CONSUMPTION LEADGER MATRIX BLOCK                      |
+                  -+
|  TIME    | DATE    | METRIC VOLUME   | DISMISS RULE   |
+   -+   +     --+     -+
|  08:14   | JUN 15  | +250 ML         | [X] TERMINATE  |
|  12:45   | JUN 15  | +500 ML         | [X] TERMINATE  |
|  16:22   | JUN 15  | +500 ML         | [X] TERMINATE  |
+                  -+

```

#### 3.2.5 Static Progress Bar Component

Progress tracking avoids radial meters and complex wave animations, using a clean geometric progress tracking bar instead. The completion ratio is calculated via a simple bounded equation:


$$\text{Completion Ratio} = \min\left(1.0, \frac{\text{Today Total}}{\text{Daily Target}}\right)$$

This metric dictates the layout width of an explicit foreground color container overlay within a flat layout track:

```dart
Container(
  width: double.infinity,
  height: 6,
  color: isDark ? Color(0xFF1F1F1F) : Color(0xFFDCDCDC),
  child: Align(
    alignment: Alignment.centerLeft,
    child: FractionallySizedBox(
      widthFactor: completionRatio,
      child: Container(color: textMain),
    ),
  ),
)

```

 

### 3.3 `StepScreen` — Quantum Step Quantizer & Density Matrix

#### 3.3.1 Purpose and Rationale

Daily movement patterns directly impact cardiovascular health and metabolic efficiency. However, scrolling through complex scatter plots or endless line charts often leads to information fatigue.

The `StepScreen` solves this by transforming the extensive 12-month calendar matrix grid from `ideainbox.dart` into an interactive health tracking visualization. This system renders a comprehensive annual performance grid within a single screen view, allowing the operator to immediately evaluate long-term movement habits and behavioral consistency.

```
+                  -+
| GRID CALENDAR MATRIX VISUAL SCHEMA                    |
+                  -+
|  [M]  [T]  [W]  [T]  [F]  [S]  [S]   <- Day Headers   |
|  [01] [02] [03] [04] [05] [06] [07]  <- Intensity box  |
|  [08] [09] [10] [11] [12] [13] [14]  |  scaled via     |
|  [15] [16] [17] [18] [19] [20] [21]  |  logged step    |
|  [22] [23] [24] [25] [26] [27] [28]  |  thresholds     |
+                  -+

```

#### 3.3.2 Grid Matrix Generation Algorithm

The screen builds a 12-month calendar layout using an optimized nested grid builder pipeline. For any current year, it calculates month structures dynamically to ensure absolute calendar accuracy across leap years:

```dart
int _getTotalDaysInYear(int year) {
  bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  return isLeapYear ? 366 : 365;
}

```

For each distinct month, the system evaluates the exact layout padding required by checking the day-of-the-week index of the first calendar day:

```dart
final DateTime firstDayOfMonth = DateTime(currentYear, monthIndex + 1, 1);
final int startingWeekday = firstDayOfMonth.weekday;
final int leadingBlanks = startingWeekday - 1;

```

The grid builder processes the combination of day headers, blank offsets, and monthly days, compiling them into a responsive grid system.

#### 3.3.3 The Three-Tier Density Color Engine

Instead of mapping complex bar heights, each calendar cell functions as a discrete status block. The fill color of the container shifts across three distinct tiers based on the recorded daily step count:

```
+                       --+
| INTENSITY LEVEL THRESHOLD DEFINITIONS                                 |
+                       --+
|  STEP RANGE          | RENDER STYLING CONFIGURATION                   |
+       -+                +
|  0 Steps             | Transparent background / ruleBorder outline    |
|  1 - 4,999 Steps     | Low intensity mute fill (Color(0xFF262626))   |
|  5,000 - 9,999 Steps | Medium intensity textSub fill                  |
|  10,000+ Steps       | Solid high-contrast textMain fill (Goal Met)   |
+                       --+

```

This color mapping allows users to instantly spot behavioral gaps and habit trends without needing to click or drill down into complex sub-menus.

#### 3.3.4 Retrospective Numeric Data Entry Block

Tapping any matrix cell opens a customized bottom logging sheet. This drawer restricts user input to numeric characters via a strict system verification formatter:

```dart
keyboardType: TextInputType.number,
inputFormatters: [FilteringTextInputFormatter.digitsOnly]

```

When the user submits a value, it updates the state map using a string date key lookup (`yyyy-MM-dd`), which instantly triggers an isolated repaint of the specific calendar cell.

 

### 3.4 `MeditationScreen` — Inversion Alarm Framework

#### 3.4.1 Purpose and Rationale

Meditation and interval breathing exercises require undivided concentration. Standard utility timers undermine this practice by displaying circular progress animations or showing shifting numbers that draw the user's focus back to the screen.

The `MeditationScreen` removes these visual distractions by showing a clean, unmoving text timer during active countdowns. Once the countdown terminates, the module triggers a complete layout color inversion, creating a bold visual notification that doesn't rely on noisy audio alerts or intrusive graphical animations.

```
+                  -+
| TIMER IN ACTIVE RUNTIME STATE                         |
+                  -+
| Context: Dark Mode Active                             |
| Canvas: Pure Black (#000000)                          |
| Card Typography: Pure White Text on Dark Box           |
+                  -+
                           |
                           v  [Seconds Count Down to Zero]
                           |
+                  -+
| TIMER TERMINATION STATE (COLOR INVERSION TRIGGERED)   |
+                  -+
| Context: Local Screen Layout Swaps Parameters         |
| Canvas Fluid Change: Pure White Card (#FFFFFF)         |
| Typography Inversion: Pure Black Text on White Box    |
+                  -+

```

#### 3.4.2 The Local Color Inversion Engine

The module reads the application's underlying timer state structure. If the state flags a termination event (`timerState.isFinished == true`), the screen overrides global theme configurations and instantly swaps local color values:

```dart
Color baseTextMain = isDark ? Colors.white : Colors.black;
Color baseContainerBg = isDark ? Color(0xFF0F0F0F) : Color(0xFFEEEEEE);

if (timerState.isFinished) {
  baseContainerBg = isDark ? Colors.white : Colors.black;
  baseTextMain = isDark ? Colors.black : Colors.white;
}

```

This sudden, total inversion flips the screen contrast profile instantly. If the user is running the dark theme, the active display card switches to solid white with black text; if the light theme is active, it flashes to solid black with white text. This provides a clear, unmistakable visual signal that can be easily spotted across a room.

#### 3.4.3 Interval Control Configurations

Duration intervals are selected via standard macro control selectors styled like the tab components in `clipboard.dart`:

* `[ 15 MIN ]` (Short breathing interval)
* `[ 30 MIN ]` (Standard mindfulness session)
* `[ 60 MIN ]` (Extended structural awareness session)

#### 3.4.4 Async Countdown Ticker Process

The timer uses a precise async ticker engine managed via an isolated `Timer.periodic` loop. This engine updates remaining intervals at exact 1-second ticks, ensuring reliable timekeeping and avoiding frame rendering delays or task suspension bugs when users lock their devices.

 

### 3.5 `SettingsScreen` — System Config Matrix

#### 3.5.1 Purpose and Rationale

The `SettingsScreen` acts as the control center for system configurations and local privacy documentation. It completely avoids complex multi-layered menus and iconography, providing a single consolidated dashboard built with clean menu rows and expandable text boxes.

#### 3.5.2 Inline Expandable System Drawers

Instead of opening external web links or separate text screens for documentation and privacy terms, the screen handles all content layouts inline using compact Boolean state triggers:

```dart
bool _isPrivacyPolicyExpanded = false;
bool _isDataPrivacyExpanded = false;

```

Tapping a menu row toggles these flags, smoothly expanding or collapsing detailed system disclosures within the active view. This allows users to read documentation without losing their position in the configuration menu.

```
+                  -+
| SYSTEM CONFIG MATRIX VIEWPORT                         |
+                  -+
|  [01] INTERFACE THEME  -> [ PURE DARK MODE ACTIVE ]   |
|  [02] PRIVACY POLICY   -> [ EXPANSILE CONTROL DRAWER ]|
|  ===================================================  |
|  || VIDADOR CODES BIOMETRIC RECORDINGS EXCLUSIVELY  |||
|  || TO LOCAL STORAGE ARRAYS. NO TELEMETRY BRIDGE.   |||
|  ===================================================  |
|  [03] DATA PRIVACY     -> [ EXPANSILE CONTROL DRAWER ]|
|  [04] WEBSITE BRIDGE   -> [ EXTERNAL APPLICATION LINK]|
|  [05] FEEDBACK ENGINE  -> [ EXTERNAL APPLICATION LINK]|
+                  -+

```

#### 3.5.3 Verification and Licensing Disclosures

The section provides three specific technical disclosures that explain the app's offline, independent architecture:

1. **Privacy Policy Matrix:** Discloses that the app is completely network-isolated and features zero background profiling or usage tracking.
2. **Data Privacy Sandbox Specs:** Explains how biometric data is stored inside local Hive partitions, clarifying that deleting the application completely purges all data from the device hardware.
3. **The Darshseraphic Sign-Off:** A static typographic signature (`BUILD BY DARSHSERPHIC`) positioned at the base of the view to guarantee code authenticity.

 

## 4. TECHNICAL EXECUTION & UNDERLYING LOGIC ENGINE

### 4.1 System Root State Management via Riverpod

Vidador handles application states using `flutter_riverpod`, avoiding old mutable patterns or heavy state architectures. State mutation logic is encapsulated within clean, isolated `Notifier` lifecycle blocks.

```
+                     --+
|  RIVERPOD CONSUMER REFRESH MECHANISM                            |
+                     --+
|  1. USER ACTION     -> Triggers tactile log input action        |
|  2. NOTIFIER MUTATE -> Evaluates and appends state array        |
|  3. DISK STREAM     -> Fires background serialization write     |
|  4. CONSUMER REF    -> UI components auto-repaint viewports     |
+                     --+

```

By decoupling state changes from UI rendering, Vidador ensures efficient data updates and smooth rendering performance, keeping frame delivery stable across low-powered devices.

### 4.2 Local Offline Persistence Architecture via Hive

Data storage runs on **Hive**, a fast, lightweight NoSQL key-value database engine optimized for local mobile devices. It encodes object arrays directly into binary streams written inside dedicated app sandbox partitions, bypassing the overhead of heavy relational database systems.

```
+                     --+
|  HIVE SANDBOX STORAGE SEPARATION MATRIX                         |
+                     --+
|  BOX IDENTIFIER       | CONTAINED COMPONENT TYPE DATA MAPS      |
+       --+             --+
|  vidador_settings_box | Theme markers, setup parameters         |
|  vidador_sleep_box    | ISO8601 strings for circadian tracking   |
|  vidador_water_box    | Transaction logs for volumetric entries |
|  vidador_steps_box    | Key-value logs for date movement maps   |
+                     --+

```

#### 4.2.1 High-Performance RAM Caching

During the initial boot cycle, the app loads data indices directly into active RAM buffers. Read operations access this memory layer with zero disk delay, while write and delete transactions modify the active cache array for instant visual updates before streaming updates down onto device hardware storage asynchronously.

### 4.3 App Boot Initializer Optimization

To prevent UI initialization delays or blank screen rendering errors, Vidador runs all async database setup tasks inside a centralized initialization sequence before launching the primary app widget:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize and open local Hive storage boxes
  await LocalDatabaseManager.initializeDatabase();

  runApp(
    const ProviderScope(
      child: VidadorAppHead(),
    ),
  );
}

```

 

## 5. COMPLETE REPOSITORY BLUEPRINT & IMPLEMENTATION GUIDE

### 5.1 Project Layout Matrix

The repository is organized into distinct, isolated modules to ensure clear separation of concerns and maintain technical scalability:

```
vidador/
├── lib/
│   ├── core/
│   │   └── database.dart
│   ├── features/
│   │   ├── meditation.dart
│   │   ├── setting.dart
│   │   ├── sleep.dart
│   │   ├── step.dart
│   │   └── water.dart
│   └── main.dart
├── test/
│   └── widget_test.dart
└── pubspec.yaml

```

### 5.2 Dependency Manifest (`pubspec.yaml`)

The package configuration file maps all dependencies required by the application engine:

```yaml
name: vidador
description: "Strict ultra minimalistic discipline and biometric tracking engine."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # DATA PERSISTENCE MANAGEMENT
  hive_flutter: ^1.1.0

  # APPLICATION STATE PIPELINE
  flutter_riverpod: ^2.5.1

  # UTILITIES AND EXTERNAL LINK ROUTING
  intl: ^0.19.0
  url_launcher: ^6.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true

```

### 5.3 System Boot Blueprint (`lib/main.dart`)

The core setup script manages screen routing and coordinates global application states:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/database.dart';
import 'features/sleep.dart';
import 'features/water.dart';
import 'features/step.dart';
import 'features/meditation.dart';
import 'features/setting.dart';

final themeProvider = StateProvider<bool>((ref) {
  final box = Hive.box('vidador_settings_box');
  return box.get('is_dark_mode', defaultValue: true);
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabaseManager.initializeDatabase();

  runApp(
    const ProviderScope(
      child: VidadorAppHead(),
    ),
  );
}

class VidadorAppHead extends ConsumerWidget {
  const VidadorAppHead({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp(
      title: 'VIDADOR',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Courier',
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Courier',
      ),
      home: const MainLayoutRouter(),
    );
  }
}

class MainLayoutRouter extends ConsumerStatefulWidget {
  const MainLayoutRouter({super.key});

  @override
  ConsumerState<MainLayoutRouter> createState() => _MainLayoutRouterState();
}

class _MainLayoutRouterState extends ConsumerState<MainLayoutRouter> {
  int _currentMatrixIndex = 0;

  final List<Widget> _appScreens = [
    const SleepScreen(),
    const WaterScreen(),
    const StepScreen(),
    const MeditationScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF666666) : const Color(0xFF999999);
    final borderColor = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E5E5);
    final barBgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentMatrixIndex,
          children: _appScreens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: barBgColor,
          border: Border(top: BorderSide(color: borderColor, width: 0.8)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChronoTabItem(0, 'SLEEP', textMain, textSub),
                _buildChronoTabItem(1, 'WATER', textMain, textSub),
                _buildChronoTabItem(2, 'STEPS', textMain, textSub),
                _buildChronoTabItem(3, 'MEDITATION', textMain, textSub),
                _buildChronoTabItem(4, 'SETTING', textMain, textSub),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChronoTabItem(int index, String label, Color selectedColor, Color unselectedColor) {
    final bool isCurrent = _currentMatrixIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentMatrixIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          isCurrent ? '[$label]' : label,
          style: TextStyle(
            color: isCurrent ? selectedColor : unselectedColor,
            fontSize: 9.5,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            letterSpacing: 0.04,
          ),
        ),
      ),
    );
  }
}

```

### 5.4 Database Storage Init Blueprint (`lib/core/database.dart`)

This module handles local storage allocations and asynchronous initializations for Hive database boxes:

```dart
import 'package:hive_flutter/hive_flutter.dart';

class LocalDatabaseManager {
  static const String settingsBoxName = 'vidador_settings_box';
  static const String sleepBoxName = 'vidador_sleep_box';
  static const String waterBoxName = 'vidador_water_box';
  static const String stepsBoxName = 'vidador_steps_box';

  static Future<void> initializeDatabase() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(settingsBoxName),
      Hive.openBox(sleepBoxName),
      Hive.openBox(waterBoxName),
      Hive.openBox(stepsBoxName),
    ]);
  }

  static Future<void> purgeAllRegistries() async {
    await Hive.box(sleepBoxName).clear();
    await Hive.box(waterBoxName).clear();
    await Hive.box(stepsBoxName).clear();
  }
}

```

### 5.5 Environment Setup & Project Build Sequences

To deploy and compile the application successfully, execute these system terminal commands from your project's root folder:

#### 1. System Directory Purge

Clear out historical compilation artifacts and reset dependency caches:

```bash
flutter clean

```

#### 2. Synchronize Application Dependencies

Fetch and pull down the explicit versions of the external libraries specified within your pubspec manifest:

```bash
flutter pub get

```

#### 3. Analyze Code Sanity

Run compilation check engines to confirm layout tokens conform to strict design system constraints:

```bash
flutter analyze

```

#### 4. Ignite Active Project Runtime

Launch the production runtime environment on your connected testing hardware or simulator:

```bash
flutter run

```

#### 5. Generate Compiled Release Application (Android Release APK)

Build an optimized, standalone production binary compiled directly for native deployment:

```bash
flutter build apk --release

```

 

## 6. MAINTENANCE CONSTRAINTS & DEVELOPMENT GUIDELINES

To maintain Vidador's specific structural goals, future development contributions must adhere to these clear codebase constraints:

### 6.1 The Anti-Decoration Rule

The inclusion of color gradients, decorative border-radius elements, floating action buttons, material elevation parameters, or background graphics is strictly prohibited. If a layout component requires visual separation, you must use an explicit thin border line (`0.8px`) or structured typographic hierarchy.

### 6.2 The Unified Uppercase Label Rule

All interactive interface texts, screen headers, execution buttons, metadata tags, and confirmation components must be written inside uppercase string declarations. Lowercase strings are restricted to user logs or long-form paragraphs within informational sub-panels.

### 6.3 The Air-Gapped Verification Protocol

No code additions may import libraries that perform telemetry tracking, analytical profiling, or remote background reporting. Any updates to network requirements must be fully reviewed to ensure user data remains completely isolated on local storage hardware.