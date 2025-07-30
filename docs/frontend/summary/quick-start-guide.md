# Quick Start Guide

This guide provides essential information for new developers to quickly get started with the DocuSnap-Frontend project.

## Key Components and Files

### 1. Entry Points

- **MainActivity.kt**: Main application entry point
  - Initializes the application
  - Sets up the navigation host
  - Configures dependencies

- **AppModule.kt**: Dependency injection configuration
  - Provides application-wide dependencies
  - Configures services and repositories
  - Manages singleton instances

### 2. Core Modules

- **DocumentViewModel.kt**: Core of document processing
  - Manages document state and operations
  - Handles document loading, saving, and updating
  - Coordinates with repositories for data operations

- **ImageProcessingViewModel.kt**: Core of image processing
  - Manages image processing state and operations
  - Handles image filters and transformations
  - Coordinates with image processing services

- **BackendApiService.kt**: Core of backend communication
  - Manages API requests and responses
  - Implements encryption and security
  - Handles error cases and retries

### 3. Data Models

- **Document.kt**: Document data model
  - Defines document structure and properties
  - Used throughout the document processing flow

- **Form.kt**: Form data model
  - Defines form structure and properties
  - Includes form fields and metadata

- **ExtractedInfoItem.kt**: Extracted information model
  - Represents extracted text or field data
  - Used in both documents and forms

### 4. UI Components

