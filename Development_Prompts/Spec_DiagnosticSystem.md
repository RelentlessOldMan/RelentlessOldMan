# Application Diagnostics / Support System — Implementation Specification

Implement a robust, reusable diagnostics, logging, and user-feedback system for this application.

This is an IMPLEMENTATION task — you are building and integrating a working system, not producing a review or a report.

The goal is simple:

> If a user encounters a problem, they should be able to save one diagnostic package, send it to the developer, and provide enough information to investigate what happened without requiring the user to understand logs, debugging, file locations, configuration internals, or technical terminology.

The intended support workflow should be approximately:

1. User encounters a problem.
2. User selects something like **Help → Save Diagnostic Report**.
3. The application asks where to save it.
4. The application creates ONE diagnostic/support package.
5. User sends that package to the developer.
6. Developer can inspect it and reconstruct what the application was doing.

Adapt the implementation to the application's language, framework, architecture, and platform.

Do not blindly implement every idea below if it is irrelevant to the application.

Prefer a clean, centralized, reusable design over diagnostic code scattered throughout the project.

---

# 1. CORE REQUIREMENTS

The diagnostic system should capture enough information to answer:

- What application version was running?
- What build was running?
- When did the problem occur?
- What operating environment was being used?
- What was the application doing?
- What had the user recently done?
- What application state was relevant?
- What operations succeeded immediately beforehand?
- What operation failed?
- What exception/error occurred?
- What important warnings occurred beforehand?
- What configuration/options were relevant?
- Were external resources/files/devices/services involved?
- Was the application already behaving abnormally before the final failure?

The system should make debugging a remote user's problem dramatically easier.

---

# 2. CENTRALIZED LOGGING

Implement or standardize a centralized application logging system.

Application code should have a straightforward way to emit diagnostic events.

Support appropriate severity levels such as:

- Trace
- Debug
- Information
- Warning
- Error
- Critical/Fatal

Use the logging facilities idiomatic to the application's language/framework where practical rather than unnecessarily inventing a logging framework.

Logs should include timestamps.

Where useful, include:

- Severity
- Component/module
- Operation
- Thread/task information
- Exception details
- Relevant identifiers
- Relevant application state

Logs should be useful to a developer reading them later.

Avoid meaningless messages like:

"Operation failed."

Prefer:

"Failed to load project '/path/project.xyz': invalid header version 7."

when that information is safe to record.

---

# 3. STRUCTURED LOGGING

Prefer structured diagnostic information where practical.

For example, conceptually:

Event: ProjectLoadFailed
Path: ...
Reason: ...
ExceptionType: ...
DurationMs: ...

rather than constructing everything as arbitrary prose.

The exact implementation should follow conventions appropriate for the project's technology.

Do not over-engineer this into a massive telemetry platform.

The important requirement is that diagnostic information remains understandable and searchable.

---

# 4. SESSION IDENTIFICATION

Assign each application execution a unique session identifier.

Record it when the application starts.

This allows all events from one execution to be correlated.

Include the session ID in the generated diagnostic package.

If the application launches multiple processes/components, provide correlation identifiers where useful.

---

# 5. APPLICATION STARTUP INFORMATION

At startup, record useful non-sensitive information such as:

- Application name
- Application version
- Build/version identifier
- Build date if available/reliable
- Debug/release configuration if relevant
- Architecture
- Runtime/framework version
- Operating system/version
- Process architecture
- Application start time
- Relevant locale/culture
- Relevant display/UI scaling information for GUI applications
- Relevant command-line options, AFTER removing sensitive information

Do not collect information merely because it is technically available.

Capture things that could realistically explain application behavior.

---

# 6. IMPORTANT USER ACTIONS

Record meaningful user actions at the APPLICATION level.

Examples:

- Created project
- Opened project
- Imported file
- Selected item
- Changed major mode
- Saved
- Save As
- Exported
- Deleted item
- Added item
- Started operation
- Canceled operation
- Opened important dialog
- Applied settings
- Changed significant configuration

Do NOT log every mouse movement, keystroke, hover event, or meaningless UI event.

The objective is to reconstruct the user's workflow, not surveil them.

A useful diagnostic history might read:

14:03:11 Application started
14:03:18 Opened project
14:03:26 Selected card #17
14:03:31 Changed card style
14:03:37 Selected artwork
14:03:42 Save started
14:03:42 Save failed: UnauthorizedAccessException

