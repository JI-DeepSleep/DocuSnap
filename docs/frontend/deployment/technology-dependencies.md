# Technology Stack and Dependencies

DocuSnap-Frontend relies on multiple libraries and frameworks to provide its functionality. This page details the runtime and build dependencies of the application.

## Runtime Dependencies

### 1. UI Framework

- **Jetpack Compose** (androidx.compose.*)
  - Modern declarative UI framework
  - Core components: ui-core, ui-tooling, foundation, material3
  - Version: Latest BOM (Bill of Materials)

- **Material Design 3** (androidx.material3)
  - Implements Material Design guidelines
  - Provides modern UI components and theming

- **Navigation Compose** (androidx.navigation:navigation-compose)
  - Handles navigation between screens
  - Supports deep linking and type-safe navigation

### 2. Architecture Components

- **Jetpack ViewModel** (androidx.lifecycle:lifecycle-viewmodel-ktx)
  - Manages UI-related data through lifecycle changes
  - Survives configuration changes

- **Kotlin Coroutines** (org.jetbrains.kotlinx:kotlinx-coroutines-android)
  - Handles asynchronous operations
  - Provides structured concurrency

- **Flow** (part of kotlinx-coroutines)
  - Implements reactive programming
  - Supports data streaming and transformation

- **Lifecycle Components** (androidx.lifecycle:lifecycle-runtime-ktx)
  - Manages Android component lifecycles
  - Provides lifecycle-aware components

### 3. Network Communication

- **Retrofit** (com.squareup.retrofit2:retrofit)
  - Type-safe HTTP client
  - Version: 2.9.0

- **OkHttp** (com.squareup.okhttp3:okhttp)
  - Efficient HTTP client
  - Provides interceptors and caching
  - Version: 4.12.0

- **Moshi and Gson** (for JSON processing)
  - com.squareup.retrofit2:converter-gson
  - com.squareup.retrofit2:converter-moshi
  - Handles JSON serialization and deserialization

### 4. Local Storage

- **Room Database** (androidx.room.*)
  - Provides abstraction layer over SQLite
  - Supports type-safe queries and data access
  - Version: 2.7.2

- **SharedPreferences**
  - Stores simple key-value pairs
  - Used for application settings

### 5. Image Processing

- **CameraX** (androidx.camera.*)
  - Simplifies camera implementation
  - Components: camera-camera2, camera-lifecycle, camera-view, camera-extensions
  - Version: 1.3.0

- **Coil** (io.coil-kt:coil-compose)
  - Image loading library
  - Efficiently loads and caches images
  - Version: 2.5.0

### 6. Serialization

- **Kotlinx Serialization**
  - Handles object serialization and deserialization
  - Used for data model serialization

## Build Dependencies

### 1. Build Tools

- **Gradle Build System**
  - Manages build process and dependencies
  - Uses Kotlin DSL for build scripts

- **Kotlin Gradle Plugin**
  - Enables Kotlin compilation
  - Configures Kotlin compiler options

- **Android Gradle Plugin**
  - Provides Android-specific build capabilities
  - Configures Android build process

### 2. Compilation Tools

- **Kotlin Compiler**
  - Compiles Kotlin source code
  - Supports modern language features

- **R8 Code Optimizer**
  - Performs code shrinking and optimization
  - Not currently enabled in the project

- **Android SDK Tools**
  - Provides Android platform tools and APIs
  - Used for building Android applications

### 3. Resource Processing

- **Android Resource Compiler**
  - Processes Android resource files
  - Generates R.java file

- **Resource Optimization Tools**
  - Optimizes drawables and other resources
  - Reduces application size

## Dependency Relationship Diagram

The main dependency relationships in the application are as follows:

```
Android Runtime (ART)
├── Jetpack Compose
│   ├── Material Design 3
│   └── Navigation Compose
├── Retrofit
│   └── OkHttp
├── Room Database
├── CameraX
└── Kotlin Standard Library
    ├── Coroutines
    └── Flow
```

## Dependency Management

The application uses Gradle's dependency management system with the following features:

### 1. Version Catalogs

- Centralizes dependency versions
- Simplifies version updates
- Example from build.gradle.kts:
  ```kotlin
  implementation(platform(libs.androidx.compose.bom))
  implementation(libs.androidx.ui)
  implementation(libs.androidx.ui.graphics)
  implementation(libs.androidx.material3)
  ```

### 2. Dependency Configurations

- Uses appropriate configurations (implementation, api, etc.)
- Minimizes unnecessary transitive dependencies
- Example:
  ```kotlin
  implementation("androidx.core:core-ktx:1.12.0")
  implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
  testImplementation("junit:junit:4.13.2")
  ```

### 3. Dependency Constraints

- Resolves version conflicts
- Enforces specific versions when needed
- Example:
  ```kotlin
  constraints {
      implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
  }
  ```

## Build Configuration

The application is configured with the following build parameters:

- Compile SDK Version: 35
- Minimum SDK Version: 33 (Android 13)
- Target SDK Version: 35
- Java Compatibility Version: Java 11
- Kotlin Version: Latest stable
- Compose Compiler Version: Compatible with Kotlin version

These dependencies and configurations ensure that DocuSnap-Frontend is built with modern, robust libraries that provide the necessary functionality while maintaining compatibility with the target Android versions.