# Architecture Diagrams

This page presents various architecture diagrams of the DocuSnap-Backend system, helping readers understand the system design and component relationships from different perspectives.

## Overall Architecture Diagram

The following diagram shows the overall architecture of DocuSnap-Backend, including the three-layer architecture (Backend Server, OCR Server, LLM Provider) and the main data flows.

![Overall Architecture Diagram](../image/overall_architecture.png)

**Diagram Explanation**:

1. **Client Layer**:
   - Shows different types of clients interacting with the system
   - Communicates with the backend server via encrypted REST API

2. **Backend Server Layer**:
   - The core component of the system, based on Flask framework
   - Contains multiple functional modules such as task processing, security encryption, caching, etc.
   - Manages communication with OCR server and LLM provider

3. **OCR Server Layer**:
   - Independent OCR processing service, based on CnOCR
   - Responsible for image text recognition

4. **LLM Provider Layer**:
   - External LLM service (Zhipu AI)
   - Provides text analysis and information extraction capabilities

5. **Data Flow**:
   - Arrows indicate the direction of data flow
   - Shows the complete path of request processing

This architecture diagram clearly shows the layered structure and component relationships of the system, helping to understand the overall design and working principles of the system.

## Core Modules Relationship Diagram

The following diagram shows the relationships and interactions between the five core modules of the DocuSnap-Backend system.

![Core Modules Relationship Diagram](../image/core_modules_relationship.png)

**Diagram Explanation**:

1. **Task Processing Module**:
   - Located at the center of the system, coordinating the work of other modules
   - Manages task queues and worker threads
   - Interacts with all other modules

2. **OCR Processing Module**:
   - Responsible for image processing and OCR service calls
   - Interacts with the Task Processing Module and LLM Processing Module

3. **LLM Processing Module**:
   - Responsible for prompt construction and LLM API calls
   - Processes OCR results, generates structured output

4. **Security & Encryption Module**:
   - Provides end-to-end encryption and request validation
   - Protects communication security with clients

5. **Cache & Persistence Module**:
   - Manages storage of task status and results
   - Provides cache query and cleanup functions

The connections between modules represent their dependencies and data flows, with different colors distinguishing the functional scope of different modules.

## Data Flow Diagram

The following diagram shows the complete process of data processing in the DocuSnap-Backend system, from client request to response.

![Data Flow Diagram](../image/data_flow_diagram.png)

**Diagram Explanation**:

1. **Request Processing Phase**:
   - Client sends encrypted request
   - System decrypts and validates
   - Checks task status, decides whether to create a new task

2. **Task Processing Phase**:
   - Task enters the queue
   - Worker thread retrieves task
   - Selects processing strategy based on task type

3. **OCR Processing Phase**:
   - Sends images to OCR service
   - Processes multiple images in parallel
   - Merges OCR results

4. **LLM Processing Phase**:
   - Builds prompts suitable for task type
   - Calls LLM API
   - Parses LLM response

5. **Result Processing Phase**:
   - Stores processing results
   - Encrypts response data
   - Returns results to client

The numbers in the data flow diagram indicate the sequence of processing steps, helping to understand the system's workflow and data transformation process.

## Deployment Architecture Diagram

The following diagram shows the deployment architecture of the DocuSnap-Backend system in a production environment.

![Deployment Architecture Diagram](../image/deployment_architecture.png)

**Diagram Explanation**:

1. **Frontend Deployment**:
   - Web clients and mobile clients
   - Communicates with backend via HTTPS

2. **Load Balancing Layer**:
   - Nginx reverse proxy
   - Distributes requests to multiple application instances

3. **Application Service Layer**:
   - Multiple Flask application instances
   - Uses Gunicorn as WSGI server

4. **OCR Service Layer**:
   - Independent OCR service instances
   - Can be horizontally scaled

5. **Data Storage Layer**:
   - SQLite database for caching
   - File storage for temporary data

6. **External Service Layer**:
   - Zhipu AI LLM service
   - Other potential external services

The deployment architecture diagram shows the distribution and connection of system components in physical or virtual environments, helping to understand the system's deployment structure and scaling strategy.

## Architecture Diagram Design Notes

All architecture diagrams were created using GraphViz tools, following these design principles:

1. **Clear Hierarchical Structure**: Using layered layouts to clearly show system component relationships
2. **Consistent Visual Style**: Using unified colors and shapes to identify different types of components
3. **Detailed Annotations**: Adding appropriate labels and notes to explain diagram content
4. **Separation of Concerns**: Different diagrams focus on different aspects of the system, providing a comprehensive perspective

Together, these architecture diagrams provide a comprehensive view of the DocuSnap-Backend system design, helping readers understand the system architecture and working principles from different angles.
