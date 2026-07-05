# Guideline Edge-Case Audit — Summary (Fleischner 2017, Lung-RADS v2022, Brock)

This document summarizes what branches/thresholds were audited, what interpretations were locked in by tests, and any intentional limitations or open items.

> Scope note: This repo is a deterministic, rule-based reference calculator. Passing tests demonstrates consistency with the rules encoded here and the audit cases included in the test suite; it does **not** constitute clinical validation.

---

## Where the logic lives

- Fleischner 2017: `Lung Nodule/Lung Nodule/Models/FleischnerModel.swift`
- Lung-RADS v2022: `Lung Nodule/Lung Nodule/Models/LungRADSModel.swift`
- Brock model: `Lung Nodule/Lung Nodule/Models/BrockModel.swift`

## Where the audit is enforced (tests)

- Primary regression / edge-case coverage:
  - `Lung Nodule/Lung NoduleTests/Lung_NoduleTests.swift`
  - `Lung Nodule/Lung NoduleTests/BrockCalculatorTests.swift`
  - `Lung Nodule/Lung NoduleTests/AuditTestHelpersTests.swift`
  - `Lung Nodule/Lung NoduleTests/LungRADSEdgeCaseTests.swift`
  - `Lung Nodule/Lung NoduleTests/LungRADSSModifierStateBindingTests.swift`

The audit matrix format and severity guardrails were introduced to prevent **under-calls** relative to verified guideline interpretations.

---

## Fleischner Society 2017 — audited interpretations

Reference decision-table assumptions and boundary conventions are captured in:
- `Notes/LogicTables.md` (Fleischner section)

Audited risk areas (locked by tests):
- Solid nodules: solitary vs multiple; low vs high risk
- Boundary sizing behavior at thresholds:
  - solitary solid: `<6`, `6–8 (inclusive)`, `>8`
  - multiple solid: `<6` vs `≥6`
- Subsolid nodules:
  - pure GGN: `<6` vs `≥6`
  - part-solid: total `<6` vs `≥6` and solid component `<6` vs `≥6`

Severity guardrail principle:
- When guideline language permits “optional CT” vs “no routine follow-up”, tests are written to prevent outputs that are *less* intensive than the chosen interpretation.

---

## Lung-RADS v2022 — audited risk areas

Reference categorization notes and boundary conventions are captured in:
- `Notes/LogicTables.md` (Lung-RADS section)

The following risk areas were explicitly audited and covered by regression tests:

1. Part-solid growth priority
   - Growth of the **solid component** is prioritized appropriately vs total size changes.
   - Boundary values around the 4/6/8mm solid-component thresholds are exercised.

2. Juxtapleural 8–10mm boundary handling
   - Classification at 8, 9, and 10mm was verified to avoid off-by-one binning.

3. Airway anatomy classification
   - Airway nodules are classified across anatomic levels (trachea/mainstem/lobar/segmental/subsegmental) per the app’s model and mapped to Lung-RADS airway guidance.

4. S-modifier state binding
   - Tests simulate state transitions to ensure the S-modifier is applied to the current computed base category and does not persist incorrectly.

5. Stable part-solid reclassification
   - Stability-dependent downgrades/maintenance behaviors are covered with boundary-duration cases to prevent under-calling.

Additionally:
- A “full audit matrix” sweep is executed in tests to assert computed severity is never below expected for verified branches.

---

## Brock model — audited behavior

Implementation details (coefficients, encodings, transforms) were verified and documented in the plan notes for subtask 3.1.

Regression coverage:
- Deterministic unit tests assert probability output for fixed inputs within tolerance.
- Edge-case validation around allowed size range and required fields is covered.

Known limitation / follow-up recommendation:
- A one-time manual cross-check vs a trusted external Brock/PanCan calculator is recommended and should be recorded by adding new test vectors derived from that reference.

---

## Intentional limitations / caveats

The audit process focuses on threshold correctness and preventing under-calls in audited branches. The following items remain “out of scope” for strict guideline equivalence unless explicitly added:

- Measurement conventions: exact rounding strategy, multi-plane measurement nuance, and reader variability are not modeled beyond what is encoded in the calculator.
- Full imaging context: comorbidities, broader radiology report context, and institutional protocols may override guideline defaults.
- Brock external validation: reference-calculator cross-check is not embedded in CI here.

If any of these limitations become problematic for your deployment context, treat them as candidates for additional requirements + test vectors.
