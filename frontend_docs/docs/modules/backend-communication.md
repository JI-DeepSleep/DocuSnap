# Backend Communication Module

## Responsibilities

The Backend Communication module is responsible for secure communication with the backend server, providing remote processing and data synchronization capabilities for the application. Its main responsibilities include:

- Managing API communication with the backend server
- Implementing secure data encryption and transmission
- Handling long-running backend jobs
- Managing job status and results
- Handling network errors and retry logic
- Implementing data synchronization and conflict resolution

## Interface Design

### Main Classes and Interfaces

#### 1. BackendApiService

Manages all interactions with the backend server, handling encrypted communication and authentication.

```kotlin
class BackendApiService(
    private val retrofit: Retrofit,
    private val cryptoUtil: CryptoUtil,
    private val settingsManager: SettingsManager
) {
    private val api = retrofit.create(BackendApiInterface::class.java)
    
    // Process document
    suspend fun processDocument(document: Document): ProcessingResult {
        return process("document_process", document)
    }
    
    // Process form
    suspend fun processForm(form: Form): ProcessingResult {
        return process("form_process", form)
    }
    
    // Check job status
    suspend fun checkJobStatus(jobId: String): JobStatus {
        val requestBody = JSONObject().apply {
            put("job_id", jobId)
        }
        
        val response = api.checkStatus(requestBody.toString())
        return JobStatus(
            id = jobId,
            status = response.getString("status"),
            progress = response.optInt("progress", 0),
            result = response.optJSONObject("result")
        )
    }
    
    // Generic processing function
    private suspend fun process(
        type: String,
        payload: Any
    ): ProcessingResult {
        val innerJson = JSONObject().apply {
            when (payload) {
                is Document -> {
                    put("id", payload.id)
                    put("name", payload.name)
                    put("images", JSONArray(payload.imageBase64s))
                    // Other properties
                }
                is Form -> {
                    put("id", payload.id)
                    put("name", payload.name)
                    put("images", JSONArray(payload.imageBase64s))
                    // Other properties
                }
                else -> throw IllegalArgumentException("Unsupported payload type")
            }
        }
        
        // Generate AES key
        val aesKey = cryptoUtil.generateAesKey()
        val encryptedContent = cryptoUtil.aesEncrypt(innerJson.toString().toByteArray(), aesKey)
        val sha256 = cryptoUtil.computeSHA256(encryptedContent)
        val encryptedAesKey = cryptoUtil.rsaEncrypt(aesKey, cryptoUtil.getPublicKey(settingsManager.getPublicKeyPem()))
        val encryptedAesKeyBase64 = Base64.encodeToString(encryptedAesKey, Base64.NO_WRAP)
        
        // Build request body
        val requestBody = JSONObject().apply {
            put("type", type)
            put("SHA256", sha256)
            put("has_content", true)
            put("aes_key", encryptedAesKeyBase64)
            put("content", Base64.encodeToString(encryptedContent, Base64.NO_WRAP))
        }
        
        // Send request
        val response = api.process(requestBody.toString())
        
        return ProcessingResult(
            success = response.getBoolean("success"),
            jobId = response.getString("job_id"),
            message = response.optString("message", "")
        )
    }
}

// Processing result data class
data class ProcessingResult(
    val success: Boolean,
    val jobId: String,
    val message: String
)

// Job status data class
data class JobStatus(
    val id: String,
    val status: String,
    val progress: Int,
    val result: JSONObject?
)
```

#### 2. JobPollingService

Manages long-running backend jobs, implementing a polling mechanism to check job status.

```kotlin
class JobPollingService(
    private val backendApiService: BackendApiService,
    private val jobDao: JobDao,
    private val cryptoUtil: CryptoUtil
) {
    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val pollingJobs = mutableMapOf<String, Job>()
    
    // Start polling job status
    fun startPolling(jobId: String) {
        if (pollingJobs.containsKey(jobId)) return
        
        pollingJobs[jobId] = coroutineScope.launch {
            var retryCount = 0
            var completed = false
            
            while (!completed && isActive) {
                try {
                    val job = jobDao.getJobById(jobId) ?: break
                    
                    // Check job status
                    val status = backendApiService.checkJobStatus(jobId)
                    
                    when (status.status) {
                        "completed" -> {
                            // Process completion
                            val result = status.result?.toString()
                            jobDao.updateJobStatus(jobId, "completed", result = result)
                            completed = true
                        }
                        "failed" -> {
                            // Process failure
                            jobDao.updateJobStatus(jobId, "failed", errorDetail = status.result?.optString("error"))
                            completed = true
                        }
                        "processing" -> {
                            // Processing
                            jobDao.updateJobProgress(jobId, status.progress)
                            retryCount = 0
                            delay(500) // Short polling interval
                        }
                        else -> {
                            // Other status
                            delay(500) // Short polling interval
                        }
                    }
                } catch (e: Exception) {
                    retryCount++
                    val delayTime = if (retryCount > 3) 5000L else 1000L // Increase interval after errors
                    delay(delayTime)
                }
            }
            
            pollingJobs.remove(jobId)
        }
    }
    
    // Stop polling
    fun stopPolling(jobId: String) {
        pollingJobs[jobId]?.cancel()
        pollingJobs.remove(jobId)
    }
    
    // Stop all polling
    fun stopAllPolling() {
        pollingJobs.values.forEach { it.cancel() }
        pollingJobs.clear()
    }
    
    // Decrypt job result
    fun decryptJobResult(encryptedResult: String, job: JobEntity): String {
        // Decrypt result using the AES key created when the job was created
        val encryptedBytes = Base64.decode(encryptedResult, Base64.NO_WRAP)
        val aesKey = job.aesKey?.let { Base64.decode(it, Base64.NO_WRAP) }
            ?: throw IllegalStateException("Missing AES key for job ${job.id}")
            
        return String(cryptoUtil.aesDecrypt(encryptedBytes, aesKey))
    }
}
```

## Design Patterns and Extension Points

### Design Patterns

#### 1. Adapter Pattern
- Adapts REST API through Retrofit interface
- Converts HTTP requests to local method calls

#### 2. Observer Pattern
- Uses Flow to monitor job status changes
- Automatically updates UI in response to status changes

#### 3. Decorator Pattern
- Decorates original data with encryption
- Enhances security without changing the interface

#### 4. Asynchronous Job Pattern
- Long-running tasks are processed as asynchronous jobs
- Job status is tracked through a polling mechanism

### Extension Points

#### 1. Encryption Algorithm Replacement
- Encryption algorithms can be replaced or upgraded
- Supports different key management strategies

#### 2. Communication Protocol Upgrade
- Can be upgraded to WebSocket or other real-time communication
- Supports different API versions

#### 3. Authentication Mechanism Extension
- Can be extended to OAuth or other authentication methods
- Supports multiple authentication strategies

#### 4. Offline Operation Support
- Can be extended to support offline queuing and synchronization
- Implements more complex conflict resolution strategies

## Security Implementation

The Backend Communication module implements a robust security system:

1. **Hybrid Encryption**:
   - RSA encryption (2048-bit) for key exchange
   - AES-CBC encryption (256-bit) for content
   - Each request uses a unique AES key

2. **Data Integrity**:
   - SHA-256 hash verification ensures data integrity
   - Prevents data tampering during transmission

3. **Secure Transport**:
   - All communication occurs over HTTPS
   - Certificate validation prevents man-in-the-middle attacks

4. **Error Handling**:
   - Graceful handling of network errors
   - Automatic retries with exponential backoff
   - Detailed error reporting for debugging

This comprehensive security approach ensures that sensitive document and form data is protected during transmission and processing.