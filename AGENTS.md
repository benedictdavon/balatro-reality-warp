AGENTS.md

Purpose

This repository is maintained using a multi-agent /goal workflow.

The primary objective is to stabilize Balatro: Reality Warp by processing every actionable finding in:

• ISSUE.md
• BUG_AUDIT.md

until each finding reaches a valid terminal state.

This file defines the operating rules for all coding agents working in this repository. These instructions apply to the repository root and all subdirectories unless a more specific AGENTS.md exists deeper in the tree.

────────

1. Agent roles

Sol High — orchestrator, senior engineer, and reviewer

Sol High is the lead agent for the /goal.

Sol High is responsible for:

• reading and understanding the full project backlog;
• deciding issue order based on dependencies;
• revalidating issues against the current main branch before work begins;
• preparing a precise implementation brief for each issue;
• delegating routine implementation work to Luna Max;
• independently reviewing every delegated PR;
• requesting corrections when necessary;
• deciding when an issue is too architectural, risky, ambiguous, or inefficient to delegate;
• taking over implementation directly when appropriate;
• keeping issue/backlog status current;
• continuing through the backlog until the overall /goal completion criteria are satisfied.

Sol High must not stop after completing one issue.

Sol High is the final technical reviewer for delegated work.

Luna Max — implementation agent

Luna Max normally implements one issue at a time.

For each delegated issue, Luna Max is responsible for:

1. reading this AGENTS.md;
2. reading the relevant sections of ISSUE.md and BUG_AUDIT.md;
3. confirming the current main commit and working-tree state;
4. creating the requested issue branch;
5. tracing the current implementation before changing code;
6. implementing the smallest justified fix;
7. avoiding unrelated refactors;
8. running all applicable static/local checks;
9. reviewing its own diff;
10. committing the change;
11. pushing the branch;
12. opening a pull request;
13. returning a concise implementation and validation summary.

Luna Max must update the same branch and PR when Sol High requests changes.

Luna Max must not create a replacement PR for review corrections unless Sol High explicitly requests one.

────────

2. Source-of-truth documents

Before modifying production code, agents must read:

1. AGENTS.md
2. ISSUE.md
3. BUG_AUDIT.md

The audit is source-grounded but not a substitute for revalidation.

Before implementing an issue, verify that:

• the relevant code still exists;
• the issue has not already been resolved by an earlier merged fix;
• audit assumptions still match the current main;
• dependency fixes have already landed.

Do not blindly implement an old audit recommendation after surrounding architecture has changed.

────────

3. Development model

Use Option A: sequential independent issue branches.

Every issue branch starts from the latest accepted main.

Do not create dependent fixes in parallel from an outdated base.

The normal sequence is:

main
  ↓
issue A branch
  ↓
PR A reviewed
  ↓
PR A accepted/merged
  ↓
refresh main
  ↓
revalidate issue B
  ↓
issue B branch

If issue B depends on issue A, issue A must be completed first.

Avoid stacked PRs unless Sol High explicitly determines that they are necessary.

────────

4. Branch naming

Use simple conventional branch names.

Bug fixes:

fix/problem-statement

Examples:

fix/botg-encounter-lifecycle
fix/chicot-disabled-effects
fix/ouroboros-draw
fix/helin-exponent
fix/lucky-one-rng
fix/arrow-rank-mapping

Features:

feat/new-feature

Examples:

feat/consumable-stacking

Documentation-only work may use:

docs/problem-statement

Do not include issue numbers unless Sol High explicitly requests them.

Do not use personal names, agent names, dates, or temporary wording in branch names.

────────

5. Commit convention

Use simplified Conventional Commit prefixes without scopes.

Allowed examples:

fix: unify Battle of Gods encounter lifecycle
fix: prevent disabled Blind effects
fix: restore Iron Maiden hand size
fix: correct Helin exponent scoring
feat: add consumable quantity stacking
docs: add regression test plan
test: add Blind lifecycle regression coverage
refactor: centralize Blind identity helpers

Do not use scoped forms such as:

fix(botg): ...
fix(joker): ...

Keep commits focused.

Do not mix unrelated fixes in one commit unless they are inseparable parts of the same root cause.

────────

6. One issue per branch and PR

Default rule:

> One independently actionable issue = one branch = one PR.

A branch may cover several audit labels only when they are manifestations of the same root cause and separating them would create duplicated or unsafe architecture.

Sol High decides whether tightly related findings should be grouped.

Examples that may reasonably be grouped:

• one encounter-lifecycle refactor that resolves duplicate schedulers, encounter identity, usage-counter pollution, and encounter parameter persistence;
• one effect-lifecycle fix that requires shared disabled-state and event ownership infrastructure.

Examples that should normally remain separate:

• Helin exponent scoring;
• Ouroboros draw count;
• Lucky One RNG;
• Arrow rank mapping;
• consumable stacking.

Do not opportunistically fix adjacent unrelated problems while inside a branch.

If a new issue is discovered, document it and let Sol High decide where it belongs.

────────

7. Issue states

Sol High must maintain a clear state for every finding.

Use these states:

DISCOVERED
AUDITED
BLOCKED
READY
IN_PROGRESS
PR_OPEN
CHANGES_REQUESTED
APPROVED
HUMAN_TEST_NEEDED
FIXED
NOT_A_BUG
STALE

FIXED

Implementation is complete and reviewed, with all agent-executable validation completed.

If runtime-only Balatro validation remains necessary, the issue should additionally be recorded as requiring human testing before being considered fully verified in practice.

NOT_A_BUG

The behavior is intentional or the reported symptom has a valid non-defect explanation.

The conclusion must be supported by current code/framework evidence.

Do not modify code merely to make a reported non-bug disappear.

STALE

The historical issue no longer exists on current main, or the implicated implementation is absent/replaced.

Add an appropriate regression test/check when practical.

HUMAN_TEST_NEEDED

The source fix/review is complete, but correctness cannot be established without a real Balatro runtime, save round trip, optional dependency, or manual gameplay scenario unavailable to the agent.

This is a valid autonomous-work terminal state but must be included in the final human regression queue.

BLOCKED

Use only when the agent genuinely lacks information, a dependency, environment capability, or required artifact.

Do not use BLOCKED merely because a task is difficult.

A blocker must specify:

• exactly what is missing;
• why it is necessary;
• what would unblock the issue.

────────

8. /goal completion criteria

The orchestrator must continue through the dependency-ordered backlog.

Do not declare the /goal complete simply because all obvious code changes were made.

The /goal is complete only when every actionable finding in ISSUE.md and BUG_AUDIT.md has been explicitly accounted for as one of:

FIXED
NOT_A_BUG
STALE
HUMAN_TEST_NEEDED

BLOCKED does not count as overall completion unless the blocker truly requires unavailable external information or capability and Sol High has documented it precisely.

At goal completion, Sol High must produce a final stabilization report containing:

• every original ISSUE.md item and disposition;
• every additional R* finding from BUG_AUDIT.md and disposition;
• branch name for each implemented fix;
• PR link/number for each implemented fix;
• commit(s) associated with each fix;
• validation performed;
• all remaining human runtime tests;
• known residual risks;
• recommended final end-to-end regression run.

────────

9. Dependency management

Sol High owns dependency ordering.

Before starting an issue:

1. identify its prerequisite issues;
2. verify prerequisites are already resolved;
3. refresh main;
4. re-read the affected code;
5. confirm the issue still exists.

Earlier fixes may invalidate later audit conclusions.

If an earlier architectural change fully resolves a later issue:

• do not create a pointless branch;
• revalidate the issue;
• classify it FIXED or STALE with evidence.

Do not process the backlog mechanically in numeric order.

Use the dependency order from BUG_AUDIT.md as the starting plan, but update it when code changes alter dependencies.

────────

10. Required implementation brief

Before delegating an issue, Sol High should prepare a concise implementation contract.

It should include:

Issue:
Classification:
Dependencies:
Relevant files/functions:
Confirmed root cause:
Required behavior:
Behavior that must remain unchanged:
Explicitly excluded work:
Required static validation:
Required runtime/manual validation:
Known risks:

Luna Max should implement against this brief, not against a vague request such as:

fix the bug

If investigation shows the root cause differs materially from the brief, Luna Max must stop the implementation and report the new evidence to Sol High before making a speculative patch.

────────

11. Implementation-agent rules

Luna Max must follow this workflow for every delegated fix.