That is vastly more useful than thousands of low-level UI messages.

---

# 7. OPERATION LIFECYCLE LOGGING

For important operations, record BOTH beginning and outcome.

Conceptually:

Import started
Import completed successfully

or:

Import started
Import failed
Exception...

Where useful, record duration.

Apply this to significant operations such as:

- Load
- Save
- Import
- Export
- Network operations
- Device communication
- External processes
- Parsing
- Generation
- Compilation
- Long-running operations
- Database operations

This makes it possible to identify operations that started but never completed.

---

# 8. EXCEPTION CAPTURE

Capture handled exceptions where they represent meaningful failures.

Include:

- Exception type
- Message
- Stack trace
- Inner/nested exceptions
- Relevant operation context

Do not destroy useful exception information by replacing exceptions with generic messages.

For example, avoid:

catch (...)
{
    Log("Something failed");
}

when the original exception contains the information necessary to diagnose the problem.

---

# 9. UNHANDLED EXCEPTION CAPTURE

Install appropriate top-level/unhandled exception handlers supported by the application's platform.

The objective is to record useful information when the application encounters an unexpected failure.

Where applicable, consider:

- Main/UI thread exceptions
- Background thread exceptions
- Unobserved task exceptions
- Process-level unhandled exceptions

Do NOT attempt to continue running indefinitely after catastrophic corruption simply because an exception handler exists.

The handler exists primarily to preserve diagnostic information and, where safe, provide a comprehensible failure experience.

---

# 10. CRASH INFORMATION

If the platform allows reasonable crash diagnostics, preserve information about unexpected termination.

At minimum, the next application launch should ideally be able to recognize:

"The previous session did not shut down normally."

If useful, include the previous session's logs in the diagnostic package.

Do not build an enormous crash-reporting infrastructure unless the application warrants it.

---

# 11. RECENT EVENT HISTORY

Maintain enough recent diagnostic history to reconstruct what happened BEFORE a failure.

This is important.

Often the final exception is not the real cause.

For example:

Configuration loaded with warning
→ resource missing
→ fallback used
→ user begins export
→ unexpected state
→ crash

The diagnostic system should preserve that chain.

---

# 12. LOG FILE MANAGEMENT

Logs should be written somewhere appropriate for the platform/application.

Do not allow logs to grow forever.

Implement reasonable rotation/retention.

Possible strategies include:

- Maximum file size
- Maximum number of files
- Maximum age
- Per-session files

Choose something appropriate for the application.

The application should remain safe even if it runs for months.

Logging must not eventually fill the user's disk.

---

# 13. LOGGING MUST NOT BREAK THE APPLICATION

The diagnostic system itself must be defensive.

If logging fails because of:

- Permission problems
- Disk full
- Invalid log directory
- File locking
- I/O failure

the application should not normally crash solely because it could not write a log.

Logging should degrade gracefully.

Avoid recursive failure patterns where:

Logging failed
→ log the logging failure
→ logging failed
→ log the logging failure
→ ...

---

# 14. DIAGNOSTIC PACKAGE

Implement a user-facing command such as:

**Help → Save Diagnostic Report...**

or another location appropriate for the application's UI.

This command should create ONE portable diagnostic package.

A ZIP archive is usually appropriate unless there is a project-specific reason to use something else.

Use a recognizable filename such as:

AppName_Diagnostics_2026-09-26_143512.zip

Use a filename format appropriate for the platform.

---

# 15. DIAGNOSTIC PACKAGE CONTENTS

The package should contain useful artifacts such as:

## summary.txt

A human-readable overview containing:

- Application version
- Build
- Session ID
- Current timestamp
- Application start time
- Operating system
- Runtime/framework
- Relevant environment information
- Current application state
- Current document/project if safe
- Whether there are unsaved changes
- Most recent major operation
- Recent errors/warnings

This should allow a developer to get useful information WITHOUT immediately reading raw logs.

## logs/

Include relevant application logs.

Prioritize:

- Current session
- Previous abnormal/crashed session if applicable
- Limited recent historical logs if useful

Do not dump months of logs into every package.

## configuration/

Include diagnostic-safe application configuration where useful.

REMOVE OR REDACT secrets.

## diagnostics.json

