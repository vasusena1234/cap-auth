# CAP Application with Audit and Authentication Features

## Overview
This CAP (Cloud Application Programming) application, named **cap-auth**, is designed to demonstrate authentication and authorization features using SAP BTP's security mechanisms. The application provides controlled access to an entity **Books** based on user roles.

## Folder Structure
```
.
|-- README.md
|-- app
|   `-- router
|       |-- default-env.json
|       |-- package-lock.json
|       |-- package.json
|       `-- xs-app.json
|-- db
|   |-- data
|   |   `-- my.bookshop-Books.csv
|   |-- schema.cds
|   |-- src
|   `-- undeploy.json
|-- eslint.config.mjs
|-- mta.yaml
|-- package-lock.json
|-- package.json
|-- srv
|   `-- cat-service.cds
`-- xs-security.json
```

## Database Model (`db/schema.cds`)
This defines the **Books** entity, which is the main data model for the application:
```cds
namespace my.bookshop;

entity Books {
  key ID : Integer;
  title  : String;
  stock  : Integer;
}
```

## Service Layer (`srv/cat-service.cds`)
This file defines the **CatalogService** and applies role-based authorization to different entities:
```cds
using my.bookshop as my from '../db/schema';

service CatalogService {
    @(requires: 'authenticated-user')
    entity Books      as projection on my.Books;

    @(requires: 'admin')
    entity Books1     as projection on my.Books;

    entity Booksample as projection on my.Books;
}
```
### Explanation:
- **`Books` entity**: Accessible only to authenticated users.
- **`Books1` entity**: Accessible only to users with the `admin` role.
- **`Booksample` entity**: Open to all users without any authentication requirement.

## Security Configuration (`xs-security.json`)
This file defines the authentication and authorization rules for the application.
```json
{
  "xsappname": "cap-auth",
  "tenant-mode": "dedicated",
  "scopes": [
    {
      "name": "$XSAPPNAME.admin",
      "description": "admin"
    }
  ],
  "attributes": [],
  "role-templates": [
    {
      "name": "admin",
      "description": "generated",
      "scope-references": [
        "$XSAPPNAME.admin"
      ],
      "attribute-references": []
    }
  ],
  "oauth2-configuration": {
    "credential-types": [
      "binding-secret",
      "x509"
    ],
    "redirect-uris": [
      "https://*.applicationstudio.cloud.sap/**",
      "https://*.cfapps.us10-001.hana.ondemand.com/**",
      "https://*.cfapps.us10-001.hana.ondemand.com/login/callback"
    ]
  }
}
```
### Explanation:
- **`xsappname`**: Defines the name of the application.
- **`tenant-mode`**: Specifies that the app is single-tenant (`dedicated`).
- **Scopes (`scopes`)**:
  - Defines an `admin` scope, which is required for accessing the `Books1` entity.
- **Role Templates (`role-templates`)**:
  - Maps the `admin` role to the `admin` scope.
- **OAuth2 Configuration (`oauth2-configuration`)**:
  - Defines allowed credential types for authentication (`binding-secret`, `x509`).
  - Specifies valid redirect URIs for authentication callbacks.

## Application Deployment
### Prerequisites
- SAP Business Application Studio or VS Code
- Node.js installed
- CAP CLI installed (`npm install -g @sap/cds-dk`)
- SAP BTP account

### Steps to Deploy
1. **Install dependencies**:
   ```sh
   npm install
   ```
2. **Run the application locally**:
   ```sh
   cds watch
   ```
   - This starts the CAP server and makes the service available at `http://localhost:4004`

3. **Deploy to SAP BTP**:
   ```sh
   cds build --production
   ```
   ```sh
   cf push
   ```
   - Ensure that the application is bound to an instance of **SAP Authorization & Trust Management (XSUAA)**
   - Assign roles via **SAP BTP Cockpit**

## Testing Authorization
### Testing Without Authentication
- Open `http://localhost:4004/odata/v4/CatalogService/Booksample`
- This should return data from the `Booksample` entity.

### Testing with an Authenticated User
- To access `Books`, a user must be authenticated.
- To test, log in using an identity provider (IDP) configured in SAP BTP.

### Testing with Admin Role
- Assign the **admin role** to a user in **SAP BTP Cockpit**.
- Try accessing `Books1` at `http://localhost:4004/odata/v4/CatalogService/Books1`.
- Only users with the **admin** role should be able to retrieve data.

## Conclusion
This CAP application showcases role-based authentication and authorization using SAP BTP. It demonstrates how to secure services using **CAP annotations** and enforce user roles through **SAP XSUAA**.

