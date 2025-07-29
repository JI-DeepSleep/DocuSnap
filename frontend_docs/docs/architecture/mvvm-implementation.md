# MVVM Architecture Implementation

DocuSnap-Frontend fully adopts the MVVM (Model-View-ViewModel) architecture pattern, which provides a clear separation of concerns and improves code maintainability and testability.

## MVVM Components

### Model

- **Data Models**: `Document`, `Form`, `ExtractedInfoItem`, etc.
- **Data Access**: Repositories and data sources (local database, remote API)

### View

- **UI Components**: Jetpack Compose UI components
- **State Observation**: Using `collectAsState()` to observe ViewModel states

### ViewModel

- **State Management**: Using `StateFlow` to manage UI states
- **Business Logic**: Handling user actions and data transformations
- **Coroutine Integration**: Using `viewModelScope` to manage asynchronous operations

## MVVM Implementation Example

Below is an example of how MVVM is implemented in the application:

```kotlin
// State management in ViewModel
class DocumentViewModel(private val repository: DocumentRepository) : ViewModel() {
    private val _documents = MutableStateFlow<List<Document>>(emptyList())
    val documents: StateFlow<List<Document>> = _documents.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    fun loadDocuments() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val docs = repository.getAllDocuments()
                _documents.value = docs
            } catch (e: Exception) {
                // Error handling
            } finally {
                _isLoading.value = false
            }
        }
    }
}

// State collection in UI
@Composable
fun DocumentScreen(viewModel: DocumentViewModel) {
    val documents by viewModel.documents.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    
    LaunchedEffect(Unit) {
        viewModel.loadDocuments()
    }
    
    if (isLoading) {
        CircularProgressIndicator()
    } else {
        LazyColumn {
            items(documents) { document ->
                DocumentItem(document)
            }
        }
    }
}
```

## Data Flow in MVVM

The data flow in the MVVM architecture follows a unidirectional pattern:

1. **User Interaction**: User interacts with the UI (View)
2. **Action Dispatch**: View dispatches actions to the ViewModel
3. **Data Processing**: ViewModel processes the action and interacts with the Repository
4. **Data Retrieval**: Repository retrieves data from local or remote sources
5. **State Update**: ViewModel updates its state based on the retrieved data
6. **UI Update**: View observes state changes and automatically updates

This unidirectional data flow ensures that the UI is always consistent with the underlying data and simplifies debugging and testing.

## Benefits of MVVM in DocuSnap-Frontend

- **Separation of Concerns**: UI, business logic, and data access are clearly separated
- **Testability**: ViewModels and Repositories can be tested independently
- **Maintainability**: Each component has a single responsibility
- **Reactive UI Updates**: UI automatically updates in response to data changes
- **Lifecycle Awareness**: ViewModels survive configuration changes