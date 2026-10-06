# Current State — Evidence-backed audit

**Audit date:** 2026-10-06  
**Repository:** `tupiniquimtechsolution-blip/RastaQuest`  
**Audited branch:** `main`

## Executive status

- **Phase:** Pre-production / PE-000 normalization
- **Playable build committed:** No
- **Current implementation baseline committed:** No
- **Historical design material:** Yes
- **Current PE execution roadmap:** Yes
- **Complete canonical master documentation:** No

## Duplicate audit

The pre-normalization repository contained 50 blobs. Exact duplicate detection by Git blob SHA found **zero exact duplicate groups**.

Several images are derivative/export variants (original vs. Photoroom/remove-background versions). They are grouped, not deleted, because their production role is not yet documented.

## Critical findings

### Upload shape

The 2026-10-06 upload commit added only:

- `Assembly-CSharp.csproj`
- `PortalAscendant.sln`
- `portals-edge-ondas-PE-completo.md`

No `PortalAscendant/` directory exists in the audited Git tree.

### Incomplete Unity prototype metadata

The generated `Assembly-CSharp.csproj` identifies **Unity 6000.0.45f1** and references `Assets/Scripts/PlayerMovement.CS`. That source file is absent, as are the normal Unity `Assets/`, `Packages/` and `ProjectSettings/` directories.

The committed Unity files therefore do not form a recoverable Unity project by themselves.

### Architecture conflict

The available PE roadmap specifies a portable C++ core, Godot adapter and PS3 adapter/feasibility gate. Unity metadata is classified as legacy unless a newer approved source says otherwise.

### Missing referenced canonical sources

The roadmap references **Documento Mestre v3.0** and **Planejamento 2.0**. Neither is currently present under those identities.

### Naming conflict

Three identities coexist:

- repository: **RastaQuest**
- historical GDD: **Portal's Edge: Last Stand**
- old Unity prototype: **PortalAscendant**

No current source explicitly reconciles them.

### Platform strategy

Historical documents emphasize mobile. The PE roadmap emphasizes PC first, a PS3 feasibility gate, and later QA including Android/iOS. Release priority requires a canonical decision.

## Authority classification

### Current / higher authority available
- `AGENTS.md`
- `docs/roadmap/PE_EXECUTION_WAVES.md`
- approved ADRs

### Legacy / preserved
- original DOCX GDD files
- engine/mobile research DOCX
- concept art and sprite experiments
- Unity-generated solution/project metadata

## PE-000 status

- [x] Preserve legacy material without destructive loss
- [x] Separate current roadmap from legacy material
- [x] Create legacy index
- [x] Record ADR 0001
- [x] Establish repository hygiene and contribution policy
- [x] Add structural CI
- [ ] Recover Documento Mestre v3.0
- [ ] Recover Planejamento 2.0
- [ ] Confirm complete intended source upload
- [ ] Reconcile canonical product name
- [ ] Verify exact target directory tree from the missing master source
- [ ] Establish a real build gate when an implementation skeleton exists

## Gate

Do not start PE-001 as though the repository were complete until missing master sources are recovered or explicitly retired.