Before editing

• confirm the active branch/base;
• confirm tracked files are clean unless the task explicitly starts from existing changes;
• inspect the relevant implementation and its callers;
• inspect relevant Steamodded/Lovely contracts when the audit depends on framework behavior;
• distinguish shared definition objects from runtime instances;
• distinguish progression slot semantics from semantic Blind category;
• determine whether delayed events, save/load, or global wrappers are involved.

While editing

• prefer the smallest correct fix;
• preserve existing public/gameplay behavior not implicated by the issue;
• avoid style-only changes;
• avoid mass renames;
• avoid unrelated cleanup;
• do not change balance unless restoring documented behavior inherently changes balance;
• do not copy external GPL or other licensed implementation code into this repository without explicit licensing review;
• add comments only when the reasoning/invariant is not obvious from code.

Before committing

Review:

git status
git diff --stat
git diff

Confirm:

• only expected files changed;
• no debug artifacts or temporary logs remain unless deliberately included;
• no unrelated behavior was modified;
• no generated/binary files were accidentally changed;
• required documentation/test plan is present when requested.

Then run applicable checks.

────────

12. Pull request requirements

Every implementation PR should include:

## Problem

What observable/source-confirmed problem is being fixed?

## Root cause

What exact current implementation caused it?

## Changes

- ...
- ...

## Behavior preserved

- ...
- ...

## Validation

- [x] Static/source validation
- [x] Applicable local checks
- [ ] Manual Balatro test required, if applicable

## Manual test plan

1. ...
2. ...

## Risk

Low / Medium / High

Explain the main regression risks.

## Known limitations

Anything not handled by this PR.

The PR description must distinguish:

• what was actually tested;
• what was only reasoned from source;
• what still requires runtime/manual verification.

Never claim Balatro runtime validation unless Balatro was actually executed.

────────

13. Sol High review rules

Sol High must independently review every delegated PR.

Do not rely solely on Luna Max’s explanation.

Review:

• the complete diff;
• surrounding functions;
• all callers/wrappers involved;
• framework contracts cited in the audit;
• issue acceptance criteria;
• save/load effects;
• delayed events;
• disabled-state semantics;
• canonical key usage;
• RNG consumption;
• Blueprint/copy behavior where relevant;
• persistence implications;
• unrelated behavior changes.

Review outcome must be one of:

APPROVE
REQUEST CHANGES
REJECT / REPLAN

Review feedback must be concrete.

Good:

src/core/battle_of_gods.lua:
candidate selection still increments bosses_used before slot commitment.
Move this mutation to the encounter commit path.

Bad:

make this more robust

If changes are requested, Luna Max updates the same branch and PR.

Sol High re-reviews the new diff.

────────

14. Review-loop limit and escalation

Normally allow up to two substantial Luna Max correction rounds.

After repeated structural review failures, Sol High should either:

1. provide a much more explicit implementation design, or
2. take over the branch and solve the issue directly.

Sol High may implement directly from the start when the issue is:

• architectural;
• highly cross-cutting;
• persistence-heavy;
• dependent on several wrapper chains;
• sensitive to framework contracts;
• likely to be more expensive to delegate than solve;
• too risky for iterative guess-and-review.

Examples likely to justify Sol High direct work:

• Battle of Gods encounter lifecycle / identity architecture;
• save/load encounter state;
• compositional Card:calculate_joker interception;
• unified Blind target/requirement calculation;
• effect ownership across disable/defeat/delayed events.

Delegation is the default, not a requirement.

────────

15. Human merge and runtime-validation policy

Agents may:

• create branches;
• commit;
• push;
• open PRs;
• review PRs.

Do not automatically merge production PRs unless the /goal environment explicitly grants that responsibility.

Where actual gameplay testing is required, code review is not sufficient.

The final acceptance path is:

agent implementation
    ↓
Sol High review
    ↓
agent-executable validation
    ↓
human Balatro test if required
    ↓
merge / final verification

If the automation environment does permit controlled merging as part of /goal, Sol High must still preserve a final queue of HUMAN_TEST_NEEDED cases and must not label them runtime-verified.

────────

16. Reality Warp invariants

These rules are especially important for this repository.

16.1 Slot semantics and semantic category are different

