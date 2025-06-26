# Getting Started

This section outlines how to build and run the project, along with the **direct** third-party tools, libraries, SDKs, and APIs used.  

### **Front-End (Android)**  
Built with **Android Studio** targeting **Android 13 (API Level 33)**.  

#### **Dependencies**  
- **Encryption**:  
  - [Bouncy Castle](https://www.bouncycastle.org/) – Cryptographic algorithms.  
  - [Android Keystore System](https://developer.android.com/training/articles/keystore) – Secure key storage.  
- **Networking**:  
  - [OkHttp](https://square.github.io/okhttp/) – Underlying HTTP/2 support.  

### **Back-End (Flask)**  
Built with **Python**, using the following core dependencies:  

#### **Dependencies**  
- **Web Framework**:  
  - [Flask](https://flask.palletsprojects.com/) – Lightweight WSGI server.  
  - [Gunicorn](https://gunicorn.org/) – Production-grade WSGI HTTP server.  
- **Database**:  
  - [SQLite](https://www.sqlite.org/index.html) – Embedded relational database.  
- **OCR & AI Tools**:  
  - [CnOcr](https://github.com/breezedeus/cnocr) – Chinese and English OCR library.  
  - [Zhipu AI API](https://open.bigmodel.cn/) – Integration for generative AI tasks.  

### **Notes**  
- **Android Setup**: Ensure **Android SDK 33** is configured in Android Studio.  
- **Back-End Setup**: Use `pip install -r requirements.txt` .  

# Model and Engine

# APIs and Controller

### 1. Frontend Modules (Function Calls)
Internal frontend APIs via function calls.

#### Camera/Gallery Module
```typescript
function captureImage(source: "camera" | "gallery"): Image
```
- Captures/selects image from device camera or gallery
- Returns raw image object

#### Geometric Correction
```typescript
function correctGeometry(image: Image): Image
```
- Applies perspective correction and deskewing
- Returns geometrically corrected image

#### Color Enhancement
```typescript
function enhanceColors(image: Image): Image
```
- Optimizes contrast, brightness and color balance
- Returns color-enhanced image

#### Document Handler
```typescript
function processDocument(enhancedImage: Image): { encryptedDoc: string, sha256: string }
```
- Processes generic documents
- Returns RSA-encrypted document and SHA256 hash

#### Form Handler
```typescript
function processForm(enhancedImage: Image, formType: string): { encryptedDoc: string, sha256: string }
```
- Processes structured forms using DB templates
- Returns encrypted document and SHA256 hash

#### Frontend Database
```typescript
// Document storage
function saveDocument(sha256: string, metadata: JSON): boolean
function getDocument(sha256: string): Document
function updateDocumentData(sha256: string, updates: JSON): boolean

// Form data storage
function saveFormData(formId: string, data: JSON): boolean
function getFormData(formId: string): JSON
```

### 2. Backend Server (Flask)
Main entry point for processing requests and status checks.

#### Endpoint: `/api/process_document`
| **Request Parameters** | | ||
| ---------------------- | ----------- | ----------------- | -------------------------------------------- |
| `client_id`| Body (JSON) | `String` (UUID) | **Required** Client identifier |
| `sha256_key` | Body (JSON) | `String`| **Required** SHA256 hash of the document |
| `image`| Body (JSON) | `String` (Base64) | **Optional** RSA-encrypted image data|
| `encryption_key` | Body (JSON) | `String`| **Optional** User encryption key for results |

**Validation Rules**:
- If `image` is provided:
1. `encryption_key` must be present (else `400`)
2. Backend decrypts image using its private RSA key
3. SHA256 of decrypted image must match `sha256_key` (else `400`)

| **Response Codes** | |
| ------------------ | ------------------------- |
| `200 OK` | Result available|
| `202 Accepted` | Processing in progress|
| `400 Bad Request`| Invalid input/missing key |
| `404 Not Found`| SHA256 not recognized |
| `500 Server Error` | Internal processing error |

**Returns** (Case 1: Result Available):
| **Key**| **Type** | **Description** |
| -------- | -------- | ------------------------- |
| `status` | `String` | `"complete"`|
| `result` | `String` | Encrypted with user's key |

**Returns** (Case 2: Processing In Progress):
| **Key**| **Type** | **Description** |
| -------- | -------- | --------------- |
| `status` | `String` | `"processing"`|

**Returns** (Case 3: Error State):
| **Key**| **Type** | **Description**|
| -------- | -------- | -------------------------------------------------- |
| `status` | `String` | `"error_processing"` or `"error_sha256_not_found"` |
| `detail` | `String` | Error description|

#### Endpoint: `/api/clear`
| **Request Parameters** | | | |
| ---------------------- | ----------- | --------------- | --------------------------------------- |
| `client_id`| Body (JSON) | `String` (UUID) | **Required** Client identifier|
| `sha256_key` | Body (JSON) | `String`| **Optional** Specific document to clear |

| **Response Codes** ||
| ------------------ | -------------------- |
| `200 OK` | Clearance successful |
| `400 Bad Request`| Missing client_id|
| `500 Server Error` | Clearance failed |

**Returns**:
| **Key** | **Type**| **Description** |
| --------- | --------- | --------------------------------------- |
| `cleared` | `Integer` | Number of entries cleared |
| `status`| `String`| `"all_cleared"` or `"specific_cleared"` |

### 3. Cache Server(Flask+SQLite)
Stores encrypted processing results. Uses composite keys: `(client_id, sha256_key)`.

#### Endpoint: `/api/cache/query`
| **Request Parameters** | | ||
| ---------------------- | ----------- | --------------- | -------------------------- |
| `client_id`| Query Param | `String` (UUID) | Client identifier|
| `sha256_key` | Query Param | `String`| SHA256 key of the document |

| **Response Codes** | |
| ------------------ | ------------------- |
| `200 OK` | Cache entry found |
| `404 Not Found`| Cache entry missing |

**Returns** (Success):
| **Key** | **Type** | **Description**|
| ------- | -------- | ---------------- |
| `data`| `String` | Encrypted result |

#### Endpoint: `/api/cache/store`
| **Request Parameters** | | ||
| ---------------------- | ----------- | --------------- | -------------------------- |
| `client_id`| Body (JSON) | `String` (UUID) | Client identifier|
| `sha256_key` | Body (JSON) | `String`| SHA256 key of the document |
| `data` | Body (JSON) | `String`| Encrypted result to store|

| **Response Codes** ||
| ------------------ | ------------------ |
| `201 Created`| Cache entry stored |

**Returns**: Empty body

#### Endpoint: `/api/cache/clear`
| **Request Parameters** | | | |
| ---------------------- | ----------- | --------------- | --------------------------------------- |
| `client_id`| Body (JSON) | `String` (UUID) | **Required** Client identifier|
| `sha256_key` | Body (JSON) | `String`| **Optional** Specific document to clear |

| **Response Codes** ||
| ------------------ | -------------------- |
| `200 OK` | Clearance successful |

**Returns**:
| **Key** | **Type**| **Description** |
| --------- | --------- | ------------------------- |
| `cleared` | `Integer` | Number of entries cleared |

### 4. OCR Server(CnOCR)
Performs text extraction.

#### Endpoint: `/api/ocr/extract`
| **Request Parameters** | | ||
| ---------------------- | ----------- | ----------------- | ---------------------------- |
| `image_data` | Body (JSON) | `String` (Base64) | Decrypted image from backend |

| **Response Codes** ||
| ------------------ | -------------- |
| `200 OK` | Text extracted |

**Returns**:
| **Key** | **Type** | **Description**|
| ------- | -------- | ------------------ |
| `text`| `String` | Extracted raw text |

## Third-Party SDKs

### 1. LLM API Provider (Zhipu)
Format OCR data using LLM.
- **API Documentation**:
[GLM-4](https://bigmodel.cn/dev/api/normal-model/glm-4)
[GLM-Z1](https://bigmodel.cn/dev/api/Reasoning-models/glm-z1)

### 2. CnOCR

Chinese/English OCR tool for text recognition. 

- **API Documentation:**

  [CnOCR](https://github.com/breezedeus/CnOCR/blob/master/README_en.md)

# View UI/UX

# Team Roster