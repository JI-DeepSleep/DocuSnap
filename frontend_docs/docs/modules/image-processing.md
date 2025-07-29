# Image Processing Module

## Responsibilities

The Image Processing module is responsible for image capture and processing, providing fundamental support for document and form processing. Its main responsibilities include:

- Camera interface and image capture
- Image cropping and adjustment
- Image enhancement and filter application
- Edge detection and perspective correction
- Image quality optimization
- Image format conversion and compression

## Interface Design

### Main Classes and Interfaces

#### 1. ImageProcessingViewModel

Manages image processing states and operations, coordinating different image processing functions.

```kotlin
class ImageProcessingViewModel(
    private val imageProcService: ImageProcService
) : ViewModel() {
    // UI state
    private val _uiState = MutableStateFlow(ImageProcessingUiState())
    val uiState: StateFlow<ImageProcessingUiState> = _uiState.asStateFlow()
    
    // Load images
    fun loadImages(uris: List<String>) {
        viewModelScope.launch {
            _uiState.update { it.copy(
                isLoading = true,
                originalImageUris = uris,
                currentImageIndex = 0
            )}
            
            try {
                if (uris.isNotEmpty()) {
                    val bitmap = loadBitmapFromUri(uris[0])
                    _uiState.update { it.copy(
                        editingBitmap = bitmap,
                        isLoading = false
                    )}
                    detectDocumentCorners()
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false) }
                // Error handling
            }
        }
    }
    
    // Apply binarization filter
    fun applyBinarizationFilter() {
        applyFilter("Black & White") { bitmap ->
            imageProcService.applyThresholdFilter(bitmap, 4)
        }
    }
    
    // Apply high contrast filter
    fun applyHighContrastFilter() {
        applyFilter("High Contrast") { bitmap ->
            imageProcService.applyHighContrast(bitmap)
        }
    }
    
    // Detect document corners
    fun detectDocumentCorners() {
        viewModelScope.launch {
            val bitmap = _uiState.value.editingBitmap ?: return@launch
            _uiState.update { it.copy(isLoading = true) }
            
            try {
                val corners = imageProcService.detectDocumentCorners(bitmap)
                _uiState.update { it.copy(
                    detectedCorners = corners,
                    adjustedCorners = corners.clone(),
                    isLoading = false
                )}
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false) }
                // Error handling
            }
        }
    }
    
    // Apply perspective correction
    fun applyPerspectiveCorrection() {
        viewModelScope.launch {
            val bitmap = _uiState.value.editingBitmap ?: return@launch
            val corners = _uiState.value.adjustedCorners ?: return@launch
            
            _uiState.update { it.copy(isLoading = true) }
            
            try {
                val correctedBitmap = imageProcService.applyPerspectiveTransform(bitmap, corners)
                _uiState.update { it.copy(
                    editingBitmap = correctedBitmap,
                    isCornerAdjustmentMode = false,
                    detectedCorners = null,
                    adjustedCorners = null,
                    isLoading = false
                )}
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false) }
                // Error handling
            }
        }
    }
    
    // Generic filter application function
    private fun applyFilter(filterName: String, filter: suspend (Bitmap) -> Bitmap) {
        viewModelScope.launch {
            val bitmap = _uiState.value.editingBitmap ?: return@launch
            _uiState.update { it.copy(isLoading = true) }
            
            try {
                val filteredBitmap = filter(bitmap)
                _uiState.update { it.copy(
                    editingBitmap = filteredBitmap,
                    appliedFilter = filterName,
                    isLoading = false
                )}
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false) }
                // Error handling
            }
        }
    }
}

// UI state data class
data class ImageProcessingUiState(
    val isLoading: Boolean = false,
    val originalImageUris: List<String> = emptyList(),
    val currentImageIndex: Int = 0,
    val editingBitmap: Bitmap? = null,
    val isFilterToolbarVisible: Boolean = false,
    val isPerspectiveToolbarVisible: Boolean = false,
    val appliedFilter: String? = null,
    val isCornerAdjustmentMode: Boolean = false,
    val detectedCorners: Array<PointF>? = null,
    val adjustedCorners: Array<PointF>? = null
)
```

#### 2. ImageProcService

Provides low-level image processing algorithms, implementing edge detection, perspective correction, and other functions.

