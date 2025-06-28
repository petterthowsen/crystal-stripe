# Crystal Stripe API Library - Implementation Plan

This document outlines a Test-Driven Development (TDD) implementation plan for the Crystal Stripe API library, focusing on core functionality for payment processing and subscription management.

## Implementation Philosophy

Our implementation will follow these key principles:

1. **Test-Driven Development**: Write tests first, then implement functionality to pass those tests
2. **Incremental Delivery**: Build the library in phases, starting with core functionality
3. **Type Safety**: Leverage Crystal's type system for robust API interactions with strong type mappings
4. **Idiomatic Crystal**: Follow Crystal's conventions and best practices
5. **Comprehensive Testing**: Use unit tests, integration tests, mocks, and VCR-style HTTP recordings
6. **Security-First Design**: Implement best practices for API key management and PII handling
7. **Event-Driven Architecture**: Support Stripe's webhook system for asynchronous processing

## Phase 1: Core Infrastructure

This phase establishes the foundational components needed for the Stripe API client.

### Task 1.1: Project Setup, Dependencies, and Configuration

**Tests:**
- [x] Test basic project structure and shard installation
- [x] Test configuration loading from environment variables
- [x] Test configuration loading from configuration files
- [x] Test secure API key management utilities

**Implementation:**
- [x] Create project structure (src/, spec/, README.md, shard.yml)
- [x] Analyze and select optimal Crystal dependencies:
  - HTTP client library evaluation (stdlib HTTP vs. alternatives)
  - JSON parsing library selection (stdlib JSON vs. alternatives)
  - Consider external security libraries for API key management
- [x] Define initial dependencies in shard.yml with explicit versioning
- [x] Implement configuration module for API keys with secure storage patterns
- [x] Create basic spec helper with test utilities and VCR-style HTTP recording

**Deliverable:** Working project structure with secure configuration module and appropriate dependencies.

### Task 1.2: HTTP Client Implementation

**Tests:**
- [x] Test client initialization with different authentication options
- [x] Test proper header generation (auth, API version, idempotency)
- [x] Test request formatting for different HTTP methods
- [x] Test connection and request timeout handling
- [x] Test API key rotation mechanisms
- [x] Test secure header handling (no key leakage in logs)

**Implementation:**
- [x] Create Stripe::Client class extending HTTP::Client
- [x] Implement authentication methods (API key, bearer token) with PII protection
- [x] Implement header generation with API versions and safety checks
- [x] Add request timeout configurations with reasonable defaults
- [x] Implement support for connected accounts via Stripe-Account header
- [x] Add API key rotation mechanisms
- [x] Implement secure logging (redacting sensitive information)

**Deliverable:** Secure, functional HTTP client with robust authentication and PII protection.

### Task 1.3: Request/Response Handling with Strong Type Mapping

**Tests:**
- [x] Test parameter serialization (nested params, arrays)
- [x] Test successful response parsing with type validation
- [x] Test error response handling and exception mapping
- [x] Test pagination handling
- [x] Test object expansion parameters
- [x] Test metadata field handling

**Implementation:**
- [x] Implement parameter flattening for nested structures
- [x] Create response parser for Stripe JSON responses using Crystal's JSON::Serializable
- [x] Build strongly-typed response models leveraging Crystal's type system
- [x] Implement error handling and exception hierarchy with detailed error types
- [x] Create pagination utility for list responses with iterator pattern
- [x] Implement idempotency key handling and collision detection
- [x] Add support for Stripe's object expansion feature
- [x] Implement metadata field handling for all relevant resources

**Deliverable:** Type-safe request/response handling system with comprehensive error management and advanced Stripe features.

### Task 1.4: Resource Base Classes with Type Mapping

**Tests:**
- [x] Test base resource class initialization and attributes
- [x] Test resource serialization and deserialization with type validation
- [x] Test CRUD operations on mock resources
- [x] Test metadata handling on resources
- [x] Test object expansion and relations

**Implementation:**
- [x] Create StripeObject base class with JSON::Serializable for all resources
- [x] Implement macro-based field definitions with proper typing
- [x] Implement StripeResource for API-accessible resources
- [x] Create ListObject for paginated collections with proper iterator support
- [x] Implement standard CRUD methods (create, retrieve, update, delete)
- [x] Add common attribute handling (id, object, created, metadata)
- [x] Implement object expansion handling for nested resources
- [x] Add documentation to all public methods and classes

**Deliverable:** Type-safe base resource classes with comprehensive documentation.

### Task 1.5: Webhook Handling and Event Processing

**Tests:**
- [ ] Test webhook signature verification
- [ ] Test event object parsing and type mapping
- [ ] Test event type handling and routing
- [ ] Test webhook retry mechanisms

**Implementation:**
- [ ] Create WebhookEvent class with JSON::Serializable
- [ ] Implement signature verification using Stripe's algorithm
- [ ] Create type-safe event object mapping for all event types
- [ ] Implement event handler registration mechanism
- [ ] Add webhook timeout and retry handling
- [ ] Create convenient DSL for webhook handler registration
- [ ] Add detailed documentation for webhook setup