Where practical, include a machine-readable structured summary containing the same major diagnostic information.

This makes future automated analysis easier.

Additional artifacts may be included if they genuinely help diagnose this particular application.

---

# 16. CURRENT APPLICATION STATE

When generating the package, capture a diagnostic snapshot of current state.

Examples might include:

- Current mode
- Loaded project/document type
- Dirty/clean state
- Number of loaded objects
- Current selection identifier
- Active tab/view
- Important feature states
- Background operations
- Relevant caches/resources
- Current workflow stage

Do not serialize the entire application's memory.

Create an intentional diagnostic representation.

---

# 17. CONFIGURATION SNAPSHOT

Capture relevant configuration because many "bugs" are actually configuration-dependent.

Include useful settings.

Exclude/redact:

- Passwords
- Authentication tokens
- API keys
- Cookies
- Private keys
- Credentials
- Connection strings containing secrets
- Anything else explicitly marked sensitive

Prefer allowlisting diagnostic-safe configuration over blindly dumping every configuration object.

---

# 18. PRIVACY AND SENSITIVE INFORMATION

THIS IS IMPORTANT.

Diagnostic packages should NOT become accidental data-exfiltration bundles.

Do not automatically include:

- Passwords
- Authentication tokens
- API keys
- Cookies/session tokens
- Private keys
- Credential stores
- Entire user documents
- Arbitrary user files
- Clipboard contents
- Environment variables wholesale
- Memory dumps by default
- Browser data
- Unrelated filesystem information

Be cautious with:

- Usernames
- Home directory paths
- Full file paths
- Network paths
- Machine names
- Email addresses
- Document contents

Capture only what is genuinely useful.

Where appropriate, sanitize paths.

For example, it may be useful to transform:

C:\Users\Bob\Documents\Project\foo.xyz

into something like:

%USERPROFILE%\Documents\Project\foo.xyz

depending on the application's needs.

---

# 19. USER CONTENT

Do not automatically include the user's actual working files unless there is a strong application-specific reason.

If reproducing a problem requires the user's project/document/input data, make this a deliberate and visible option.

For example:

[ ] Include current project file

Explain that this may contain user-created content.

Default to NOT including sensitive user content unless there is a compelling reason otherwise.

---

# 20. SCREENSHOT OPTION

For GUI applications, consider an OPTIONAL mechanism to include a screenshot of the application's current window.

This can be extremely useful for layout/UI problems.

However:

- Make it explicit.
- Do not capture unrelated applications.
- Prefer the application's own window rather than the entire desktop.
- Make the user aware that the screenshot may contain visible information.

Do not silently screenshot users.

---

# 21. USER DESCRIPTION

When saving a diagnostic report, optionally allow the user to enter a short description:

"What happened?"

and perhaps:

"What were you trying to do?"

This description should be included in the package.

Do not require the user to understand technical terminology.

A simple free-form text box is sufficient.

---

# 22. REPRODUCTION STEPS

Optionally provide a field for:

"Steps to reproduce, if known"

Again, keep this lightweight.

Do not make submitting diagnostics feel like completing a tax return.

---

# 23. SUCCESS EXPERIENCE

After successfully creating the package, clearly tell the user:

- That it succeeded
- Where the file was saved
- What file should be sent to the developer

Provide an easy way to:

- Open containing folder

where appropriate for the platform.

Do not automatically email/upload/send anything unless the application explicitly has such a feature and the user deliberately requests it.

---

# 24. FAILURE EXPERIENCE

Diagnostic package generation itself can fail.

Handle this gracefully.

If creating the package fails:

- Do not crash.
- Explain what failed.
- Preserve existing logs.
- Allow the user to try another location where appropriate.

Avoid the embarrassing situation where:

"The application failed, and then the error-reporting system also failed catastrophically."

---

# 25. OPTIONAL COPY DIAGNOSTIC SUMMARY

Consider providing:

**Help → Copy Diagnostic Summary**

This should copy a SMALL textual summary suitable for pasting into:

- Email
- Chat
- Issue tracker
- Support ticket

Example:

Application: ExampleApp 2.4.1
Build: 8421
OS: Windows 11 24H2
Runtime: .NET 10
Session: ...
Started: ...
Current State: Project loaded, modified
Last Operation: Export
Last Error: IOException during export
Diagnostic Package: available separately