```kotlin
class ImageProcService {
    // Apply threshold filter (binarization)
    fun applyThresholdFilter(bitmap: Bitmap, type: Int): Bitmap {
        val result = Bitmap.createBitmap(bitmap.width, bitmap.height, bitmap.config)
        val threshold = when (type) {
            1 -> 100
            2 -> 127
            3 -> 150
            else -> 127
        }
        
        // Binarization processing
        for (x in 0 until bitmap.width) {
            for (y in 0 until bitmap.height) {
                val pixel = bitmap.getPixel(x, y)
                val gray = (Color.red(pixel) + Color.green(pixel) + Color.blue(pixel)) / 3
                val newPixel = if (gray > threshold) Color.WHITE else Color.BLACK
                result.setPixel(x, y, newPixel)
            }
        }
        
        return result
    }
    
    // Apply high contrast filter
    fun applyHighContrast(bitmap: Bitmap): Bitmap {
        val result = Bitmap.createBitmap(bitmap.width, bitmap.height, bitmap.config)
        val canvas = Canvas(result)
        val paint = Paint()
        val colorMatrix = ColorMatrix()
        
        // Increase contrast
        colorMatrix.set(floatArrayOf(
            2.0f, 0f, 0f, 0f, -128f,
            0f, 2.0f, 0f, 0f, -128f,
            0f, 0f, 2.0f, 0f, -128f,
            0f, 0f, 0f, 1f, 0f
        ))
        
        paint.colorFilter = ColorMatrixColorFilter(colorMatrix)
        canvas.drawBitmap(bitmap, 0f, 0f, paint)
        
        return result
    }
    
    // Detect document corners
    fun detectDocumentCorners(bitmap: Bitmap): Array<PointF> {
        // Edge detection algorithm implementation
        // 1. Convert to grayscale
        // 2. Apply Gaussian blur
        // 3. Apply Canny edge detection
        // 4. Find contours
        // 5. Approximate polygons
        // 6. Find the largest quadrilateral
        
        // Simplified implementation, returns default corners
        return arrayOf(
            PointF(0f, 0f),
            PointF(bitmap.width.toFloat(), 0f),
            PointF(bitmap.width.toFloat(), bitmap.height.toFloat()),
            PointF(0f, bitmap.height.toFloat())
        )
    }
    
    // Apply perspective transform
    fun applyPerspectiveTransform(bitmap: Bitmap, corners: Array<PointF>): Bitmap {
        // Perspective transform algorithm implementation
        // 1. Calculate target rectangle
        // 2. Create transformation matrix
        // 3. Apply transformation
        
        // Simplified implementation, returns original image
        return bitmap.copy(bitmap.config, true)
    }
}
```

#### 3. CameraCaptureScreen

Provides camera interface, handling image capture and preview.

## Design Patterns and Extension Points

### Design Patterns

#### 1. Strategy Pattern
- Different image processing algorithms are encapsulated as independent strategies
- Strategy switching is implemented through the high-order function `applyFilter`

#### 2. Command Pattern
- Image processing operations are encapsulated as independent commands
- Supports operation history and undo functionality

#### 3. State Pattern
- Uses `ImageProcessingUiState` to manage complex UI states
- Different operations are enabled in different states

### Extension Points

#### 1. Custom Filters
- New image processing algorithms can be extended
- Supports custom filter parameters

#### 2. Edge Detection Algorithms
- Edge detection algorithms can be replaced or enhanced
- Supports optimization for different scenarios

#### 3. Image Analysis Plugins
- New image analysis functions can be added
- Supports domain-specific image processing requirements

#### 4. Camera Control Extensions
- Camera functions and control options can be extended
- Supports advanced shooting modes

## Image Processing Workflow

The image processing workflow typically involves these steps:

1. **Image Capture**: User captures an image using the camera or selects from the gallery
2. **Initial Processing**: Basic processing like rotation and cropping
3. **Edge Detection**: Automatic detection of document edges
4. **Perspective Correction**: Correction of perspective distortion
5. **Enhancement**: Application of filters to enhance readability
6. **Final Processing**: Final adjustments before saving or further processing

This workflow ensures that captured images are optimized for document and form processing, improving the accuracy of subsequent text extraction and field recognition.