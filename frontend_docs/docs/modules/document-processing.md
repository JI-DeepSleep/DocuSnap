# Document Processing Module

## Responsibilities

The Document Processing module is responsible for document capture, processing, and management, which is one of the core functional modules of the application. Its main responsibilities include:

- Document data model definition and management
- Document creation, reading, updating, and deletion (CRUD) operations
- Document metadata extraction and management
- Document search and filtering
- Document usage statistics tracking
- Document relationship management

## Interface Design

### Main Classes and Interfaces

#### 1. DocumentViewModel

Manages document states and operations, providing document loading, saving, updating, and deletion functions, as well as managing document search and usage statistics.

```kotlin
class DocumentViewModel(private val repository: DocumentRepository) : ViewModel() {
    // Document list state
    private val _documents = MutableStateFlow<List<Document>>(emptyList())
    val documents: StateFlow<List<Document>> = _documents.asStateFlow()
    
    // Loading state
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    
    // Load all documents
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
    
    // Get a single document
    suspend fun getDocument(id: String): Document? {
        return repository.getDocument(id)
    }
    
    // Save document
    suspend fun saveDocument(document: Document) {
        repository.saveDocument(document)
        loadDocuments() // Refresh list
    }
    
    // Update document
    suspend fun updateDocument(document: Document) {
        repository.updateDocument(document)
        loadDocuments() // Refresh list
    }
    
    // Delete document
    suspend fun deleteDocument(id: String) {
        repository.deleteDocument(id)
        loadDocuments() // Refresh list
    }
    
    // Update extracted info usage statistics
    suspend fun updateExtractedInfoUsage(fileId: String, fileType: FileType, key: String) {
        repository.updateExtractedInfoUsage(fileId, fileType, key)
    }
}
```

#### 2. DocumentRepository

Abstracts document data access, coordinates data flow between local database and remote API, and handles document serialization and deserialization.

```kotlin
class DocumentRepository(private val deviceDBService: DeviceDBService) {
    // Get all documents
    suspend fun getAllDocuments(): List<Document> {
        return deviceDBService.getDocumentGallery().mapNotNull { json ->
            try {
                Document(
                    id = json.getString("id"),
                    name = json.getString("name"),
                    // Other property mapping
                )
            } catch (e: Exception) {
                null
            }
        }
    }
    
    // Get a single document
    suspend fun getDocument(id: String): Document? {
        val json = deviceDBService.getDocument(id) ?: return null
        return try {
            Document(
                id = json.getString("id"),
                name = json.getString("name"),
                // Other property mapping
            )
        } catch (e: Exception) {
            null
        }
    }
    
    // Save document
    suspend fun saveDocument(document: Document) {
        val json = JSONObject().apply {
            put("id", document.id)
            put("name", document.name)
            // Other property mapping
        }
        deviceDBService.saveDocument(json)
    }
    
    // Update document
    suspend fun updateDocument(document: Document) {
        saveDocument(document) // Simplified implementation, could be optimized
    }
    
    // Delete document
    suspend fun deleteDocument(id: String) {
        deviceDBService.deleteDocument(id)
    }
    
    // Update extracted info usage statistics
    suspend fun updateExtractedInfoUsage(fileId: String, fileType: FileType, key: String) {
        deviceDBService.updateExtractedInfoUsage(fileId, fileType, key)
    }
}
```

#### 3. DeviceDBService

Local data storage service that uses Room database to store document entities and manages document CRUD operations.

#### 4. Document Data Model

Represents the core data structure for documents.

```kotlin
@Serializable
data class Document(
    val id: String,
    val name: String,
    val description: String,
    val imageBase64s: List<String> = emptyList(),
    val extractedInfo: List<ExtractedInfoItem> = emptyList(),
    val tags: List<String> = emptyList(),
    val uploadDate: String = "2024-01-15",
    val relatedFileIds: List<String> = emptyList(),
    val sha256: String? = null,
    val isProcessed: Boolean = false,
    val jobId: Long? = null,
    val usageCount: Int = 0,
    val lastUsed: String = "2024-01-15"
)
```

## Design Patterns and Extension Points

### Design Patterns

#### 1. Repository Pattern
- Abstracts data access logic
- Provides a unified data interface
- Hides data source details

#### 2. Observer Pattern
- Uses StateFlow to implement reactive data flow
- Automatically updates UI in response to data changes

#### 3. Factory Pattern
- Uses ViewModelFactory to create ViewModel instances
- Supports dependency injection

### Extension Points

#### 1. Custom Metadata Extraction
- The `extractedInfo` field supports custom metadata
- Extraction algorithms and field types can be extended

#### 2. Document Relationships
- `relatedFileIds` allows establishing relationships between documents
- Can be extended to more complex relationship graphs

#### 3. Document Processing Plugins
- Backend processing capabilities can be extended
- Supports new document types and processing algorithms

#### 4. Usage Statistics and Analysis
- Existing usage statistics mechanism can be extended to more complex analytics
- Supports personalized recommendations and intelligent sorting