Do not copy thousands of lines of logs.

This feature is complementary to the full diagnostic package.

---

# 26. DEVELOPMENT VS RELEASE LOGGING

Support appropriate differences between development and release builds.

Development builds may capture substantially more detailed diagnostic information.

Release builds should still capture enough information to diagnose real-world failures.

Do NOT make release logging so minimal that user bug reports become impossible to investigate.

Conversely, do not continuously emit enormous trace logs in production without justification.

---

# 27. DEBUG MODE

If useful for the application, support an optional temporary enhanced diagnostic/debug mode.

For example:

Settings → Enable Detailed Logging

When enabled, additional information can be recorded for difficult-to-reproduce problems.

This mode should:

- Be clearly indicated
- Avoid secrets
- Have bounded log growth
- Ideally be easy to disable
- Not permanently degrade performance

If practical, consider automatically reverting detailed logging after a reasonable period/session so users do not accidentally leave extremely verbose logging enabled forever.

Do not implement this if normal logging already provides everything necessary.

---

# 28. PERFORMANCE

Logging should not materially damage normal application performance.

Avoid:

- Excessive synchronous disk writes on UI threads
- Logging enormous objects
- Serializing entire state repeatedly
- Logging inside extremely hot loops without need
- Building expensive diagnostic strings when the log level would discard them

Use appropriate buffering/asynchronous mechanisms if warranted by the technology.

But do not make the logging architecture unnecessarily complicated.

---

# 29. CORRELATION / OPERATION IDS

For complex operations, consider assigning an operation/correlation ID.

Example:

Export [operation 84F2] started
Export [operation 84F2] loading assets
Export [operation 84F2] rendering
Export [operation 84F2] failed

This is especially useful when multiple operations can overlap.

Use this only where it adds meaningful diagnostic value.

---

# 30. TIMING INFORMATION

For meaningful operations, record durations where useful.

Examples:

Project loaded successfully (842 ms)

Export completed (4.2 sec)

Device connection timed out (30.0 sec)

Unexpectedly slow operations are often themselves valuable diagnostic information.

---

# 31. EXTERNAL DEPENDENCIES

Where relevant, record diagnostic information about dependencies the application relies upon.

Examples:

- External executable versions
- Connected device type/version
- Database version
- API/service endpoint category
- Plugin versions
- Driver versions
- Important library/runtime versions

Do not dump credentials or sensitive connection information.

---

# 32. PLUGINS / EXTENSIONS

If the application supports plugins/extensions/modules, include:

- Installed plugin names
- Versions
- Enabled/disabled state

Plugin-related failures should identify which plugin was involved where possible.

---

# 33. FILE OPERATIONS

For applications heavily involving files, log meaningful operations such as:

- Open requested
- File validated
- Parse started
- Parse succeeded
- Save started
- Save succeeded
- Export started
- Export succeeded

On failure, record enough safe information to understand the problem.

Be thoughtful about full paths and user privacy.

---

# 34. APPLICATION STATE BREADCRUMBS

Implement lightweight breadcrumbs for major state transitions.

Examples:

Application started
→ project opened
→ editor activated
→ item selected
→ style changed
→ save started
→ save succeeded
→ export started
→ export failed

These breadcrumbs are often more valuable than huge amounts of low-level logging.

The developer should be able to reconstruct the user's recent journey.

---

# 35. ASSERTIONS / IMPOSSIBLE STATES

Where appropriate, identify internal invariants.

If the application reaches a state that "should never happen," record detailed diagnostic context.

Do not merely log:

"Invalid state."

Record enough information to understand:

- Expected state
- Actual state
- Relevant object identifiers
- Current operation
- Previous state/operation

Development builds may assert aggressively where appropriate.

Release builds should fail safely and preserve diagnostics.

---

# 36. SUPPORT PACKAGE MANIFEST

Include a manifest listing what the diagnostic package contains.

For example:

manifest.txt

Application Version: ...
Created: ...
Session: ...

Included:
- summary.txt
- diagnostics.json
- logs/session.log
- configuration/settings.json

Excluded:
- User project
- Screenshot
- Credentials

This makes the package self-describing.

---

# 37. DIAGNOSTIC PACKAGE VERSION

Give the diagnostic package format a version.

Example:

DiagnosticFormatVersion: 1

This costs almost nothing and allows the format to evolve later without ambiguity.

