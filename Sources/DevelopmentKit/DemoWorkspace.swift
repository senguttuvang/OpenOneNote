import Foundation
import Darwin
import MarkdownNotes

extension DevelopmentWorkflow {
    /// A local-only fictional startup notebook; never merges into an existing vault.
    @discardableResult public func createDemoVault(at output: URL) throws -> Int {
        let files = FileManager.default
        guard !files.fileExists(atPath: output.path),
              (try? output.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) != true else {
            throw DevelopmentError.outputExists(output.path)
        }
        let codec = MarkdownConversion()
        let pages = try StartupDemo.pages.map { page in
            var ledger = NoteLedger(identity: PageIdentity(root: "local", pageID: UUID().uuidString),
                title: page.title, baseline: try codec.parse(page.body), markdown: page.body, htmlHash: "", assets: [])
            ledger.hierarchy = ["Orbit — Startup Notebook", page.section]
            ledger.state = "local-only"
            return ledger
        }
        // Reserve a new directory without accepting an existing empty directory or a racing writer.
        guard mkdir(output.path, mode_t(0o700)) == 0 else {
            let code = errno
            if code == EEXIST { throw DevelopmentError.outputExists(output.path) }
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(code))
        }
        let vault = try MarkdownVault(root: output)
        for page in pages { try vault.create(page) }
        print("Created \(pages.count) fictional startup pages in \(output.path). Local only; no Microsoft account or cloud writes.")
        return pages.count
    }
}

