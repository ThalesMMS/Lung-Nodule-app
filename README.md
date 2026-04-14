# Lung Nodule

SwiftUI iOS app for lung nodule guideline calculators and reference screens.

It currently focuses on **Fleischner Society 2017** incidental pulmonary nodule follow-up logic and **ACR Lung-RADS v2022** screening workflows. The project is positioned for **educational, reference, and research/prototyping use** rather than autonomous clinical use.

## 30-second quickstart
```bash
git clone https://github.com/ThalesMMS/Lung-Nodule-app.git
cd Lung-Nodule-app
open "Lung Nodule/Lung Nodule.xcodeproj"
```

Then in Xcode:
1. Select the `Lung Nodule` scheme.
2. Choose a compatible simulator or connected device.
3. Build & Run.

If you want a fast sanity check before opening the UI:
```bash
xcodebuild -list -project "Lung Nodule/Lung Nodule.xcodeproj"
```

## Features
- Fleischner 2017 calculator for solid, pure GGO, and part-solid nodules (single or multiple; low/high risk).
- Lung-RADS v2022 calculator with baseline/follow-up logic, morphology, size, and suspicious feature inputs.
- Common-issues reference screens for both guideline sets.
- S-Modifier considerations checklist (informational).
- Brock full model form (**UI scaffold only; calculation not implemented yet**).
- Dark-mode UI and segmented calculator switcher.

## Status and intended use
- This repository contains a **rule-based calculator app**, not a trained AI/ML model.
- Inputs are entered manually in the UI; the app does **not** ingest DICOM studies, segment nodules, or detect lesions automatically.
- Recommendations are generated from encoded guideline logic in the source tree and should be treated as a fast reference, not as a substitute for full radiology review.
- If local policy, newer literature, or source guideline documents differ from the app output, the **source documents and clinical context take precedence**.

## Guideline and provenance notes
- The implemented decision logic lives primarily in:
  - `Lung Nodule/Lung Nodule/Models/FleischnerModel.swift`
  - `Lung Nodule/Lung Nodule/Models/LungRADSModel.swift`
- Logic checks and threshold-focused regression coverage live in:
  - `Lung Nodule/Lung NoduleTests/Lung_NoduleTests.swift`
- No training dataset, fitted model weights, or benchmark dataset are bundled in this repository.
- This means reproducibility here is about **reproducing deterministic rule outputs from the same app version**, not reproducing a machine-learning training pipeline.

## Project layout
- `Lung Nodule/Lung Nodule/Models`: guideline models and calculator logic.
- `Lung Nodule/Lung Nodule/ViewModels`: state and calculation triggers.
- `Lung Nodule/Lung Nodule/Views`: SwiftUI screens and reference detail views.
- `Lung Nodule/Lung NoduleTests`: unit and edge-case tests for calculator behavior.

## Requirements
- macOS with Xcode installed.
- iOS simulator or device compatible with the deployment target configured in Xcode.
- No third-party dependencies.

## Run locally
Use the quickstart above for the fastest path. The same project can also be validated from the command line with the reproducibility steps below.

## Reproducibility checklist
To verify the project structure and re-run the calculator tests from a clean clone, substitute a compatible simulator name and iOS version if your Xcode installation does not include the example destination shown below:

```bash
# Confirm that Xcode sees the project and scheme
xcodebuild -list -project "Lung Nodule/Lung Nodule.xcodeproj"

# Run tests on a compatible iOS Simulator runtime
# Replace the simulator name/OS with one available in your local Xcode setup.
xcodebuild \
  -project "Lung Nodule/Lung Nodule.xcodeproj" \
  -scheme "Lung Nodule" \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  test
```

If `xcodebuild` reports that the required iOS platform/runtime is missing, install it from **Xcode → Settings → Components** and rerun the command. If your machine does not offer `iPhone 16`, replace it with any compatible simulator name and OS version shown by Xcode or `xcrun simctl list devices available`.

## Expected input/output examples
These examples are meant to make the app behavior easier to verify against the current source code and tests.

### Example 1 — Fleischner incidental nodule workflow
**Input**
- Single solid nodule
- Size category: `6 - 8 mm`
- Patient risk: `High Risk`

**Expected output**
- Recommendation includes: `CT at 6-12 months, then CT at 18-24 months.`

**Where this is covered**
- `solid6To8mmHighRisk()` in `Lung_NoduleTests.swift`

### Example 2 — Lung-RADS baseline screening workflow
**Input**
- Screening context (`Baseline CT`)
- Nodule type: `Solid`
- Size category: `8-14.9 mm`

**Expected output**
- Category: `4A`
- Management includes: `3-month LDCT; PET/CT may be used when solid component is ≥ 8mm.`

**Where this is covered**
- `solid8To15mmBaselineReturnsCategory4A()` in `Lung_NoduleTests.swift`

## Limitations and evaluation caveats
- The app has **logic tests**, but this repository does **not** include a prospective clinical validation study or an outcomes dataset.
- Passing tests shows consistency with the encoded rules and edge cases in the repo; it does **not** prove clinical safety, effectiveness, or regulatory fitness.
- The Brock risk form is currently a UI scaffold and should not be interpreted as a functioning risk model.
- Recommendations depend on user-entered values. Incorrect measurements, context selection, or risk labeling will produce misleading outputs.
- Edge cases may still require direct consultation of the original guideline documents, especially when morphology, prior imaging history, comorbidities, or institutional pathways complicate categorization.
- The repository should not be used to make unsupervised screening, biopsy, surveillance, or treatment decisions.

## Medical disclaimer
This app is for **educational/reference and research/prototyping use only**. It does not replace clinical judgment, multidisciplinary review, institutional policy, or the original guideline publications. It has not been presented here as a regulated medical device and should **not** be used as the sole basis for clinical decision-making.

## Citation
If you use this repository in academic or educational work, see [`CITATION.cff`](./CITATION.cff).

## License
MIT. See `LICENSE`.
