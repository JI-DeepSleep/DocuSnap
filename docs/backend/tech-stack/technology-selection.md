# Technology Selection

The DocuSnap-Backend system employs a series of modern technologies and frameworks to achieve efficient, secure, and scalable document and form processing capabilities. This page provides detailed information about the system's technology stack choices.

## Backend Framework

### Flask (3.1.1)

[Flask](https://flask.palletsprojects.com/) is a lightweight Python Web framework used to build the API service for DocuSnap-Backend.

**Key Features**:
- Lightweight, flexible, and easily extensible
- Simple and intuitive API design
- Rich plugin ecosystem
- Suitable for rapid prototype development and small to medium-sized applications

**Application in the System**:
- Provides RESTful API interfaces
- Handles HTTP requests and responses
- Manages routing and request dispatching
- Handles errors and exceptions

## Database

### SQLite3

[SQLite](https://www.sqlite.org/) is a lightweight embedded relational database used to store task status and processing results.

**Key Features**:
- Zero configuration, self-contained, serverless
- Lightweight, efficient, reliable
- Supports standard SQL queries
- Suitable as an embedded application database

**Application in the System**:
- Stores task status and processing results
- Serves as a caching system to reduce repeated computations
- Manages temporary data storage
- Supports task status queries and result retrieval

## AI/LLM Service

### Zhipu AI (zhipuai 2.1.5)

[Zhipu AI](https://www.zhipuai.cn/) is a Chinese AI service provider that offers Large Language Model APIs for document analysis and information extraction.

**Key Features**:
- Provides high-quality Chinese LLM services
- Supports complex natural language understanding and generation
- Offers structured output capabilities
- Supports custom prompt engineering

**Application in the System**:
- Analyzes document structure and content
- Extracts form fields and values
- Understands document context and semantics
- Generates structured processing results

## OCR Service

### CnOCR

[CnOCR](https://github.com/breezedeus/cnocr) is an OCR tool optimized specifically for Chinese, used to convert images to text.

**Key Features**:
- OCR engine optimized for Chinese
- High accuracy text recognition
- Supports multiple image formats
- Open-source and customizable

**Application in the System**:
- Converts document and form images to text
- Recognizes form structure and fields
- Supports batch image processing
- Operates as an independent service interacting with the backend server

## Security Encryption

### RSA and AES Encryption

The system uses a hybrid encryption scheme with RSA and AES to secure data transmission.

**Key Features**:
- RSA asymmetric encryption for key exchange
- AES symmetric encryption for data encryption
- SHA256 hash for data integrity verification
- End-to-end encryption to protect sensitive data

**Application in the System**:
- Secures API requests and responses
- Encrypts sensitive document and form data
- Verifies the integrity and authenticity of requests
- Prevents data leakage and tampering

## Concurrent Processing

### Python Standard Library

The system uses concurrent processing tools from the Python standard library, such as `threading` and `concurrent.futures`.

**Key Features**:
- `Queue` for thread-safe task queues
- `threading` for creating and managing threads
- `ThreadPoolExecutor` for parallel task processing
- `Semaphore` for controlling concurrent access

**Application in the System**:
- Implements producer-consumer pattern for task processing
- Processes multiple images and documents in parallel
- Controls concurrent requests to external services
- Improves overall system processing efficiency

## Development and Testing Tools

### Other Tools and Libraries

The system also uses various auxiliary tools and libraries for development, testing, and deployment.

**Main Components**:
- `json` for data serialization and deserialization
- `base64` for binary data encoding
- `logging` for log recording and management
- `time` and `datetime` for time management and calculations

These technical components collectively form the technology stack of DocuSnap-Backend, supporting the system's core functionality and performance requirements. Each component has been carefully selected to ensure system stability, security, and scalability.
