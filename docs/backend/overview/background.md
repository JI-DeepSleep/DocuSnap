# Project Background

## Project Origins

DocuSnap-Backend is a university graduation project designed to provide a better document and form processing experience than current OCR tools. The project aims to combine OCR technology with the capabilities of Large Language Models (LLM) to achieve efficient and accurate document recognition and information extraction.

## Project Positioning

DocuSnap-Backend is positioned as a backend service focused on OCR recognition and AI analysis of documents and forms. It provides document processing, form processing, and form auto-filling functions for frontend applications through REST API interfaces.

## Project Objectives

1. **Improve Document Processing Efficiency**: Enhance the efficiency and accuracy of document recognition and information extraction by combining OCR and LLM technologies.
2. **Simplify Form Processing Workflow**: Automatically recognize form structure and content, reducing manual input and processing time.
3. **Enhance Data Security**: Protect the transmission security of sensitive documents and form data through end-to-end encryption.
4. **Provide Flexible Integration Methods**: Facilitate integration with various frontend applications and systems through REST API interfaces.

## Project Challenges

1. **OCR Accuracy**: Ensuring OCR recognition accuracy across various document qualities and formats.
2. **LLM Prompt Engineering**: Designing effective prompts to guide LLM in accurately extracting and processing document information.
3. **Performance Optimization**: Optimizing performance when handling large concurrent requests and large documents.
4. **Security Assurance**: Ensuring secure transmission and processing of sensitive documents and form data.

## Technology Selection Considerations

During the project development process, the team considered various technology options and ultimately chose the current technology stack based on the following factors:

1. **Flask Framework**: Lightweight, flexible, and easily extensible, suitable for rapid API service development.
2. **SQLite Database**: Lightweight, no need for a separate server, suitable for caching and task status storage.
3. **Zhipu AI**: Provides high-quality Chinese LLM services, suitable for processing Chinese documents and forms.
4. **CnOCR**: An OCR service optimized for Chinese, providing higher Chinese recognition accuracy.
5. **RSA and AES Encryption**: Combining two encryption technologies to achieve efficient and secure end-to-end encryption.

Through these technology choices, DocuSnap-Backend can effectively process documents and forms, providing high-quality OCR recognition and AI analysis services.