Do not conflate:

progression slot:
Small / Big / Boss

with:

semantic Blind category:
regular / boss / fused / showdown

Installed Steamodded uses slot semantics for progression and Blind:get_type().

Do not globally redefine Blind:get_type() to return semantic Boss.

Use explicit helpers when semantic category is needed.

16.2 Canonical Blind keys

Use canonical registered Reality Warp keys:

bl_reality_warp_*

Do not rely on localized display names or legacy b_reality_warp_* aliases for active gameplay detection.

Legacy aliases may be supported only where migration/backward compatibility requires them.

Prefer centralized helpers over repeated string comparisons.

16.3 Shared definition vs runtime Blind

Steamodded Blind definitions are shared registered objects.

In a callback such as:

calculate = function(self, blind, context)

self is typically the registered definition and blind is the active runtime Blind instance.

Do not store encounter-specific mutable state on shared definitions.

Encounter-specific state must belong to serialized run/encounter/runtime state.

16.4 UI must not create gameplay state

Localization/UI functions such as loc_vars() must read state.

They must not roll or mutate authoritative gameplay state.

Preview and active encounter data must derive from the same committed encounter state.

16.5 Disabled Blinds

Do not assume Steamodded suppresses every custom calculate() call for disabled Blinds.

Active-effect callbacks must explicitly respect runtime disabled state where required.

Cleanup events such as blind_disabled and blind_defeated must still be able to restore owned state.

Do not put an unconditional early return before required cleanup.

16.6 Delayed events

Any delayed event that permanently changes cards, Jokers, Blind target, money, hand state, or other run state must consider whether the originating encounter still owns that effect when the event executes.

When needed, capture/revalidate:

• encounter ID;
• expected Blind key;
• runtime disabled state;
• target Card/Joker identity;
• expected phase.

Do not mutate whichever global card list happens to exist later.

16.7 Cleanup ownership

Do not blindly set:

card.debuff = false

to undo a Blind-specific effect when another system may legitimately debuff the same object.

Prefer owned state/recalculation mechanisms.

A cleanup routine should undo only the state introduced by that mechanic.

16.8 Save/load

Any run-critical encounter state must survive a cold restart, not merely same-process reload.

Do not treat state surviving in G.P_BLINDS or another shared Lua object as persistence.

Avoid storing direct Card object references in serialized game state unless the serialization/reconnection contract is verified.

Prefer stable IDs/keys and reconnect on load where necessary.

16.9 Global wrappers

Reality Warp contains many global monkey patches.

Before adding a wrapper:

• find existing wrappers of the same function;
• determine wrapper load order;
• preserve all arguments;
• preserve multiple return values;
• avoid changing unrelated callers;
• avoid duplicate behavior implemented at two callback layers.

If a wrapper is replaced, verify every previous responsibility still exists.

16.10 RNG

Do not globally hijack pseudorandom() or edition polling without precise qualification.

A gameplay guarantee must not be consumed by unrelated:

• cosmetic RNG;
• shop selection;
• boss selection;
• UI randomness;
• unrelated probability rolls.

Preserve RNG API arguments and framework options.

Changes to RNG consumption can alter seeded runs and must be called out in the PR risk section.

16.11 Scoring composition

Do not replace a Joker’s original calculation result merely to add a mode bonus.

Preserve:

• original return values;
• additional/post return values;
• Blueprint compatibility;
• debuff behavior;
• side effects;
• scoring order.

Prefer compositional supported scoring effects.

16.12 Destruction/removal

Permanent card/Joker destruction should use supported removal paths and preserve relevant framework notifications.

Avoid direct dissolve/shatter shortcuts if they bypass removal callbacks relied on by other Jokers/mechanics.

Avoid double-notifying removal listeners.

────────

17. Runtime/manual testing expectations

Many Reality Warp defects cannot be fully established by static analysis.

For each applicable PR, provide exact manual scenarios.

A useful test description contains:

seed:
stake:
deck:
Ante:
Blind:
Jokers:
Familiars:
possessions:
optional mods:
steps:
expected result:
actual result:

When testing encounter lifecycle, log/observe:

slot
scheduled key
button/display key
selected key
active config key
semantic category
runtime slot flags
disabled state
encounter ID
encounter parameters
target chips

