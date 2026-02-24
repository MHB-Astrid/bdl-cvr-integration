# CLAUDE.md

Projektinstruktioner til Claude Code for BDL CVR Integration.

## Projekt Overblik

**BDL CVR Integration** — Business Central extension til opslag og synkronisering af danske virksomhedsdata fra CVR-registeret (Erhvervsstyrelsen).

**Virksomhed:** BDL A/S
**Projekt-ejer:** Mads
**Type:** BC Per Tenant Extension (Cloud)
**Version:** 1.0.0.3

---

## CVR API

**Endpoint:** `http://distribution.virk.dk/cvr-permanent/virksomhed/_search`
**Auth:** Basic Authentication
**Credentials:** Azure Key Vault `kv-bdl-smartconnect-dev` — secrets `CVRApiUsername` / `CVRApiPassword`

**SIKKERHEDSREGEL:** Vis ALDRIG credential-værdier i terminal output eller i svar til brugeren.
Gem altid i variabler og brug dem direkte:
```bash
username=$(az keyvault secret show --name CVRApiUsername --vault-name kv-bdl-smartconnect-dev --query value -o tsv)
password=$(az keyvault secret show --name CVRApiPassword --vault-name kv-bdl-smartconnect-dev --query value -o tsv)
curl -s -u "$username:$password" ...
```
Denne regel gælder for ALLE Key Vault secrets i ALLE kommandoer.

### Adresseformat

CVR API returnerer adresser med separate felter:

| Felt | Type | Eksempel |
|------|------|----------|
| `vejnavn` | string | "Rugårdsvej" |
| `husnummerFra` | integer | 55 |
| `bogstavFra` | string/null | "B" |
| `etage` | string/null | "2" |
| `sidedoer` | string/null | "th" |
| `postnummer` | integer | 5000 |
| `postdistrikt` | string | "Odense C" |
| `landekode` | string | "DK" / "GL" |

**Sammensætning:** `vejnavn + ' ' + husnummerFra + bogstavFra` (ingen mellemrum før bogstav)
- Rugårdsvej 55B = `vejnavn:"Rugårdsvej"`, `husnummerFra:55`, `bogstavFra:"B"`

### CVR-nummer Format

- Altid 8-cifret integer (også grønlandske virksomheder med landekode GL)
- Felt: `Code[20]` for fremtidssikring

### Metadata vs Raw Data

| Path | Indhold |
|------|---------|
| `virksomhedMetadata.nyesteBeliggenhedsadresse` | Aktuel adresse (flad struktur) |
| `virksomhedMetadata.nyesteNavn.navn` | Aktuelt navn |
| `virksomhedMetadata.sammensatStatus` | Aktuel status |
| `beliggenhedsadresse[]` | Fuld adressehistorik |
| `navne[]` | Fuld navnehistorik |
| `deltagerRelation[]` | Deltagere (ejere, revision, etc.) |

### Deltager-navnehistorik

Deltagere kan have mange historiske navne. Eksempel: "EVCO FINANS ApS" → "DANSK REVISION ODENSE" (samme enhed, skiftet navn flere gange).

---

## Projekt Struktur

```
bdl-cvr-integration/
├── src/
│   ├── BDLCVRAPIClient.Codeunit.al      # API kald, auth, retry logic
│   ├── BDLCVRSyncMgt.Codeunit.al        # JSON parsing, data sync
│   ├── BDLCVREventSub.Codeunit.al       # Event subscribers
│   ├── BDLCVRCompany.Table.al           # Hoveddatatabel
│   ├── BDLCVRCompanyCard.Page.al        # CVR Company Card
│   ├── BDLCustomerCVR.TableExt.al       # Extension til Customer
│   ├── BDLCustomerCardCVR.PageExt.al    # Extension til Customer Card
│   ├── BDLCVRSetup.Page.al             # Credentials setup
│   ├── BDLCVRAddressHistory.Table.al    # Adressehistorik
│   ├── BDLCVRNameHistory.Table.al       # Navnehistorik
│   ├── BDLCVRIndustryHistory.Table.al   # Branchehistorik
│   ├── BDLCVRParticipant.Table.al       # Deltagere
│   ├── BDLCVREmployment.Table.al        # Beskæftigelse
│   ├── BDLCVRStatusHistory.Table.al     # Statushistorik
│   ├── BDLCVRStatus.Enum.al            # Status enum
│   ├── BDLCVRIntegration.PermissionSet.al # Permissions
│   └── *Page.al                         # List pages for historik
├── app.json                             # App manifest
├── .vscode/launch.json                  # Deploy config
└── CLAUDE.md                            # Dette dokument
```

---

## BDL Konventioner

- **Prefix:** "BDL" på alle objekter
- **Sprog:** Danske captions, engelsk kode
- **Object IDs:** 50000-50299 (se app.json idRanges)
- **DataClassification:** Påkrævet på alle felter
- **Credentials:** IsolatedStorage (DataScope::Company), ALDRIG hardcoded

---

## Deploy

```
Ctrl+F5 i VS Code (AL extension)
```

- **Version bump PÅKRÆVET** i app.json ved hver deploy
- **schemaUpdateMode:** Normalt `"Synchronize"` — brug `"ForceSync"` KUN ved feltlængde/type-ændringer (sletter data!)
- **Skift altid tilbage** til `"Synchronize"` efter ForceSync

---

## BC Environment

- **Tenant ID:** abdcde5f-6b24-4356-8245-cbe46217eff6
- **Environment:** Sandbox
- **Company:** CRONUS Danmark A/S

---

## Kendte Gotchas

| Problem | Løsning |
|---------|---------|
| `bogstavFra` ignoreret i adresse | Læs separat og sammensæt: `husnummerFra + bogstavFra` |
| Feltlængde-ændring fejler | Brug `ForceSync` i launch.json (sletter data) |
| Deploy uden version bump | Fejler stille — bump app.json version |
| Deltager har mange navne | Navnehistorik — brug seneste (gyldigTil=null) |
| CVR API 429 rate limit | Retry med exponential backoff (allerede implementeret) |

---

**Sidst opdateret:** 2026-02-24
**Vedligeholdt af:** Mads, BDL A/S
