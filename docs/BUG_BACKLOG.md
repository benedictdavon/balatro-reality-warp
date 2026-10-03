# Stabilization backlog

Base: `8d732bd3fece32d63aeda285904ce1123a211084`. Sequential Option A; each implementation branch starts from refreshed accepted main. AGENTS.md, ISSUE.md and BUG_AUDIT.md were initially untracked user-provided source documents and are tracked with this ledger. No real Balatro execution has been performed.

Terminal states describe evidence, not a runtime claim. HUMAN_TEST_NEEDED means implementation/review/local checks are complete with game tests outstanding. Candidate classifications remain provisional until revalidation.

Initial order: identity; scheduler/persistence; effect ownership; target/scoring; Joker composition; draw; RNG; focused residual checks; optional features.

## 1: Battle of Gods / Colosseum can display one Blind while a different Blind or effect is actually active

Source: ISSUE.md #1
Classification: Source-confirmed defect; revalidate before implementation
Priority: Critical
Dependencies: 18, R11
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 2: Ares / Violet Vessel sometimes behave like The Hook / Minotaur and discard two random cards

Source: ISSUE.md #2
Classification: Historical symptom requiring isolated game reproduction
Priority: Normal
Dependencies: 1, 6, 19, R10
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: See source document and dependency order; not yet implemented.

## 3: Athena can display one required poker hand and enforce another

Source: ISSUE.md #3
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 1, R1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 4: The Net can display one target rank and destroy another

Source: ISSUE.md #4
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 1, R1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 5: Godly Hubris / Blind chip requirement can differ between preview and actual combat

Source: ISSUE.md #5
Classification: Source fix independently reviewed; all agent checks pass; actual game/extension validation outstanding
Priority: High
Dependencies: 1, 18, R3
State: HUMAN_TEST_NEEDED
Branch: fix/blind-target-calculation
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/9
Commit: 8b6b0b910fb6466aade2ae2df18b7254fb3fc2c3
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Shared pure formula/native initialization hooks cover semantic Hubris, stake, showdown mult, Rod/Nectar, final cap and eligible Wall forecast; active previews read current serialized chips. Reset-only wrappers no longer scale or rebuild dynamic target. Competing shared-definition UI mutation and delayed Colosseum4000 override removed. Seven stub harnesses and exact installed Lovely pattern counts pass; actual game/number extension/conditional setup eligibility remain manual tests.

## 6: Chicot can visually disable custom bosses while their custom effects still execute

Source: ISSUE.md #6
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 18, R11
State: HUMAN_TEST_NEEDED
Branch: fix/blind-effect-ownership
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/4
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Disabled callbacks suppress penalties after source-owned cleanup. Permanent queued effects validate game/encounter/key/phase; captured targets avoid later global lists. Athena/Phone release only their SMODS sources. Thanatos uses actual showdown metadata and recalculates after refreshing expiry; Apotheosis exempts Blind restrictions without erasing other sources/expiry. Callback/event/debuff Lua stubs pass. Winning-hand queue order and actual game cleanup require human testing.

## 7: Ouroboros does not reliably enforce “always draw 3 cards” after Play or Discard

Source: ISSUE.md #7
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 1, 6, 19
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: See source document and dependency order; not yet implemented.

## 8: Helin's exponent effect can do nothing in big-number mode

Source: ISSUE.md #8
Classification: Likely unsupported scoring dispatch; verify number extension
Priority: Normal
Dependencies: R5
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: See source document and dependency order; not yet implemented.

## 9: Colosseum starting Perishable Stencils can expire, then become active again

Source: ISSUE.md #9
Classification: Historical correction with residual eligibility/ownership risk
Priority: Normal
Dependencies: 1, 18, R4
State: HUMAN_TEST_NEEDED
Branch: fix/blind-effect-ownership
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/4
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Disabled callbacks suppress penalties after source-owned cleanup. Permanent queued effects validate game/encounter/key/phase; captured targets avoid later global lists. Athena/Phone release only their SMODS sources. Thanatos uses actual showdown metadata and recalculates after refreshing expiry; Apotheosis exempts Blind restrictions without erasing other sources/expiry. Callback/event/debuff Lua stubs pass. Winning-hand queue order and actual game cleanup require human testing.

## 10: Shortcut failed a valid one-gap Straight

Source: ISSUE.md #10
Classification: Historical hand accepted by current fallback
Priority: Normal
Dependencies: R8
State: STALE
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Source trace in BUG_AUDIT.md; R8 remains independently actionable. Add detector regression checks.

