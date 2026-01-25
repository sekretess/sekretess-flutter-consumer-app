# Core Data Model Setup

The Core Data model file needs to be created in Xcode:

1. In Xcode, right-click on the `Runner` folder
2. Select "New File..."
3. Choose "Data Model" under Core Data
4. Name it `CoreDataModel`
5. Add the following entities with their attributes:

## Entities to Create:

### IdentityKeyPairEntity
- id: Integer 64
- identityKeyPair: String
- createdAt: Integer 64

### IdentityKeyEntity
- id: Integer 64
- deviceId: Integer 32
- name: String
- identityKey: String
- createdAt: Integer 64

### RegistrationIdEntity
- id: Integer 64
- registrationId: Integer 32
- createdAt: Integer 64

### PreKeyRecordEntity
- id: Integer 64
- preKeyId: Integer 32
- preKeyRecord: String
- used: Boolean
- createdAt: Integer 64

### SignedPreKeyRecordEntity
- id: Integer 64
- spkId: Integer 32
- spkRecord: String
- used: Boolean
- createdAt: Integer 64

### KyberPreKeyEntity
- id: Integer 64
- prekeyId: Integer 32
- kpkRecord: String
- used: Boolean
- createdAt: Integer 64

### SessionEntity
- id: Integer 64
- session: String
- addressName: String
- serviceId: String (optional)
- deviceId: Integer 32
- createdAt: Integer 64

### SenderKeyEntity
- id: Integer 64
- deviceId: Integer 32
- addressName: String
- senderKeyRecord: String
- distributionUuid: String
- createdAt: Integer 64

## Code Generation
Set "Codegen" to "Class Definition" for all entities in Xcode.
