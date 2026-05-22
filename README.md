# Anexee ML Platform Companion App

Anexee is a state-of-the-art analytical excellence Machine Learning companion application built with Flutter. It provides an intuitive, high-performance user interface for managing datasets, training ML models, tracking real-time training status, and comparing models via dynamic leaderboards.

---

## 🚀 Key Features

### 🔐 1. Authentication & Security
* **Dynamic Server Connection**: Connect to custom backend APIs dynamically with real-time health checks and status indicators.
* **Auto-Token Refresh**: Automatically refreshes the JWT token every 15 minutes (895s) in the background to ensure session continuity.
* **Encrypted Storage**: Credentials and API tokens are securely encrypted and cached locally using `Hive` and `shared_preferences`.
* **User Profile Dialog**: Interactive top-bar profile card displaying the logged-in user details, current organization logo, and sign-out capabilities.

### 📊 2. Dynamic Leaderboard
* **Dynamic Table Layout**: A full-width, clean table showcasing trained models, hyperparameter settings, and performance indicators.
* **Tooltip Sorting Directions**: Column headers display tooltip directions (`maximize` or `minimize`) pointing upwards on hover to guide sorting.
* **Recursive Nested Accordions**: Deep-dive into metrics using recursively nested ExpansionTiles, supporting complex JSON trees gracefully.
* **Deployment & Fit Filters**: Out-of-the-box extraction of `Deployment Health` and `Model Fit Analysis` while automatically filtering out irrelevant categories (such as underfitting indicators).
* **Feature Importance Accordion**: Individual vertical layout representation of model features and their relative scores.

### 🪄 3. Model Training Wizard
* **Parquet File Preview**: Drag-and-drop Parquet file upload with read-only preview tables demonstrating column data types.
* **Target & Feature Selection**: Select classification or regression target variables dynamically.
* **Live Stream Tracking**: Monitor training runs in real time via asynchronous event streams showing validation losses, accuracy curves, and intermediate statuses.

---

## 🛠 Tech Stack

* **Core Framework**: Flutter (v3.24+ compatible)
* **Architecture**: Clean Architecture / Feature-First Folder Structure
* **State Management**: flutter_bloc (BLoC Pattern)
* **Dependency Injection**: get_it
* **Networking**: Dio (HTTP client with custom Interceptors)
* **Local Storage**: Hive (caching), shared_preferences (user preferences)
* **Cryptography**: AES encryption via `encrypt` and `pointycastle`
* **SVG Rendering**: flutter_svg

---

## 📂 Project Structure

```text
lib/
├── app/
│   ├── core/                  # Color systems, Typography, Global constants & Themes
│   │   ├── constants/         # API constants & storage keys
│   │   ├── theme/             # Light/dark theme parameters
│   │   └── utils/             # Helper extensions & formats
│   ├── data/                  # Core models, local storage databases & remote APIs
│   │   ├── local/             # Preference stores
│   │   └── model/             # Global data entities (models, profiles, results)
│   ├── di/                    # Dependency injection (service locator registration)
│   ├── modules/               # Feature modules
│   │   ├── auth/              # Sign in bloc, screen, and background authentication managers
│   │   ├── dashboard/         # Profile lists, widgets & user profile popover
│   │   ├── dataset/           # Dataset loading & previews
│   │   ├── leaderboard/       # Leaderboard tables, metric streams, and nested detail rows
│   │   └── training/          # Multi-step training wizard & streaming modals
│   └── routes/                # Navigation setup via go_router
└── main.dart                  # App bootstrap, configuration & local auth check
```

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel, recommended 3.24.x or above)
* [Dart SDK](https://dart.dev/get-started) (Compatible with your Flutter version)
* Native C/C++ compiler tools for building desktop apps:
  * **Windows**: Visual Studio with "Desktop development with C++" workload installed.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repo/anexee-ml-platform.git
   cd anexee-ml-platform
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Code Health**:
   ```bash
   flutter analyze
   ```

### Execution

#### Run on Windows Desktop
```bash
flutter run -d windows
```

#### Run on Web
```bash
flutter run -d chrome
```

---

## ⚙️ Configuration & Customization

* **API Endpoints**: Configure target main endpoints and path constraints directly inside `lib/app/core/constants/api_constants.dart`.
* **Theme Customization**: Update application colors, border radii, and text fonts inside `lib/app/core/theme/app_colors.dart` and `lib/app/core/theme/app_text_styles.dart`.