**Deliverable:** Complete webhook handling system with signature verification and type-safe event processing.

## Phase 2: Customer and Account Management 

### Task 2.1: Customer Resource

**Tests:**
- [x] Test customer creation with minimal fields
- [x] Test customer creation with all fields
- [x] Test customer retrieval, update, and deletion
- [x] Test customer listing with pagination
- [x] Test customer search functionality
- [x] Test customer metadata handling

**Implementation:**
- [x] Create Customer resource class with JSON::Serializable
- [x] Implement CRUD operations for customers
- [x] Add customer-specific methods and validations
- [x] Implement customer search functionality
- [x] Add customer metadata handling
- [x] Create comprehensive documentation with examples

**Deliverable:** Fully functional Customer resource with documentation.

### Task 2.2: Balance and Account Resources

**Tests:**
- [x] Test balance retrieval
- [x] Test transaction history pagination
- [ ] Test account retrieval and updates

**Implementation:**
- [x] Create Balance resource class
- [ ] Create Account resource class
- [x] Implement balance history retrieval with pagination
- [ ] Add account update functionality
- [x] Create documentation with examples

**Deliverable:** Account and balance management functionality.

## Phase 3: Payment Processing

This phase implements the core payment functionality using Payment Methods, Payment Intents, and Charges.

### Task 3.1: Payment Method Resource

**Tests:**
- [x] Test payment method creation for different types (card, bank account, etc.)
- [x] Test payment method attachment to customers
- [x] Test payment method retrieval and update
- [x] Test payment method detachment
- [x] Test payment method validation and error handling
- [x] Test metadata handling for payment methods

**Implementation:**
- [x] Create PaymentMethod resource class with JSON::Serializable and type-safe fields
- [x] Implement payment method type hierarchy with specialized classes for each method type
- [x] Add strong validations for each payment method type
- [x] Create methods for attaching/detaching from customers
- [x] Add payment method update functionality
- [x] Implement metadata handling
- [x] Add comprehensive documentation with examples

**Deliverable:** Type-safe, well-documented PaymentMethod implementation with specialized handling for each method type.

### Task 3.2: Payment Intent Resource

**Tests:**
- [x] Test payment intent creation with different parameters
- [x] Test payment intent confirmation and capture
- [x] Test payment intent status transitions
- [x] Test error handling for failed payments
- [ ] Test integration with webhook events
- [x] Test handling of payment_method_options
- [x] Test metadata handling

**Implementation:**
- [x] Create PaymentIntent resource module
- [x] Implement create, retrieve, update, and cancel operations
- [x] Add methods for confirm, capture, and other actions
- [ ] Integrate with webhook system for asynchronous events
- [x] Add comprehensive error handling for payment failures
- [x] Create detailed documentation with examples for common payment flows

**Deliverable:** Fully functional, type-safe PaymentIntent implementation with webhook integration and documentation.

### Task 2.4: Charge Resource

**Tests:**
- [ ] Test direct charge creation
- [ ] Test charge retrieval and listing
- [ ] Test charge capture and refund processes
- [ ] Test disputes and fraud detection integrations

**Implementation:**
- [ ] Create Charge resource class
- [ ] Implement charge creation and management
- [ ] Add methods for capture, refund, and other operations
- [ ] Implement dispute handling functionality

**Deliverable:** Complete Charge resource for direct payment processing.

## Phase 3: Subscription Management

This phase implements subscription-related resources and functionality.

### Task 3.1: Product and Price Resources

**Tests:**
- [x] Test product creation and management
- [x] Test product retrieval, update, deletion and listing
- [x] Test price creation for one-time payments
- [x] Test price creation for recurring payments
- [x] Test price retrieval, update and listing
- [x] Test price search functionality

**Implementation:**
- [x] Create Product resource module
- [x] Implement create, retrieve, update, delete operations for products
- [x] Implement list and search operations for products
- [x] Create Price resource module
- [x] Implement create, retrieve, update operations for prices
- [x] Implement list and search operations for prices
- [x] Create detailed documentation for products and prices

**Deliverable:** Fully functional Product and Price resources with documentation and tests.

### Task 3.2: Subscription Resource

**Tests:**
- [x] Test subscription creation with various parameters
- [x] Test subscription lifecycle (create, update, cancel)
- [x] Test subscription items management
- [x] Test subscription status tracking and metadata

**Implementation:**
- [x] Create Subscription resource module
- [x] Implement subscription creation and management
- [x] Add methods for handling subscription items
- [x] Implement subscription updating and cancellation
- [x] Create detailed documentation with subscription management best practices

**Deliverable:** Complete subscription management implementation with documentation and tests.

### Task 3.3: Invoice and Invoice Item Resources