private struct StartupDemo {
    struct Page { let section: String; let title: String; let body: String }
    static let pages: [Page] = [
        Page(section: "01 Product", title: "01 Product brief", body: """
        Orbit helps product teams turn customer conversations into clear decisions and shipped improvements.

        ## November private beta

        **Our focus:** help a small SaaS team close its first feedback loop in one day.

        | Metric | Today | Next milestone |
        | --- | --- | --- |
        | Active pilot teams | 8 | 12 |
        | Onboarding completion | 48% | 65% |
        | Time to first insight | 2.3 days | Under 1 day |

        ## This week's priorities

        - Shorten onboarding to three useful steps.
        - Connect customer feedback from Slack and support.
        - Send a weekly digest of decisions and shipped updates.

        ## Product principles

        Capture context once. Make the next action obvious. Keep the team in control.

        ## Open decisions

        Should new teams begin with sample feedback or import their own? Test both with the next four pilots before changing the default.
        """),
        Page(section: "01 Product", title: "02 Onboarding flow", body: """
        ## From signup to first useful decision

        ```mermaid
        flowchart LR
            A[Invite team] --> B[Import feedback]
            B --> C[Pick a priority]
            C --> D[Ship an update]
        ```

        ## What success looks like

        A new team connects one feedback source, groups three related requests, and shares a decision with its owner.

        - Invite colleagues after the first useful result.
        - Offer sample data when an integration is not ready.
        - Save progress so onboarding can continue later.

        ## Acceptance criteria

        The flow works with a keyboard, reports integration failures clearly, and never loses imported feedback on retry.
        """),
        Page(section: "01 Product", title: "03 Roadmap", body: """
        ## Now

        - Feedback inbox and duplicate grouping.
        - Guided onboarding for the first workspace.
        - Weekly product digest.

        ## Next

        - Linear issue links and release updates.
        - Customer-facing changelog.
        - Saved views for product and customer-success teams.

        ## Later

        Explore account-level prioritization after pilots consistently use the core feedback loop.
        """),
        Page(section: "01 Product", title: "04 Sprint 07 planning", body: """
        ## Goal

        Help every pilot team reach a useful first result without a live onboarding call.

        | Work | Owner | Status |
        | --- | --- | --- |
        | Import retry states | Engineering | In progress |
        | Three-step welcome | Product | In review |
        | Pilot checklist | Customer success | Ready |

        ## Out of scope

        New integrations and pricing changes. Review pilot recordings on Friday before planning the next sprint.
        """),
        Page(section: "02 Engineering", title: "Architecture overview", body: """
        ## System boundaries

        The web client reads workspace data through the API. Background workers ingest feedback and deliver digests. Postgres stores workspace state; an outbox records pending side effects.

        ## Reliability decisions

        - Use idempotency keys for imports and outbound messages.
        - Retry transient provider failures with bounded backoff.
        - Keep an audit trail for merges and prioritization changes.
        - Test backup restoration before expanding the pilot.
        """),
        Page(section: "02 Engineering", title: "API contract", body: """
        ## Feedback ingestion

        Each item includes a workspace, source, external identifier, text, received timestamp and optional customer reference.

        ## Contract

        Repeating an external identifier updates the existing item rather than creating a duplicate. Workspace permissions are checked for every request. Invalid payloads return an actionable error without storing partial state.
        """),
        Page(section: "02 Engineering", title: "ADR 003 — import outbox", body: """
        ## Decision

        Record import events and pending follow-up work in the same database transaction. A worker processes the outbox after commit.

        ## Why

        A successful API response must not leave feedback saved without its follow-up work. Replays are expected, so consumers must be idempotent.

        ## Trade-off

        We own worker monitoring and recovery. Alert on the age of the oldest pending event, not just queue length.
        """),
        Page(section: "03 Customer Research", title: "Interview synthesis", body: """
        ## What we heard

        Pilot teams collect requests in support tickets, Slack and meeting notes. The difficult step is explaining which requests influenced a decision and closing the loop afterwards.

        ## Opportunity

        Give every decision a short rationale, linked feedback and a clear owner. Avoid making customers maintain another prioritization spreadsheet.

        ## Next research

        Observe four teams during weekly planning. Test whether a digest helps customer-success colleagues explain what changed.
        """),
        Page(section: "03 Customer Research", title: "Pilot feedback", body: """
        ## Themes

        - Import setup needs clearer permissions guidance.
        - Duplicate suggestions need an easy undo.
        - Teams want a concise explanation when a request is deferred.

        ## Follow-up

        Add setup troubleshooting, retain merge history and test a short decision template with the next pilot group.
        """),
        Page(section: "03 Customer Research", title: "Customer journey", body: """
        ## First week

        Discover Orbit, connect a feedback source, review a small set of requests, choose a priority and share the decision.

        ## Friction to remove

        Empty states, unclear permissions and the gap between a product decision and a customer update.

        ## Evidence to collect

        First useful decision, first colleague invited and first customer loop closed. Track the journey without storing unnecessary personal data.
        """),
        Page(section: "04 Go-to-Market", title: "Positioning", body: """
        ## Who it is for

        Small B2B SaaS teams whose product and customer-success colleagues need a shared view of feedback and decisions.

        ## Promise

        Turn scattered customer requests into decisions people can explain.

        ## First channel

        Founder-led pilot conversations and practical teardown posts. Learn the buying trigger before committing to paid acquisition.
        """),
        Page(section: "04 Go-to-Market", title: "Launch checklist", body: """
        ## Before inviting the next cohort

        - Publish a short product walkthrough.
        - Verify signup, workspace isolation and support routing.
        - Prepare sample data and integration guidance.
        - Test billing in a sandbox.
        - Agree on pilot expectations and feedback sessions.

        ## After launch

        Review activation and support issues daily. Keep a single list of repeated onboarding friction.
        """),
        Page(section: "04 Go-to-Market", title: "Pricing experiment", body: """
        ## Hypothesis

        Pilot teams understand workspace pricing more readily than charging every occasional collaborator for a full seat.

        ## Experiment

        Discuss a workspace plan with a usage allowance in pilot interviews. Compare willingness to pay with the time saved closing customer feedback loops.

        ## Decision rule

        Choose a model only after validating the buyer, expected usage and support cost. These are fictional planning notes, not an offer.
        """),
        Page(section: "05 Operations", title: "Weekly operating review", body: """
        ## Monday review

        Review activation, support backlog, integration reliability and the next pilot cohort. Assign one owner and a next action to each exception.

        ## This week

        Improve the import error guide, rehearse a restore, and schedule four customer planning observations.

        ## Follow-through

        Record decisions in the product brief and update owners before Friday's review.
        """),
        Page(section: "05 Operations", title: "Metrics definitions", body: """
        ## Activation

        A workspace imports feedback, groups related items and shares a first decision within seven days.

        ## Weekly active team

        A workspace where at least two colleagues review feedback or record a decision during the week.

        ## Closed loop

        A customer request has a recorded outcome and an update has been sent to the responsible customer-facing colleague.
        """),
        Page(section: "06 Team Knowledge", title: "Working agreements", body: """
        ## How we work

        Write decisions down, keep work small and link implementation back to the customer problem. Review assumptions when new evidence arrives.

        ## Team rhythm

        Monday priorities, Wednesday customer learning, Friday demo and retrospective. Use async notes to keep meetings focused on decisions.
        """),
        Page(section: "06 Team Knowledge", title: "Demo workspace guide", body: """
        ## About this notebook

        Orbit is a fictional startup. Every note, target and metric in this workspace is sample content created for O2N documentation and screenshots.

        ## Explore

        Open the product brief in the normal editor, then use the Markdown icon on the onboarding-flow page to compare source and rendered content. This local-only notebook contains no account configuration and does not sync to Microsoft.
        """)
    ]
}
