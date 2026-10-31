# Custom Software And The SaaS Trade-Off

Replacing a SaaS workflow can mean building the subset a team uses, combining it with other tools and adapting it to a particular way of working. It need not mean reproducing the vendor's whole feature catalogue. O2N is a small experiment in that choice: a familiar Mac notebook client with Markdown-oriented capabilities and an existing cloud ecosystem.

## Start With The Workflow

The useful question is what the team needs to accomplish. Which interactions are frequent? Which integrations remove repeated work? Which features are essential for colleagues who continue using the original product?

Saying that someone uses only a fraction of a large application is an illustration of scope, not a measured universal percentage. A team should identify its own useful subset. Some capabilities that appear peripheral in a prototype, such as permissions, export, recovery or accessibility, may be essential in daily operation.

For O2N, the interesting subset is native notebook writing, Markdown/code-oriented content and coexistence with official OneNote. Freeform canvas features, audio or a complete Office suite are not prerequisites for exploring that workflow. A narrow client can still require substantial work at the compatibility boundary.

AI-assisted development can make the first useful prototype quicker to attempt. The speed of the first screen or parser does not establish production readiness, complete feature parity or a small lifetime maintenance cost.

## Choose The Ownership Boundary

There are several different decisions inside the phrase "replace SaaS":

- **Customize a client:** own the interface and its document conversions while retaining an existing service and supported APIs.
- **Add extension state:** keep the service's content, but introduce metadata or collaboration behavior that participating clients must share and reconcile.
- **Own the backend:** control the data model and service while taking responsibility for authorization, revisions, synchronization, backups, migrations and availability.

O2N currently explores the first boundary, with local source/recovery metadata and a specific source-aware diagram transport. Shared annotations and a general metadata service remain proposals. Keeping the OneNote backend retains useful infrastructure; O2N still owns its own refresh, conversions and conflict behavior. The [compatible-client analysis](compatible-onenote-client.md) develops that distinction.

Moving to a different backend might be justified for a different product. It would not automatically preserve collaboration with people using official OneNote. A compatibility bridge would become another maintained subsystem.

## Price The Whole Operating Life

A small delivery business may reasonably buy pickup and delivery management from a specialist. It gains a working system without immediately funding an internal engineering operation.

At larger order volumes, a recurring per-order charge could make an in-house workflow worth evaluating. That is a conditional example, not a claim that internal software is always cheaper. Compare both choices over the same period and expected scale:

| Buying | Building and operating |
| --- | --- |
| Avoidable subscription, seat or transaction charges | Product work, engineering and integration |
| Configuration and vendor integration work | Hosting, observability, backups and migrations |
| Support arrangements and contractual limits | Support, on-call coverage and incident response |
| Vendor roadmap and switching constraints | Upgrades, dependency/API changes and team continuity |
| Available reliability and capabilities | Expected reliability, missing capabilities and cost of failure |

Include the value of workflow fit and the cost of disrupting a working team. Count only fees that the replacement can actually eliminate. If colleagues still need vendor accounts or the same hosted service, a custom client may improve productivity without removing those charges.

The case becomes stronger when a narrow, important workflow has high recurring cost, clear requirements and a team capable of maintaining it. It becomes weaker when the vendor's broader capabilities, compliance work or support would be expensive to recreate, or when ownership depends on one person with no operating budget.

Production software is difficult to build and maintain. A strong incentive can justify funding that work; the difficulty is a cost to include, not a proof that the choice is impossible.

## What Customers Might Still Pay For

One hypothesis is that more value will move toward platforms that help teams deploy, secure, integrate and maintain software they can customize. Generating an application does not remove the need for permissions, reliable upgrades, backups, observability, incident response or someone accountable when it fails.

This is a product hypothesis, not a prediction that subscriptions or seat pricing disappear. Seat, usage, resource and managed-service pricing allocate costs differently. Any of them can be sensible when the customer receives enough value. Compare current contract terms and operating costs rather than assuming one billing unit is inherently better.

A familiar interface and a large feature list are only part of a service's value. Equally, an existing service does not prevent a team from building a better-fitting client around lawful interfaces and independently authored code. The sensible boundary depends on incentives, team capability and the amount of shared state the team chooses to own.

## What This Means For O2N

O2N is an open-source developer preview, not an enterprise replacement promise. Its next investments should follow the real cost of ownership: preserve existing notes, improve official-client interoperability, make native editing predictable and describe recovery and limits clearly.

The [product roadmap](../ROADMAP.md) puts compatibility hardening before speculative collaboration infrastructure. MIT applies to independently authored O2N code; third-party material and the repository's legacy research have separate boundaries in the [release guide](../PUBLIC_RELEASE.md). A useful-subset strategy does not grant rights to redistribute another vendor's application or assets.
