# CVR Integration til Business Central

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

### Tabeller

| Fil | ID | Beskrivelse |
|-----|----|-------------|
| `BDLCVRCompany.Table.al` | 50011 | CVR-virksomhed med navn, adresse, branche, virksomhedsform, status m.m. |
| `BDLCVRAddressHistory.Table.al` | 50012 | Historiske adresser med gyldighedsperiode |
| `BDLCVRNameHistory.Table.al` | 50013 | Historiske navne og binavne med perioder |
| `BDLCVRIndustryHistory.Table.al` | 50014 | Historiske branchekoder med perioder |
| `BDLCVRParticipant.Table.al` | 50015 | Ejere, direktører og deltagere med adresse |
| `BDLCVREmployment.Table.al` | 50016 | Årlige beskæftigelsestal med intervalkoder |
| `BDLCVRStatusHistory.Table.al` | 50017 | Statusændringer og livsforløbshændelser |

### Enums og extensions

| Fil | Type | ID | Beskrivelse |
|-----|------|----|-------------|
| `BDLCVRStatus.Enum.al` | Enum | 50401 | CVR-statusværdier: Ukendt, Aktiv, Ophørt, Under konkurs, Opløst |
| `BDLCustomerCVR.TableExt.al` | TableExt | 50000 | Tilføjer CVR-nr., CVR Status og CVR Last Synced til Customer |

### Codeunits

| Fil | ID | Beskrivelse |
|-----|----|-------------|
| `BDLCVRAPIClient.Codeunit.al` | 50200 | HTTP-klient til CVR API med Basic Auth, retry med exponential backoff |
| `BDLCVRSyncMgt.Codeunit.al` | 50201 | Orkestrator: henter CVR-data, parser JSON-response, populerer alle undertabeller |
| `BDLCVREventSub.Codeunit.al` | 50202 | Event subscriber der automatisk henter CVR-data ved kundeoprettelse |

### Pages

| Fil | ID | Type | Beskrivelse |
|-----|----|------|-------------|
| `BDLCustomerCardCVR.PageExt.al` | 50101 | PageExt | CVR-gruppe og actions på kundekortet |
| `BDLCVRCompanyCard.Page.al` | 50101 | Card | Read-only CVR-virksomhedskort med actions til alle historiklister |
| `BDLCVRSetup.Page.al` | 50102 | Dialog | Indtastning af CVR API credentials |
| `BDLCVRAddressHistory.Page.al` | 50103 | List | Historiske adresser |
| `BDLCVRNameHistory.Page.al` | 50104 | List | Historiske navne og binavne |
| `BDLCVRIndustryHistory.Page.al` | 50105 | List | Historiske branchekoder |
| `BDLCVRParticipant.Page.al` | 50106 | List | Deltagere (ejere, direktører) |
| `BDLCVREmployment.Page.al` | 50107 | List | Årlige beskæftigelsestal |
| `BDLCVRStatusHistory.Page.al` | 50108 | List | Statusændringer og livsforløb |

### Permissions

| Fil | ID | Beskrivelse |
|-----|----|-------------|
| `BDLCVRIntegration.PermissionSet.al` | 50001 | Samlet rettighedssæt for alle CVR-objekter |

## Kendte begrænsninger

- **Kun PTE** — `IsolatedStorage` er ikke tilgængeligt i AppSource-apps. Til AppSource skal credentials flyttes til en setup-tabel med krypterede felter.
- **Isolated Storage scope** — Credentials gemmes med `DataScope::Company`, så de skal konfigureres pr. virksomhed i multi-company miljøer.
- **CVR API rate limiting** — API-klienten har retry med exponential backoff (op til 5 forsøg), men Erhvervsstyrelsens API kan throttle ved mange samtidige kald.
- **Ingen batch-synkronisering** — Integrationen henter kun data for én kunde ad gangen via manuelt klik eller ved oprettelse.
- **Feltstørrelser** — CVR-navne (op til 250 tegn) kan blive afkortet ved kopiering til Customer.Name (100 tegn).
- **Deltagere uden roller** — `deltagerRelation[].organisationer[]`-arrayet parses ikke endnu, så roller (bestyrelse, direktion) vises ikke. Kun navn, type og adresse gemmes.
