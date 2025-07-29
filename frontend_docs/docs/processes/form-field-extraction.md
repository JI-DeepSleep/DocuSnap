# Form Field Extraction Process

Form field extraction is a key process in DocuSnap-Frontend that involves capturing form images, processing them, and extracting field information. This process is similar to document scanning but has specific differences in backend processing and data modeling.

## Detailed Form Processing Flow

### 1. Form Capture Phase

- User captures form images through the `CameraCaptureScreen`
- Image data is passed to the `ImageProcessingScreen`
- The camera interface provides guidance for optimal form capture
- Multiple images can be captured for multi-page forms

### 2. Image Processing Phase

- Similar to document scanning, images undergo edge detection, perspective correction, and enhancement
- Processing is optimized specifically for form field recognition
- Enhanced images are passed to the `FormDetailScreen`

### 3. Form Creation Phase

- `FormDetailScreen` calls `DocumentViewModel` (shared ViewModel) to create a form object
- User inputs form name, description, and tags
- ViewModel calls Repository to save the form
- Form metadata is associated with the processed images

### 4. Field Extraction Request Phase

- Repository calls `BackendApiService` to send the form to the backend for field extraction
- Backend returns a job ID, and a job record is created
- `JobPollingService` begins polling for job status
- The form is marked as "processing" in the local database

### 5. Field Extraction Result Processing Phase

- When the job completes, `JobPollingService` retrieves and decrypts the results
- Results include recognized form fields (names and values)
- Repository updates the form entity, adding the extracted fields
- The form status is updated to reflect the extraction completion

### 6. Field Editing Phase

- `FormDetailScreen` displays the extracted fields
- User can edit, confirm, or add fields
- Changes are saved to the database through the ViewModel
- Field validation rules can be applied during editing

### 7. Form Completion Phase

- After editing, the form is marked as processed
- Form data can be exported or integrated with other systems
- Form usage statistics are updated
- Form is available for future reference and searching

## Differences from Document Scanning

While the form field extraction process shares similarities with document scanning, there are key differences:

1. **Field Recognition Focus**:
   - Forms focus on structured field extraction
   - Documents focus on general text extraction
   - Form processing identifies field names and values as pairs

2. **User Interaction**:
   - Form processing typically requires more user verification and editing
   - Field values often need validation against specific rules
   - Form fields have relationships that need to be preserved

3. **Backend Processing**:
   - Form processing uses specialized field extraction algorithms
   - Form templates can be applied to improve recognition
   - Field extraction includes confidence scores for user verification

4. **Data Model**:
   - Forms have a structured `formFields` collection
   - Each field has a name, value, and extraction status
   - Forms track field relationships and dependencies

## Integration with Other Systems

The form field extraction process is designed to integrate with other systems:

1. **Data Export**:
   - Extracted form data can be exported in various formats (JSON, CSV, etc.)
   - Export includes both field data and form metadata

2. **Template Learning**:
   - Frequently processed form types can be learned as templates
   - Templates improve future extraction accuracy for similar forms

3. **Workflow Integration**:
   - Extracted form data can trigger workflows in other systems
   - Integration APIs allow for seamless data transfer

This form field extraction process demonstrates how DocuSnap-Frontend combines automated processing with user interaction to provide an efficient and accurate form data capture and management solution.