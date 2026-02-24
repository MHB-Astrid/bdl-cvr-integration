# BC Development Lessons Learned - 2026-02-22

## Overview
Successfully deployed first BC extension after learning through compilation errors and debugging.

## Compilation Errors Fixed

### 1. Permission Sets Required (PTE0004)
**Error:** `Table 50010 'BDL Customer Loyalty' is missing a matching permission set`
**Solution:** Created `BDLCustomerLoyalty.PermissionSet.al` with RIMD permissions
**Code:**
```al
permissionset 50000 "BDL Customer Loyalty"
{
    Assignable = true;
    Permissions =
        tabledata "BDL Customer Loyalty" = RIMD,
        table "BDL Customer Loyalty" = X,
        page "BDL Customer Loyalty API" = X;
}
```
**Learning:** Modern BC (v14+) requires explicit permission sets for all new objects for security compliance.

### 2. Field ID Conflicts in Table Extensions (AL0206)
**Error:** `A field with ID 1 is already defined in Table 'Customer'`
**Solution:** Changed field IDs from 1, 10, 20 to 50000, 50001, 50002
**Learning:** Table extensions MUST use field IDs in 50000+ range to avoid conflicts with base BC tables.

### 3. Table Naming Inconsistency
**Error:** Two table files with different IDs and names:
- `CustomerLoyalty.al` - ID 50000 - "BDL CustomerLoyalty" (no space)
- `BDLCustomerLoyalty.Table.al` - ID 50010 - "BDL Customer Loyalty" (with space)

**Solution:** Deleted duplicate file, kept only ID 50010 with consistent naming
**Learning:** Be consistent with object naming (spaces, capitalization) across all files to avoid cross-reference errors.

### 4. Codeunit Property Restrictions (AL0124)
**Error:** `The property 'Caption' cannot be used in this context`
**Solution:** Removed Caption property from codeunit declaration
**Learning:** Different AL object types support different properties:
- Tables/Pages: Caption allowed
- Codeunits: Caption NOT allowed

### 5. File Naming Conventions (AA0215 warnings)
**Warning:** File names didn't match object names
**Best Practice:** Use pattern `ObjectName.ObjectType.al` (e.g., `BDLCustomerLoyalty.Table.al`)

## Multi-Agent Workflow Success

### bc-al-generator (Table creation)
Generated: `BDLCustomerLoyalty.Table.al`, `BDLLoyaltyTier.Enum.al`

### bc-api-agent (API creation)
Generated: `BDLCustomerLoyaltyAPI.Page.al` with OData compliance

### Manual fixes
Created: Permission set, List page for UI access

## Key Takeaways

1. **Permission sets are mandatory** - Plan for them from the start
2. **Field IDs matter** - Always use 50000+ range for custom fields in extensions
3. **Naming consistency is critical** - One mistake cascades to multiple errors
4. **Object properties vary** - Not all properties work on all object types
5. **Iterative debugging works** - Each error teaches something valuable

## Timeline
- MCP servers built: 2-3 hours
- BC setup + first deployment attempt: 2 hours
- Debugging compilation errors: 1-2 hours
- **First successful deployment: ~6 hours total**
- First data created in BC: Success!

## Success Metrics
- Compilation attempts: ~8 iterations
- Errors encountered: 5 major types
- Final result: Working BC extension with live data
- Learning value: Invaluable for future BC development

## Next Steps
- Test Custom API endpoint with OAuth
- Add more sophisticated business logic
- Deploy to production environment
- Build additional features using MCP servers

## Multi-Computer Workflow (2026-02-23)

### Setup på Computer 2
Successfully replicated development environment on second computer:

**Steps:**
1. Clone both repos from GitHub:
   - `git clone https://github.com/MHB-Astrid/bc-al-mcp-server.git "BC Udvikling"`
   - `git clone https://github.com/MHB-Astrid/BC-API-Agent.git "BC API Agent"`
2. Install dependencies: `npm install` (both projects)
3. Build MCP servers: `npm run build` (both projects)
4. Install GSD: `npx get-shit-done-cc@latest`
5. Update .mcp.json paths for local computer (mhbac → mhb)

**Key Learnings:**
- .mcp.json contains machine-specific paths and should be in .gitignore
- MCP servere virker identisk på begge computere efter clone + build
- Total setup time: ~10 minutes
- Both MCP servers verified working (bc-al-generator 4.72ms, bc-api-agent 7.65ms)

### OAuth API Testing
Successfully tested Custom API endpoint deployed yesterday:

**Authentication:**
- Used Azure CLI for OAuth authentication
- Command: `az account get-access-token --resource https://api.businesscentral.dynamics.com`
- Account: MadsBach@PowerAgentAstrid.onmicrosoft.com

**API Verification:**
- Endpoint: `/api/bdl/integration/v1.0/customerLoyalties`
- Method: GET
- Response: ✓ Success
- Records retrieved: 2 (Customer 10000 Bronze, Customer 40000 Gold)

**Response Quality:**
- ✓ OData metadata present
- ✓ ETags included
- ✓ lastModifiedDateTime accurate
- ✓ All fields correctly serialized
- ✓ Tier enum values correct (Bronze, Gold)

**UI vs API Sync:**
- ✓ Data in BC UI matches API response exactly
- ✓ Both records created 2026-02-22
- ✓ Points and tier levels consistent

### End-to-End Verification Complete
Full stack validated across two computers:
- Code generation (MCP servers) ✓
- BC extension deployment ✓
- UI data entry ✓
- Custom API endpoint ✓
- OAuth authentication ✓
- OData compliance ✓

---

## CVR API Adresse-parsing (2026-02-24)

### Bug: bogstavFra ignoreret i BuildAddress
**Problem:** `BuildAddress` i `BDLCVRSyncMgt.Codeunit.al` læste kun `husnummerFra` og ignorerede `bogstavFra`. Adressen "Rugårdsvej 55B" blev vist som "Rugårdsvej 55".

**Root cause:** CVR API returnerer husnummer og bogstav i separate felter:
```json
{ "husnummerFra": 55, "bogstavFra": "B" }
```

**Fix:** Tilføj `HouseLetter := GetJsonText(AddressJson, 'bogstavFra')` og sammensæt uden mellemrum: `Result += HouseLetter`.

**Læring:**
- CVR API adressefelter: `vejnavn`, `husnummerFra`, `bogstavFra`, `etage`, `sidedoer`, `postnummer`, `postdistrikt`
- `bogstavFra` er en string ("B"), `husnummerFra` er et integer (55)
- `GetJsonText` + `AsText()` håndterer begge typer korrekt

### Deploy: Feltlængde-ændring kræver ForceSync
**Problem:** Ændring af Code[8] til Code[20] fejlede med `SchemaUpdateMode=Synchronize` — BC tillader ikke længdeændringer.

**Fix:** Midlertidigt skift til `"schemaUpdateMode": "ForceSync"` i launch.json, deploy, skift tilbage til `"Synchronize"`.

**VIGTIGT:** ForceSync sletter eksisterende data i tabellerne. Brug kun ved schema-breaking changes.

### Version bump påkrævet ved deploy
**Problem:** Ctrl+F5 fejler stille hvis app.json version er uændret.

**Fix:** Bump version i app.json (f.eks. 1.0.0.0 → 1.0.0.1) ved hver deploy.

---

**Created:** 2026-02-22
**Updated:** 2026-02-24
**Status:** Complete Success
**Environment:** BC Sandbox (abdcde5f-6b24-4356-8245-cbe46217eff6)