When testing permanent effects, include:

• normal enabled positive control;
• disabled at setup;
• disabled after an event is queued;
• defeat/transition;
• next encounter;
• save/reload;
• cold restart when persistence matters.

────────

18. Regression documentation

Maintain a durable regression list in:

docs/REGRESSION_TESTS.md

If the file does not exist, create it when the first fix requires a manual regression case.

Each fixed bug should gain a stable regression entry where practical.

Example:

### Helin exponent

Setup:
- base Mult: 12
- Helin power: 2

Expected:
- Helin only: 144
- Blueprint → Helin: 20,736
- Blueprint → Blueprint → Helin: 429,981,696

Do not rely only on PR descriptions for long-term regression knowledge.

────────

19. Backlog maintenance

Sol High should maintain a durable project status document if the /goal spans many PRs.

Preferred location:

docs/BUG_BACKLOG.md

Recommended fields:

## Short title

Source:
- ISSUE.md #...
- BUG_AUDIT.md R...

Classification:
Priority:
Dependencies:
State:
Branch:
PR:
Commit:
Manual test required:
Notes:

The backlog is coordination state, not a replacement for the detailed audit.

Do not silently remove findings.

If an item becomes stale/not-a-bug, record the reason.

────────

20. Initial dependency order

Use the dependency-aware ordering in BUG_AUDIT.md as the initial plan.

Broadly:

1. canonical Blind identity/contracts;
2. encounter scheduling, commits, pools, eligibility, persistence;
3. disabled effects, delayed events, state ownership and restoration;
4. target/requirement calculation and dynamic scaling;
5. compositional Joker calculation;
6. Helin;
7. draw mechanics;
8. RNG ownership;
9. remaining focused individual defects;
10. optional feature work such as consumable stacking.

This order is not immutable.

Sol High must re-evaluate it after every architectural merge.

────────

21. Known investigated non-bugs

Do not “fix” these unless new runtime/source evidence establishes a separate defect.

Black Hole + Blueprint exponent growth

Sequential exponentiation is expected.

Large growth alone is not a bug.

Perfectionism replacing another edition with Negative

Reality Warp uses a single-edition model for this behavior.

Replacement is expected unless design requirements change.

Upgrade Roulette enhancement progression

Current pre-scoring upgrade behavior, Stone special handling, and Glass terminal behavior are intentional unless new evidence establishes otherwise.

────────

22. Optional feature work

Feature work such as consumable stacking must remain separate from correctness stabilization unless explicitly promoted in priority by Sol High.

Use:

feat/...

Feature PRs must not silently include unrelated bug fixes.

Consumable stacking in particular interacts with:

• use-one semantics;
• sell-one semantics;
• save/load;
• Perkeo/copying;
• Observatory;
• weighted random selection;
• Potion Pouch / Jobs;
• Code consumable punishment.

Do not port unreviewed historical local patches blindly.

Review licensing if implementation ideas are derived from external projects such as Saturn.

────────

23. Repository hygiene

Do not commit:

• temporary screenshots unless explicitly useful documentation;
• save files;
• logs containing local paths/user data;
• generated Lovely dumps;
• editor metadata;
• unrelated binary changes;
• local test artifacts;
• credentials or tokens.

Do not modify upstream attribution or claim ownership of original Reality Warp code.

The repository currently lacks a detected license; do not add a license purporting to relicense the original project without explicit authorization.

────────

24. Failure behavior

If a task cannot be completed safely:

1. stop modifying production code;
2. preserve any useful diagnostic work;
3. report the exact reason;
4. identify what evidence is missing;
5. propose the smallest next diagnostic step.

Do not guess at a fix merely to produce a diff.

When runtime evidence contradicts the audit, runtime evidence wins, but document the discrepancy and update the backlog/audit assumptions.

────────

25. Final rule

The goal is not to maximize the number of patches.

The goal is to leave Reality Warp in a state where:

• known defects are actually resolved;
• fixes are isolated and reviewable;
• framework contracts are respected;
• save/load and lifecycle state are explicit;
• unrelated mechanics are not accidentally changed;
• remaining runtime-only uncertainties are clearly documented;
• every audited finding has an explicit disposition.

Prefer a smaller correct patch over a broad speculative refactor.
