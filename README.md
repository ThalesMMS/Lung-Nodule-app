# Lung Nodule

SwiftUI iOS app for lung nodule guideline calculators and clinical reference screens. It focuses on Fleischner 2017 and ACR Lung-RADS v2022 workflows with quick inputs and visual recommendations.

## Features
- Fleischner 2017 calculator for solid, pure GGO, and part-solid nodules (single or multiple; low/high risk).
- Lung-RADS v2022 calculator with baseline/follow-up logic, morphology, size, and suspicious feature inputs.
- Common-issues reference screens for both guideline sets.
- S-Modifier considerations checklist (informational).
- Brock full model form (UI scaffold; calculation not implemented yet).
- Dark-mode UI and segmented calculator switcher.

## Project Layout
- `Lung Nodule/Lung Nodule/Models`: guideline models and calculator logic.
- `Lung Nodule/Lung Nodule/ViewModels`: state and calculation triggers.
- `Lung Nodule/Lung Nodule/Views`: SwiftUI screens and reference detail views.

## Requirements
- macOS with Xcode installed.
- iOS simulator or device compatible with the deployment target configured in Xcode.
- No third-party dependencies.

## Run Locally
1. Open `Lung Nodule/Lung Nodule.xcodeproj` in Xcode.
2. Select the `Lung Nodule` scheme and a simulator/device.
3. Build & Run.

## Tests
Calculator coverage lives in `Lung Nodule/Lung NoduleTests`.

Run in Xcode (Product -> Test) or via command line:
```bash
xcodebuild -project "Lung Nodule/Lung Nodule.xcodeproj" -scheme "Lung Nodule" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Medical Disclaimer
This app is for educational/reference use only and does not replace clinical judgment or institutional guidelines.

## License
MIT. See `LICENSE`.