## 11: Baby Mark appeared to trigger roughly ten times from one Red Seal Polychrome King

Source: ISSUE.md #11
Classification: Historical symptom requiring isolated game reproduction
Priority: Normal
Dependencies: R5
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: See source document and dependency order; not yet implemented.

## 12: Consumable stacking compatibility / UI: no clean native stacking, and early visual-only patches buried cards

Source: ISSUE.md #12
Classification: Optional requested feature
Priority: Normal
Dependencies: correctness stabilization
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Native quantity model absent. Implement only after correctness stabilization; inspect use/copy/save contracts and avoid copying external licensed code.

## 13: Dark Alchemy Tag tooltip/code probability deserves verification

Source: ISSUE.md #13
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 14
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: See source document and dependency order; not yet implemented.

## 14: Lucky One probability logic has historically been broader than the tooltip suggests

Source: ISSUE.md #14
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: none
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: See source document and dependency order; not yet implemented.

## 15: Battle-of-Gods boss usage counters can be polluted by blind rolls that are immediately overwritten

Source: ISSUE.md #15
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 16: Fused and regular boss categories overlap in the current selector

Source: ISSUE.md #16
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 17: Boss eligibility ignores or inconsistently applies `min`, `max`, and `in_pool()`

Source: ISSUE.md #17
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 18: Battle-of-Gods state has too many overlapping representations of “what Blind are we fighting?”

Source: ISSUE.md #18
Classification: Source-confirmed defect; revalidate before implementation
Priority: Critical
Dependencies: none
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 19: Potential stale/delayed boss effects should be audited after Blind changes

Source: ISSUE.md #19
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 1, R1
State: HUMAN_TEST_NEEDED
Branch: fix/blind-effect-ownership
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/4
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Disabled callbacks suppress penalties after source-owned cleanup. Permanent queued effects validate game/encounter/key/phase; captured targets avoid later global lists. Athena/Phone release only their SMODS sources. Thanatos uses actual showdown metadata and recalculates after refreshing expiry; Apotheosis exempts Blind restrictions without erasing other sources/expiry. Callback/event/debuff Lua stubs pass. Winning-hand queue order and actual game cleanup require human testing.

## 20: Consumable-stack quantity badge alignment was confusing

Source: ISSUE.md #20
Classification: Historical badge implementation absent
Priority: Normal
Dependencies: 12
State: STALE
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: No current quantity badge. Future #12 implementation must use centered representative badge.

## R1: Encounter parameters are not persisted and shared definitions survive runs

Source: BUG_AUDIT.md R1
Classification: Source-confirmed defect; revalidate before implementation
Priority: Critical
Dependencies: 1, 18
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## R2: Iron Maiden hand size is not restored on ordinary defeat; disable restoration can repeat