---

# 38. HUMAN READABILITY

Do not make diagnostics exclusively machine-readable.

A developer should be able to unzip the package and immediately understand it.

Likewise, do not make everything exclusively free-form text.

A good combination is:

- Human-readable summary
- Human-readable logs
- Structured JSON diagnostic snapshot

---

# 39. TEST THE DIAGNOSTIC SYSTEM

Add tests where practical.

Test:

- Normal logging
- Exception logging
- Log rotation
- Package generation
- Package naming
- Summary generation
- Structured diagnostic generation
- Redaction
- Failed package creation
- Invalid destination
- Missing log files
- Empty log directory
- Previous abnormal session
- Optional user-content inclusion
- Configuration sanitization

Security/privacy tests are particularly important.

Explicitly verify that known secret fields DO NOT appear in generated packages.

---

# 40. MANUAL END-TO-END TEST

Perform an actual end-to-end test.

1. Start application.
2. Perform several normal operations.
3. Trigger or simulate a recoverable failure.
4. Continue using application if appropriate.
5. Save Diagnostic Report.
6. Open the resulting package.
7. Pretend you are the developer receiving it with ZERO additional information.

Ask:

"Can I understand what happened?"

Verify:

- Version is present.
- Environment is present.
- Recent workflow is understandable.
- Failure is identifiable.
- Stack trace/context exists where appropriate.
- Configuration relevant to the failure exists.
- Secrets are absent.
- Package is reasonably sized.
- Files are understandable.
- User did not need to manually collect anything.

If the package leaves obvious debugging questions unanswered that the application could reasonably have captured, improve it.

---

# 41. CENTRALIZE DIAGNOSTIC SNAPSHOT GENERATION

Avoid having the Save Diagnostic Report UI manually gather information from dozens of unrelated components.

Create a clean diagnostic collection abstraction appropriate to the architecture.

Conceptually, the application should be able to request something equivalent to:

GetDiagnosticSnapshot()

which gathers diagnostic-safe information from relevant subsystems.

This makes diagnostics maintainable as the application evolves.

---

# 42. FUTURE MAINTAINABILITY

Make it easy for future features to participate in diagnostics.

When a new subsystem is added, there should be an obvious pattern for adding:

- Logging
- State snapshot information
- Relevant version information
- Error context

Document that pattern briefly for future developers.

---

# 43. DO NOT BUILD TELEMETRY UNLESS REQUESTED

This specification is primarily for LOCAL diagnostics.

Do NOT automatically implement:

- Cloud logging
- Remote telemetry
- Analytics
- Usage tracking
- Automatic crash uploads
- Automatic support uploads
- Background reporting

unless the application already requires those things.

The default model is:

Diagnostics remain local.

The USER deliberately chooses:

Save Diagnostic Report

and then decides whether to send it.

This keeps the system simple, predictable, privacy-conscious, and usable even for completely offline applications.

---

# 44. IMPLEMENTATION QUALITY

Do not simply bolt a logger onto the application and call this complete.

Integrate diagnostics into meaningful application boundaries.

Important operations should provide enough context to understand their lifecycle.

Errors should retain their causes.

The support package should actually be useful.

At the same time:

Do not scatter logging calls indiscriminately across every line of code.

Capture SIGNAL, not noise.

---

# ACCEPTANCE CRITERIA

The implementation is complete when:

1. Important application operations are logged meaningfully.

2. Important failures include useful exception/context information.

3. Unexpected failures have a reasonable diagnostic capture path.

4. Logs have bounded storage/retention.

5. Logging failure does not normally crash the application.

6. The application provides a simple user-facing **Save Diagnostic Report** command.

7. That command produces ONE easy-to-send package.

8. The package contains a human-readable summary.

9. The package contains relevant logs.

10. The package contains a structured diagnostic snapshot where appropriate.

11. Relevant configuration/state is captured safely.

12. Secrets and sensitive information are excluded/redacted.

13. User-created content is not silently bundled.

14. Package generation is itself robust against failure.

15. The diagnostic system has been tested end-to-end.

16. A developer receiving ONLY the package has a strong chance of understanding what happened.

The final standard is:

> A user should never have to tell me "I don't know, it just didn't work" when the application itself had enough information to tell me what happened.

Build the diagnostics system so the application can tell us its side of the story.