- **screens/**: Main screen implementations
  - Contains all application screens
  - Organized by feature or function

- **components/**: Reusable UI components
  - Contains shared UI elements
  - Used across multiple screens

- **theme/**: Application theme and styles
  - Defines colors, typography, and shapes
  - Configures Material Design theme

## Development Environment Setup

### 1. Environment Requirements

- **Android Studio**: Arctic Fox or higher
- **JDK**: Version 11 or higher
- **Android SDK**: API level 33 or higher
- **Gradle**: Compatible with project configuration

### 2. Build Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/JI-DeepSleep/DocuSnap-Frontend.git
   cd DocuSnap-Frontend
   ```

2. **Open in Android Studio**:
   - Launch Android Studio
   - Select "Open an Existing Project"
   - Navigate to the cloned repository directory

3. **Sync Gradle Files**:
   - Wait for the automatic sync or
   - Click "Sync Project with Gradle Files" button

4. **Build and Run**:
   - Select a device or emulator
   - Click the "Run" button or press Shift+F10

### 3. Debugging Tips

- **Logcat**: Use for viewing logs
  - Filter by tag to focus on specific components
  - Use different log levels (DEBUG, INFO, ERROR)

- **Layout Inspector**: Debug UI issues
  - View component hierarchy
  - Inspect properties and constraints

- **Database Inspector**: View database content
  - Examine tables and records
  - Execute SQL queries for testing

- **Network Profiler**: Monitor network activity
  - Track API calls
  - Analyze response times and data sizes

## Common Development Workflows

### 1. Adding a New Screen

1. **Create a new Composable function** in the `screens/` directory:
   ```kotlin
   @Composable
   fun NewScreen(
       viewModel: SharedViewModel = hiltViewModel(),
       onNavigate: (String) -> Unit
   ) {
       // Screen implementation
   }
   ```

2. **Add a new route** in the navigation package:
   ```kotlin
   object Screen {
       // Existing routes
       object NewScreen : Screen("new_screen")
   }
   ```

3. **Register the screen** in the NavHost:
   ```kotlin
   NavHost(
       navController = navController,
       startDestination = startDestination
   ) {
       // Existing routes
       composable(Screen.NewScreen.route) {
           NewScreen(
               onNavigate = { route -> navController.navigate(route) }
           )
       }
   }
   ```

### 2. Modifying Data Models

1. **Update the data class** definition:
   ```kotlin
   @Serializable
   data class Document(
       val id: String,
       val name: String,
       // Add new fields
       val newField: String? = null,
       // Other existing fields
   )
   ```

2. **Update corresponding database entity** if needed:
   ```kotlin
   @Entity(tableName = "documents")
   data class DocumentEntity(
       @PrimaryKey val id: String,
       val name: String,
       // Add new column
       @ColumnInfo(name = "new_field") val newField: String?,
       // Other existing columns
   )
   ```

3. **Add database migration** strategy:
   ```kotlin
   val MIGRATION_1_2 = object : Migration(1, 2) {
       override fun migrate(database: SupportSQLiteDatabase) {
           database.execSQL("ALTER TABLE documents ADD COLUMN new_field TEXT")
       }
   }
   ```

### 3. Adding New Functionality

1. **Determine which module** the functionality belongs to

2. **Add necessary methods** to the appropriate ViewModel:
   ```kotlin
   // In DocumentViewModel
   fun newFeature(param: String) {
       viewModelScope.launch {
           _isLoading.value = true
           try {
               val result = repository.performNewFeature(param)
               _featureResult.value = result
           } catch (e: Exception) {
               _error.value = "Error: ${e.message}"
           } finally {
               _isLoading.value = false
           }
       }
   }
   ```

3. **Update the UI** to support the new feature:
   ```kotlin
   @Composable
   fun FeatureComponent(viewModel: DocumentViewModel) {
       val result by viewModel.featureResult.collectAsState()
       
       Column {
           Button(onClick = { viewModel.newFeature("param") }) {
               Text("Execute New Feature")
           }
           
           if (result != null) {
               Text("Result: $result")
           }
       }
   }
   ```

## Architecture Overview

DocuSnap-Frontend follows the MVVM (Model-View-ViewModel) architecture pattern:

1. **Model**: Data models and repositories
   - Represents the data and business logic
   - Handles data access and storage

2. **View**: Jetpack Compose UI components
   - Displays data to the user
   - Forwards user actions to the ViewModel

3. **ViewModel**: State management and business logic
   - Manages UI state
   - Processes user actions
   - Communicates with repositories

Data flows through the application in a unidirectional pattern:
- User actions in the UI trigger ViewModel methods
- ViewModel processes actions and updates state
- UI automatically updates to reflect the new state

## Common Pitfalls and Solutions

### 1. State Management

**Pitfall**: Mutable state shared across multiple components

**Solution**: Use StateFlow in ViewModels and collect at the UI level:
```kotlin
// In ViewModel
private val _state = MutableStateFlow(initialState)
val state: StateFlow<UiState> = _state.asStateFlow()

// In UI
val state by viewModel.state.collectAsState()
```

### 2. Coroutine Scope

**Pitfall**: Using the wrong coroutine scope or not cancelling coroutines

**Solution**: Use the appropriate scope and ensure proper cancellation:
```kotlin
// In ViewModel
viewModelScope.launch {
    // Long-running operation
}
// Automatically cancelled when ViewModel is cleared

// For background service
val job = CoroutineScope(Dispatchers.IO + SupervisorJob()).launch {
    // Background operation
}
// Remember to cancel: job.cancel()
```

### 3. Image Processing Performance

**Pitfall**: Performing heavy image processing on the main thread

**Solution**: Use background dispatchers and optimize processing:
```kotlin
viewModelScope.launch(Dispatchers.IO) {
    val processedBitmap = withContext(Dispatchers.Default) {
        // Heavy image processing
        imageProcService.processImage(bitmap)
    }
    
    // Update UI state on main thread
    _uiState.update { it.copy(editingBitmap = processedBitmap) }
}
```

### 4. Memory Management

**Pitfall**: Memory leaks from holding references to contexts or activities

**Solution**: Use application context, weak references, or lifecycle-aware components:
```kotlin
// Use application context for long-lived objects
val imageLoader = ImageLoader(context.applicationContext)

// Use rememberCoroutineScope in Compose
val scope = rememberCoroutineScope()
```

This quick start guide should help new developers understand the key components of DocuSnap-Frontend and get started with common development tasks. For more detailed information, refer to the specific documentation sections on architecture, modules, and processes.