# Existing Swift Foundation References

This note records the existing workspace projects inspected before settling OpenOneNote's native foundation and Swift development tooling.

## Health/Menu-Bar App Match

The strongest match for the remembered custom health app is **macOS-Maintenance's `MaintenanceApp/`**, observed at revision `4021273b08599e9537d8cf1efa0ee4fe3255117b`:

- `MaintenanceApp/MaintenanceApp.swift` is a SwiftUI `MenuBarExtra` application.
- `MaintenanceApp/Views/Detail/PersonalHealthDetailContent.swift` contains personal-health/check-in views.
- `MaintenanceApp/Views/CheckIn/CheckInWizardView.swift` provides the check-in flow; `Sources/CheckInKit/` contains its model/service/database sources.
- `MaintenanceApp/project.yml` describes a separate Xcode application using Swift package modules.

Current repository instructions explicitly park `CheckInKit` outside the active SwiftPM graph, while the GUI still references it. This is useful source/reference material, not proof that the current GUI checkout builds unchanged. No personal health records were read.

## Conventions Carried Into OpenOneNote

- **Swift package modules:** notebook domain, storage, editor, and development capabilities have explicit ownership/dependencies.
- **Typed native process boundary:** the DevelopmentKit process runner follows Maintenance's `ProcessClient`/`ProcessResult` pattern: literal argument arrays, structured exit results, typed failures, and deadlines. The maintenance implementation was inspected; its unrelated system services and dormant dependency graph were not imported.
- **Native lifecycle and UI:** SwiftUI composition with AppKit integration, separate app assembly/signing, and explicit development/runtime verification. OpenOneNote uses a document-window lifecycle; Maintenance's menu-bar and automatic login-item behavior remain specific to that application.
- **Swift-only project automation:** `openonenote-dev` owns CI, verification, build/sign/package, and research capture. Platform tools are invoked through `Foundation.Process`; no authored shell workflows remain.

## Workspace Inventory Coverage

A file-name inventory under the explicitly requested `~/Projects` scope found 4,151 visible `.swift` paths, excluding generated/dependency directories and respecting ignore rules. Swift-bearing repositories include macOS-Maintenance, VibeMeter, SnapTra-GoldenDict, cmux, Nimbalyst, and the Schedula iOS app, plus smaller mobile wrappers/tools. File counts are not build or ownership verification.

Maintenance was inspected in detail for relevant conventions. The other entries are candidate references, not a claim that their architecture or builds were reviewed. `iCloud-Maintenance` currently contains Python sources despite a Swift catalog tag. Sundy was not located as a native Mac foundation; the user identified it as likely Android-only.

JetBrains preparation found no baseline index for Maintenance or the new OpenOneNote repository. Discovery used the workspace catalog, a scoped source-file inventory, and direct reads. No Microsoft research artifacts were uploaded to a semantic index.
