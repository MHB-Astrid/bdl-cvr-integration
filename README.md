# BDL CVR Integration

Automatisk opslag i Erhvervsstyrelsens CVR-register direkte fra kundekortet i Business Central. Indtast et CVR-nummer, og integrationen henter firmanavn, adresse, branche, virksomhedsform, status, historiske data, deltagere og beskæftigelsestal — og udfylder kundens stamdata automatisk.

## Forudsætninger

- **Business Central** version 25.0+ (runtime 14.0, Cloud target)
- **CVR API-adgang** fra Erhvervsstyrelsen — ansøg på [virk.dk/cvr-permanent](http://distribution.virk.dk)
- Extension-typen er **PTE** (Per-Tenant Extension) da `IsolatedStorage` bruges til credentials

## Installation og opsætning

1. Publicer extensionen til din BC sandbox eller production (`Ctrl+F5` fra VS Code)
2. Åbn et kundekort i BC
3. Klik **Opsæt CVR Credentials** i procesmenuen
4. Indtast brugernavn og adgangskode fra Erhvervsstyrelsen
5. Credentials gemmes krypteret i `IsolatedStorage` (DataScope::Company)

## Brug

### Hent CVR Data

1. Åbn et kundekort og udfyld feltet **CVR-nr.** (8 cifre)
2. Klik **Hent CVR Data** i procesmenuen
3. Integrationen:
   - Kalder CVR API med det indtastede nummer
   - Opretter eller opdaterer en CVR-virksomhedsrecord med alle hentede data
   - Gemmer al historik i undertabeller (adresser, navne, branche, deltagere, beskæftigelse, status)
   - Kopierer **Navn**, **Adresse**, **Postnr.** og **By** til kundens stamdata via `Validate()`
   - Opdaterer **CVR Status** og **CVR Sidst Synkroniseret** på kunden

### Vis CVR-virksomhed

Klik **Vis CVR-virksomhed** på kundekortet for at åbne et read-only kort med alle CVR-data: adresse, kommune, branche, virksomhedsform, stiftelsesdato og synkroniseringstidspunkt.

### Historik og undertabeller

Fra CVR-virksomhedskortet kan du åbne følgende historiklister:

| Action | Data | CVR API kilde |
|--------|------|---------------|
| **Vis adressehistorik** | Alle historiske adresser med gyldighedsperioder | `beliggenhedsadresse[]` |
| **Vis navnehistorik** | Historiske navne og binavne med perioder | `navne[]` + `binavne[]` |
| **Vis branchehistorik** | Historiske branchekoder og beskrivelser | `hovedbranche[]` |
| **Vis deltagere** | Ejere, direktører og andre tilknyttede personer/virksomheder | `deltagerRelation[]` |
| **Vis beskæftigelse** | Årlige medarbejdertal, årsværk og intervalkoder | `aarsbeskaeftigelse[]` |
| **Vis statushistorik** | Statusændringer og livsforløbshændelser | `virksomhedsstatus[]` + `livsforloeb[]` |

Alle historikposter dedupliceres ved re-sync (eksisterende poster oprettes ikke igen).

### Automatisk hentning

Hvis en kunde oprettes med et CVR-nr. udfyldt, forsøger integrationen automatisk at hente CVR-data via en event subscriber på `OnAfterInsertEvent`.

## Objektoversigt

| Fil | Type | ID | Beskrivelse |
|-----|------|----|-------------|
| `BDLCustomerCVR.TableExt.al` | TableExt | 50000 | Tilføjer CVR-nr., CVR Status og CVR Last Synced til Customer |
| `BDLCVRIntegration.PermissionSet.al` | PermissionSet | 50001 | Samlet rettighedssæt for alle CVR-objekter |
| `BDLCVRCompany.Table.al` | Table | 50011 | CVR-virksomhed med navn, adresse, branche, virksomhedsform, status |
| `BDLCVRAddressHistory.Table.al` | Table | 50012 | Historiske adresser med gyldighedsperiode |
| `BDLCVRNameHistory.Table.al` | Table | 50013 | Historiske navne og binavne med perioder |
| `BDLCVRIndustryHistory.Table.al` | Table | 50014 | Historiske branchekoder med perioder |
| `BDLCVRParticipant.Table.al` | Table | 50015 | Ejere, direktører og deltagere med adresse |
| `BDLCVREmployment.Table.al` | Table | 50016 | Årlige beskæftigelsestal med intervalkoder |
| `BDLCVRStatusHistory.Table.al` | Table | 50017 | Statusændringer og livsforløbshændelser |
| `BDLCustomerCardCVR.PageExt.al` | PageExt | 50101 | CVR-gruppe og actions på kundekortet |
| `BDLCVRCompanyCard.Page.al` | Page | 50101 | Read-only CVR-virksomhedskort |
| `BDLCVRSetup.Page.al` | Page | 50102 | Indtastning af CVR API credentials |
| `BDLCVRAddressHistory.Page.al` | Page | 50103 | Historiske adresser |
| `BDLCVRNameHistory.Page.al` | Page | 50104 | Historiske navne og binavne |
| `BDLCVRIndustryHistory.Page.al` | Page | 50105 | Historiske branchekoder |
| `BDLCVRParticipant.Page.al` | Page | 50106 | Deltagere (ejere, direktører) |
| `BDLCVREmployment.Page.al` | Page | 50107 | Årlige beskæftigelsestal |
| `BDLCVRStatusHistory.Page.al` | Page | 50108 | Statusændringer og livsforløb |
| `BDLCVRAPIClient.Codeunit.al` | Codeunit | 50200 | HTTP-klient til CVR API med Basic Auth, retry med exponential backoff |
| `BDLCVRSyncMgt.Codeunit.al` | Codeunit | 50201 | Orkestrator: henter CVR-data, parser JSON, populerer alle undertabeller |
| `BDLCVREventSub.Codeunit.al` | Codeunit | 50202 | Event subscriber der auto-henter CVR-data ved kundeoprettelse |
| `BDLCVRStatus.Enum.al` | Enum | 50250 | CVR-statusværdier: Ukendt, Aktiv, Ophørt, Under konkurs, Opløst |

**ID range:** 50000–50299

## Kendte begrænsninger

- **Kun PTE** — `IsolatedStorage` er ikke tilgængeligt i AppSource-apps
- **Isolated Storage scope** — Credentials gemmes med `DataScope::Company`, så de skal konfigureres pr. virksomhed
- **CVR API rate limiting** — API-klienten har retry med exponential backoff, men API'et kan throttle ved mange samtidige kald
- **Ingen batch-synkronisering** — Henter kun data for én kunde ad gangen
- **Feltstørrelser** — CVR-navne (op til 250 tegn) kan blive afkortet ved kopiering til Customer.Name (100 tegn)