Source: BUG_AUDIT.md R2
Classification: Source-confirmed defect; implementation reviewed; real-game validation pending
Priority: Normal
Dependencies: 6, 19 (effect ownership PR #4 accepted)
State: HUMAN_TEST_NEEDED
Branch: fix/iron-maiden-restoration
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/5
Commit: 2155e8ccf5f5f6dd30cc4ad1df7d5739eaf10b79
Manual test requirement: Required for gameplay/save/load; Iron Maiden hand size, Chicot setup/late disable, Obelisk/Leviathan remaining-resource refunds, zero-resource setups, defeat, next encounter, and cold restart are specified in REGRESSION_TESTS.md.
Notes: Registered callbacks revalidated on accepted main 8e4c2bf. Setup markers and serializable applied deltas are stored on blind.effect; cleanup clears before refund. Sol High approved the implementation at this commit and independently reran the Lua 5.1 suite and diff check. No Balatro runtime/cold-restart test was run. Pre-fix Iron Maiden saves lack an ownership ledger and cannot be safely inferred; new saves carry it.

## R3: Reset-only Blind refresh compounds or erases target scaling

Source: BUG_AUDIT.md R3
Classification: Source fix independently reviewed; all agent checks pass; actual game/extension validation outstanding
Priority: High
Dependencies: 1, 18
State: HUMAN_TEST_NEEDED
Branch: fix/blind-target-calculation
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/9
Commit: 8b6b0b910fb6466aade2ae2df18b7254fb3fc2c3
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Shared pure formula/native initialization hooks cover semantic Hubris, stake, showdown mult, Rod/Nectar, final cap and eligible Wall forecast; active previews read current serialized chips. Reset-only wrappers no longer scale or rebuild dynamic target. Competing shared-definition UI mutation and delayed Colosseum4000 override removed. Seven stub harnesses and exact installed Lovely pattern counts pass; actual game/number extension/conditional setup eligibility remain manual tests.

## R4: Blanket undebuff erases other systems' restrictions

Source: BUG_AUDIT.md R4
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 6, 19
State: HUMAN_TEST_NEEDED
Branch: fix/blind-effect-ownership
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/4
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Disabled callbacks suppress penalties after source-owned cleanup. Permanent queued effects validate game/encounter/key/phase; captured targets avoid later global lists. Athena/Phone release only their SMODS sources. Thanatos uses actual showdown metadata and recalculates after refreshing expiry; Apotheosis exempts Blind restrictions without erasing other sources/expiry. Callback/event/debuff Lua stubs pass. Winning-hand queue order and actual game cleanup require human testing.

## R5: Apotheosis/Exalted interception replaces normal Joker calculation

Source: BUG_AUDIT.md R5
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 18
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: See source document and dependency order; not yet implemented.

## R6: Arrow rank lookup uses invalid vanilla card keys

Source: BUG_AUDIT.md R6
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 6
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: See source document and dependency order; not yet implemented.

## R7: Direct boss dissolution bypasses destruction-notification bookkeeping

Source: BUG_AUDIT.md R7
Classification: Source-confirmed installed-framework contract defect; static/callback checks only, gameplay remains unverified
Priority: Normal
Dependencies: #6/#19/R4 effect ownership foundation and R2
State: HUMAN_TEST_NEEDED
Branch: fix/blind-destruction-notifications
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/6
Commit: 333c3fd0c27009a540369e449b22d437f3dbfef3 (initial implementation); 64e7576eeb9b103dfee2bd8936a5c7071fc80321 (Eternal eligibility correction)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Ares, Net, and Hades submit deduplicated snapshots with already-removing cards excluded to `SMODS.destroy_cards` once per batch; the API alone checks Eternal eligibility and sends removal notifications/runs normal hooks. Ares permanence commits in `context.after`; only feedback remains delayed. See the R7 bounded brief and REGRESSION_TESTS.md. No Balatro runtime/save test has been run.

## R8: get_straight wrapper discards modern API parameters

Source: BUG_AUDIT.md R8
Classification: Source-confirmed compatibility defect; gameplay remains HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: none
State: IN_PROGRESS
Branch: fix/straight-api-forwarding
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: The current wrapper accepts only `hand`, dropping the installed four-argument detector contract and all trailing values; its numeric fallback bypasses custom rank graphs. R8 restores native/helper forwarding and retains Colorful Street through the framework helpers. The focused Lua 5.1 source regression passes; independent review and real card scoring remain pending.

## R9: Chronos and Guillotine each run at two scoring stages; Void checks before queued score addition

Source: BUG_AUDIT.md R9
Classification: Source-confirmed duplicate `modify_hand`/final-score paths; source-confirmed queued-score timing for Void, with game-event behavior requiring manual confirmation.
Priority: Normal
Dependencies: 5, R3
State: HUMAN_TEST_NEEDED
Branch: fix/blind-final-scoring
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/10
Commit: 0b6204ed03f92c191fa3ef39bd6ca3efd8709ba4 (implementation); fcf63a9 (bounded brief)
Manual test requirement: Required; use the final scoring stage ownership fixture in docs/REGRESSION_TESTS.md for Chronos, Guillotine, Void, Chicot, Plasma, Blueprint, cold restart and the actual number extension.
Notes: Source fix independently reviewed APPROVE by Sol High; all Lua5.1 compilation, eight stub harnesses, TOML/payload/pattern checks and git diff --check pass. No Balatro execution is claimed. Current accepted base main `50babb21ba2297437510ecf0ea5eb025fb5b2504` confirms native `modify_hand` precedes Jokers and final Back scoring; native sets `SMODS.last_hand_score` before `context.after`, while its chip ease remains queued. Bounded implementation contract is in `docs/IMPLEMENTATION_BRIEFS.md`; actual gameplay/score-event behavior still needs manual validation.

## R10: Possession draw/discard callbacks can issue repeated or duplicate transfers

Source: BUG_AUDIT.md R10
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 7
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: See source document and dependency order; not yet implemented.

## R11: Canonical Blind keys are missing from several active-effect detectors

Source: BUG_AUDIT.md R11
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 18
State: HUMAN_TEST_NEEDED
Branch: fix/blind-identity-contracts
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/2
Commit: See PR head/merge commit (recorded in final report)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Canonical Mountain/Doppelganger/Pincer detectors restored. Pincer unlock recalculates debuffs once and exempts Chicot; UI cleanup no longer erases Doppelganger state. Lua 5.1 compilation and identity/disabled/unlock harness passed; real game queue pending.

## R12: Free reroll refunds by assigning dollars before delayed payment settles

Source: BUG_AUDIT.md R12
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 1
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Scheduler now grants one allowance per Ante. Payment/UI defect remains actionable for its own PR.

## R13: The Code punishes one consumable twice and bypasses Eternal filtering

Source: BUG_AUDIT.md R13
Classification: Source fix independently reviewed; agent checks pass; real-game validation outstanding
Priority: Normal
Dependencies: 6, 19, R7 (accepted)
State: HUMAN_TEST_NEEDED
Branch: fix/code-consumable-punishment
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/7
Commit: 8fc3d43fa92ace3818cf03ad7ca8bda805ed7d83
Manual test requirement: Code UI/direct/Pouch, all-Eternal, Doctor Jo, Chicot and native event counts are specified in REGRESSION_TESTS.md; real game remains unrun.
Notes: One Card use-method punishment, canonical identity and captured encounter ownership; duplicate Blind calculate removed. Pouch now uses the method and emits one ordinary listener context. Framework Eternal eligibility excludes invalid candidates with no fallback. Actual consumption arguments/returns compose through all three surrounding wrappers. External definition-only calls require the Card method contract.

## R14: Ante-history wrapper marks the current hand as previously played before evaluation

Source: BUG_AUDIT.md R14
Classification: STALE on the verified installed framework stack; the alleged bare-global hook is dormant
Priority: Normal
Dependencies: Accepted main `592b30092d611a7b78694c21fff7d1b68e86a715`; installed Lovely/Steamodded source inspected
State: STALE
Branch: docs/ante-history-disposition
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/8
Commit: e4c4fc18c650cab22967ee11f709f83ea6d486b6 (documentation-only disposition).
Manual test requirement: No gameplay validation was run. The optional first-play/repeat-play confirmation fixture is recorded in REGRESSION_TESTS.md.
Notes: The audit assumed a bare global `evaluate_play` alias. On the accepted main, Reality Warp's guarded hook captures that absent global (`src/core/utils.lua:7817–7829`), and repository/framework/Lovely-patch search found no alias bridge. The installed route calls and defines `G.FUNCS.evaluate_play` (`../lovely/dump/functions/state_events.lua:526, 586`); it sends `context.after` first, then queues `played_this_ante` marking for all played cards (`:908–917`). The separate namespaced wrapper (`src/core/utils.lua:979–1006`) tracks unlock counts but does not set card history. Possessed Pillar (`src/core/botg_possession.lua:89–99`) and Obelisk (`src/blinds/fused_blinds.lua:198–203`) read the native flag as prior-play history. The `ease_ante` clear wrapper (`src/core/utils.lua:7831–7842`) remains unchanged. This stale disposition is based on source tracing, not Balatro runtime verification.

## A: Black Hole + Blueprint

Source: ISSUE.md and BUG_AUDIT.md investigated non-bugs
Classification: Intentional behavior
Priority: Control
Dependencies: none
State: NOT_A_BUG
Branch: —
PR: —
Commit: —
Manual test requirement: Preserve as regression controls.
Notes: Sequential exponentiation with intermediate flooring is intentional; secret.lua Black Hole calculate.

## B: Perfectionism edition replacement

Source: ISSUE.md and BUG_AUDIT.md investigated non-bugs
Classification: Intentional behavior
Priority: Control
Dependencies: none
State: NOT_A_BUG
Branch: —
PR: —
Commit: —
Manual test requirement: Preserve as regression controls.
Notes: set_edition uses single-edition replacement; rare.lua Perfectionism.

## C: Upgrade Roulette

Source: ISSUE.md and BUG_AUDIT.md investigated non-bugs
Classification: Intentional behavior
Priority: Control
Dependencies: none
State: NOT_A_BUG
Branch: —
PR: —
Commit: —
Manual test requirement: Preserve as regression controls.
Notes: common.lua before context upgrades scoring enhanced cards; Stone special route and Glass terminal behavior are intentional.