**Tests:**
- [x] Test invoice creation and retrieval
- [x] Test invoice finalization and payment
- [x] Test invoice item management
- [x] Test invoice PDF generation and sending

**Implementation:**
- [x] Create Invoice resource class
- [x] Create InvoiceItem resource class
- [x] Implement invoice lifecycle methods
- [x] Add PDF generation and email functionalities

**API Requirements and Implementation Notes:**
- When creating invoices with `collection_method: "send_invoice"`, the `days_until_due` parameter is required
- Invoice items must use one-time prices (not recurring prices)
- Invoice status must be "open" before void, pay, or mark_uncollectible operations can be performed
- PDF URL retrieval should handle nil values defensively as they may not be available for draft invoices
- The `statement_descriptor` parameter is no longer supported when sending invoice emails
- Use conditional logic in tests that depend on invoice status to gracefully handle different API responses

**Deliverable:** Complete invoice management system with robust error handling for Stripe API requirements.

### Task 3.4: Coupon and Promotion Resources

**Tests:**
- [x] Test coupon creation with different discount types
- [x] Test promotion code creation and application
- [ ] Test coupon validation and redemption
- [ ] Test discount calculation on invoices

**Implementation:**
- [ ] Create Coupon resource class
- [ ] Create PromotionCode resource class
- [ ] Implement discount application logic
- [ ] Add validation and redemption tracking

**Deliverable:** Discount management system for subscriptions.

## Phase 4: Error Handling and Edge Cases

This phase refines the library's robustness and handles edge cases.

### Task 4.1: Advanced Error Handling

**Tests:**
- [ ] Test network failure scenarios
- [ ] Test rate limiting and retry logic
- [ ] Test webhook signature verification
- [ ] Test invalid parameter handling and validation

**Implementation:**
- [ ] Implement comprehensive error class hierarchy
- [ ] Add automatic retry logic with exponential backoff
- [ ] Implement webhook signature verification
- [ ] Enhance parameter validation

**Deliverable:** Robust error handling system.

### Task 4.2: Idempotency and Concurrency

**Tests:**
- [ ] Test idempotent request handling
- [ ] Test concurrent requests and race conditions
- [ ] Test request timeouts and cancellation

**Implementation:**
- [ ] Enhance idempotency key management
- [ ] Implement request cancellation
- [ ] Add concurrency safeguards

**Deliverable:** Thread-safe client with proper idempotency handling.

### Task 4.3: Logging and Debugging

**Tests:**
- [ ] Test log level configuration
- [ ] Test request and response logging
- [ ] Test sensitive data redaction

**Implementation:**
- [ ] Implement configurable logging system
- [ ] Add request/response logging with redaction
- [ ] Create debugging utilities

**Deliverable:** Comprehensive logging and debugging system.

## Phase 5: Documentation and Examples

This phase focuses on making the library easy to use and understand.

### Task 5.1: API Documentation

**Tests:**
- [ ] Test documentation completeness
- [ ] Test documentation accuracy

**Implementation:**
- [ ] Write comprehensive API documentation
- [ ] Generate Crystal docs
- [ ] Add parameter and return value documentation

**Deliverable:** Complete API documentation.

### Task 5.2: Usage Examples

**Tests:**
- [ ] Test example code functionality

**Implementation:**
- [ ] Create example code for common scenarios
- [ ] Add detailed explanations for examples
- [ ] Create comprehensive README documentation

**Deliverable:** Collection of usage examples.

### Task 5.3: Integration Examples

**Tests:**
- [ ] Test integration examples with frameworks

**Implementation:**
- [ ] Create integration examples for common Crystal frameworks
- [ ] Document integration patterns and best practices

**Deliverable:** Framework integration examples.

## Phase 6: Continuous Integration and Quality Assurance

This phase establishes CI/CD and quality assurance processes.

### Task 6.1: CI/CD Setup

**Implementation:**
- [x] Set up GitHub Actions workflow
- [x] Configure automated testing
- [x] Set up code formatting checks
- [x] Implement static analysis

**Deliverable:** Working CI/CD pipeline.

### Task 6.2: Test Coverage

**Implementation:**
- [ ] Set up test coverage reporting
- [ ] Ensure >90% code coverage
- [ ] Add tests for edge cases and regressions

**Deliverable:** Comprehensive test suite with high coverage.

### Task 6.3: Release Process

**Implementation:**
- [ ] Establish versioning strategy
- [ ] Create release automation
- [ ] Set up documentation deployment

**Deliverable:** Automated release process.

## Priority Implementation Path

For the minimal implementation to handle basic payments and subscriptions, follow this order:

1. Phase 1: Core Infrastructure (all tasks)
2. Phase 2: Task 2.1 (Customer) and Task 2.3 (PaymentIntent)
3. Phase 3: Tasks 3.1 (Product/Price) and 3.2 (Subscription)
4. Phase 4: Task 4.1 (Advanced Error Handling)

This will provide the minimum viable functionality for handling payments and subscriptions while ensuring robust error handling.
