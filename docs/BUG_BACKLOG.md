# Stabilization backlog

Base: `8d732bd3fece32d63aeda285904ce1123a211084`. Sequential Option A; each implementation branch starts from refreshed accepted main. AGENTS.md, ISSUE.md and BUG_AUDIT.md were initially untracked user-provided source documents and are tracked with this ledger. No real Balatro execution has been performed.

Terminal states describe evidence, not a runtime claim. HUMAN_TEST_NEEDED means implementation/review/local checks are complete with game tests outstanding. Candidate classifications remain provisional until revalidation.

Initial order: identity; scheduler/persistence; effect ownership; target/scoring; Joker composition; draw; RNG; focused residual checks; optional features.

Coordination snapshot: accepted main/origin/main f863d0c2c543c4befa481803a581847ca8fe7274. Unpublished local APPROVE is distinct from accepted-main merge. All 34 original statuses/branch hashes/PRs, three genuine publication-dependent blocks, exact human queue and new local N1–N6 findings are consolidated in STABILIZATION_STATUS.md. No Balatro execution is claimed. POST source remains preserved/untracked for the subsequent phase.

## 1: Battle of Gods / Colosseum can display one Blind while a different Blind or effect is actually active

Source: ISSUE.md #1
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Critical
Dependencies: 18, R11
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: a8ff1d020e6f5df9c2cb12a468d90f917e27cfee (reviewed head); 43a90f472b2f251d75dd73175eb9b7dd19722b21 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 2: Ares / Violet Vessel sometimes behave like The Hook / Minotaur and discard two random cards

Source: ISSUE.md #2
Classification: Genuine unavailable publication/accepted-prerequisite dependency; source evidence retained
Priority: Normal
Dependencies: 1, 6, 19, R10
State: BLOCKED
Branch: —
PR: —
Commit: —
Manual test requirement: Exact isolated procedure is in STABILIZATION_STATUS.md; formal branch waits for accepted prerequisite.
Notes: Formal isolated symptom validation remains BLOCKED because reviewed R10 fix/round-action-draws cannot be published/accepted without the existing pending human publication approval. Encounter/effect prerequisites are merged. Do not implement a guessed Ares/Violet suppression or start a dependency branch on unpublished code. Required game isolation is in STABILIZATION_STATUS.md.

## 3: Athena can display one required poker hand and enforce another

Source: ISSUE.md #3
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 1, R1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: a8ff1d020e6f5df9c2cb12a468d90f917e27cfee (reviewed head); 43a90f472b2f251d75dd73175eb9b7dd19722b21 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 4: The Net can display one target rank and destroy another

Source: ISSUE.md #4
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 1, R1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: a8ff1d020e6f5df9c2cb12a468d90f917e27cfee (reviewed head); 43a90f472b2f251d75dd73175eb9b7dd19722b21 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 5: Godly Hubris / Blind chip requirement can differ between preview and actual combat

Source: ISSUE.md #5
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: High
Dependencies: 1, 18, R3
State: HUMAN_TEST_NEEDED
Branch: fix/blind-target-calculation
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/9
Commit: 8b6b0b910fb6466aade2ae2df18b7254fb3fc2c3 (implementation/disposition); 187e53991c6ff4e76713fdde7412924fd67e4930 (reviewed head); 50babb21ba2297437510ecf0ea5eb025fb5b2504 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: Shared pure formula/native initialization hooks cover semantic Hubris, stake, showdown mult, Rod/Nectar, final cap and eligible Wall forecast; active previews read current serialized chips. Reset-only wrappers no longer scale or rebuild dynamic target. Competing shared-definition UI mutation and delayed Colosseum4000 override removed. Seven stub harnesses and exact installed Lovely pattern counts pass; actual game/number extension/conditional setup eligibility remain manual tests.

## 6: Chicot can visually disable custom bosses while their custom effects still execute

Source: ISSUE.md #6
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 18, R11
State: HUMAN_TEST_NEEDED
Branch: fix/blind-effect-ownership
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/4
Commit: e3e3d49ef65836945eec43f8bbb70a4ed581daf9 (reviewed head); 8e4c2bfad92fc0572dcdb289608895d2f452e4ac (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: Disabled callbacks suppress penalties after source-owned cleanup. Permanent queued effects validate game/encounter/key/phase; captured targets avoid later global lists. Athena/Phone release only their SMODS sources. Thanatos uses actual showdown metadata and recalculates after refreshing expiry; Apotheosis exempts Blind restrictions without erasing other sources/expiry. Callback/event/debuff Lua stubs pass. Winning-hand queue order and actual game cleanup require human testing.

## 7: Ouroboros does not reliably enforce “always draw 3 cards” after Play or Discard

Source: ISSUE.md #7
Classification: Source fix independently reviewed and locally approved; actual game validation outstanding
Priority: Normal
Dependencies: 1, 6, 19
State: HUMAN_TEST_NEEDED
Branch: fix/round-action-draws
PR: — (unpublished; required approval pending)
Commit: 99618014e3ce21a30b0c9b04f632c652343b082d; 0b386690550d3126916492fb42e4dc91d62dcf43; 7c1cd917fbbc80c74e7f3197bbefd0e31ac86995
Manual test requirement: Required for gameplay/save/load; exact accumulated procedure is in REGRESSION_TESTS.md.
Notes: Local APPROVE; no public PR or accepted-main merge claimed. Local implementation, Sol High source review and independent Luna approval complete. All repository Lua/TOML/owned pattern checks and nine harnesses pass through the independent runner (the accepted-main N3 aggregate-runner limitation is documented). One review correction makes draw restriction runtime-owned so disabled Ouroboros alone restores native auto-refill; live Serpent remains independent. No PR/merge exists; publication awaits required human authorization, and accepted main still contains these defects. Revalidated against refreshed accepted main f863d0c; exact physical-card count requires an owned native selection boundary as well as context flags. Shared draw/transfer contract with R10 in IMPLEMENTATION_BRIEFS.md. Independent of local reviewed R5 and R6; publication withheld pending the required human confirmation. New Familiar extra-draw finding N1 is documented on local Joker-composition branch and excluded here.

## 8: Helin's exponent effect can do nothing in big-number mode

Source: ISSUE.md #8
Classification: Genuine unavailable publication/accepted-prerequisite dependency; source evidence retained
Priority: Normal
Dependencies: R5
State: BLOCKED
Branch: —
PR: —
Commit: —
Manual test requirement: Exact isolated procedure is in STABILIZATION_STATUS.md; formal branch waits for accepted prerequisite.
Notes: BLOCKED on publication and acceptance of R5 fix/joker-calculation-composition under the existing pending approval. Read-only actual installed Amulet effect/individual scoring/Omega checks contradict the unsupported e_mult-key theory (12 -> 144 -> 20736 -> 429981696); formal original-calculation/mode/Blueprint/cold validation must follow accepted R5. No balance/dispatch rewrite or dependent branch has been started.

## 9: Colosseum starting Perishable Stencils can expire, then become active again

Source: ISSUE.md #9
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 1, 18, R4
State: HUMAN_TEST_NEEDED
Branch: fix/blind-effect-ownership
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/4
Commit: e3e3d49ef65836945eec43f8bbb70a4ed581daf9 (reviewed head); 8e4c2bfad92fc0572dcdb289608895d2f452e4ac (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
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
Manual test requirement: Required for gameplay/save/load; exact accumulated procedure is in REGRESSION_TESTS.md.
Notes: Source trace in BUG_AUDIT.md; R8 remains independently actionable. Add detector regression checks.

## 11: Baby Mark appeared to trigger roughly ten times from one Red Seal Polychrome King

Source: ISSUE.md #11
Classification: No Mark-generated repetition is source-confirmed; the historical symptom remains HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: Accepted encounter/effect contracts on main f863d0c2c543c4befa481803a581847ca8fe7274. R5 is not a prerequisite for this isolated `individual` callback: Baby Mark's wrapper path and the final `joker_main` composer are separate. Combined mode integration remains in the human test queue.
State: HUMAN_TEST_NEEDED
Branch: docs/baby-mark-retrigger-validation
PR: — (unpublished; required approval pending)
Commit: 74e5961fc2407d6c14ed477e12af05308e0d6eed
Manual test requirement: Required to resolve the historical ~ten-message report; exact isolated procedure is in REGRESSION_TESTS.md.
Notes: Local APPROVE; no public PR or accepted-main merge claimed. Current Mark code returns XMult for `context.individual` on a scored face card and returns no `repetitions`. Installed `SMODS.score_card` owns repeated scoring passes; Red Seal supplies one repeat and Polychrome supplies an XMult edition effect. The Familiar scoring area wrapper checks for the same area before appending it. A source-extracted loop/callback harness covers these contracts but cannot recreate Balatro UI callbacks, optional mod dispatch or the reported run. Do not suppress Mark on legitimate repeated evaluations.

## 12: Consumable stacking compatibility / UI: no clean native stacking, and early visual-only patches buried cards

Source: ISSUE.md #12
Classification: NOT_A_BUG on current main; optional feature gap, with historical local implementations absent
Priority: Optional
Dependencies: None for this source-only disposition; any future feature waits for correctness stabilization
State: NOT_A_BUG
Branch: docs/consumable-stacking-disposition
PR: — (documentation candidate unpublished; required approval pending)
Commit: c6c78485bb752df26e8347c313465875b93b0548 (source disposition; Sol High APPROVE)
Manual test requirement: None for the source-only disposition. Optional baseline confirmation and future feature acceptance tests are in REGRESSION_TESTS.md.
Notes: Current Reality Warp and installed framework use separate real Card objects; no quantity/representative/split-use/save model or local v1–v6 patch is present. The old visual-only buried-card behavior cannot execute in this checkout. Potion Pouch is separate serialized storage for up to six potions, and Cauldron consumes two real cards into a recipe result; neither is stacking. This closes the reported current-main defect claim without implementing the requested optional feature. Preserve A/B/C controls.

## 13: Dark Alchemy Tag tooltip/code probability deserves verification

Source: ISSUE.md #13
Classification: Genuine unavailable publication/accepted-prerequisite dependency; source evidence retained
Priority: Normal
Dependencies: 14
State: BLOCKED
Branch: —
PR: —
Commit: —
Manual test requirement: Exact isolated procedure is in STABILIZATION_STATUS.md; formal branch waits for accepted prerequisite.
Notes: BLOCKED on publication and acceptance of #14 fix/lucky-one-rng under the existing pending approval. Read-only analysis found overlapping 3% paths plus native baseline, approximately 0.060846 versus 0.003, not 10x. Supported edition options/no_neg, first-card timing and one-sample semantics need their own bounded branch after native RNG ownership is restored on accepted main. No dependency branch has been started.

## 14: Lucky One probability logic has historically been broader than the tooltip suggests

Source: ISSUE.md #14
Classification: Source fix independently reviewed and locally approved; actual game validation outstanding
Priority: Normal
Dependencies: none
State: HUMAN_TEST_NEEDED
Branch: fix/lucky-one-rng
PR: — (unpublished; required approval pending)
Commit: c53fffc6a9fac38f2a2816b3e9359cd706e54bb3 (implementation); 305ad622a5bcf03dab0498be6e8a4f88abad76b2 (unowned preview correction); 288e6ba4720326f4189aaad41ed061d4d98f88eb (fixed Echo/Miner inventory correction)
Manual test requirement: Exact seeded Club/token, typed probability, UI/simulation, end-round and cold-restart cases are in REGRESSION_TESTS.md; real game remains unrun.
Notes: Local APPROVE; no public PR or accepted-main merge claimed. Sol High implemented the cross-cutting ownership fix; Luna Max independently reviewed and approved immutable head 288e6ba4720326f4189aaad41ed061d4d98f88eb after concrete corrections. Root complete-diff/self-review and all nine harnesses, Lua/TOML/four Lovely boundaries, fully applied/mixed/duplicate fixture checks and installed Omega checks pass. Global pseudorandom stays native. Serialized per-card charges and private result/reservation scopes preserve copy/simulation/disabled/end-round semantics. Base remains accepted main f863d0c2c543c4befa481803a581847ca8fe7274; no pending independent fix imported. Unpublished: existing automatic publication review rejection still requires the pending explicit approval, so no PR or main acceptance is claimed. Hypnotist cleanup remains separate local N6.

## 15: Battle-of-Gods boss usage counters can be polluted by blind rolls that are immediately overwritten

Source: ISSUE.md #15
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: a8ff1d020e6f5df9c2cb12a468d90f917e27cfee (reviewed head); 43a90f472b2f251d75dd73175eb9b7dd19722b21 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 16: Fused and regular boss categories overlap in the current selector

Source: ISSUE.md #16
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: a8ff1d020e6f5df9c2cb12a468d90f917e27cfee (reviewed head); 43a90f472b2f251d75dd73175eb9b7dd19722b21 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 17: Boss eligibility ignores or inconsistently applies `min`, `max`, and `in_pool()`

Source: ISSUE.md #17
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 1
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: a8ff1d020e6f5df9c2cb12a468d90f917e27cfee (reviewed head); 43a90f472b2f251d75dd73175eb9b7dd19722b21 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 18: Battle-of-Gods state has too many overlapping representations of “what Blind are we fighting?”

Source: ISSUE.md #18
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Critical
Dependencies: none
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: a8ff1d020e6f5df9c2cb12a468d90f917e27cfee (reviewed head); 43a90f472b2f251d75dd73175eb9b7dd19722b21 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## 19: Potential stale/delayed boss effects should be audited after Blind changes

Source: ISSUE.md #19
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 1, R1
State: HUMAN_TEST_NEEDED
Branch: fix/blind-effect-ownership
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/4
Commit: e3e3d49ef65836945eec43f8bbb70a4ed581daf9 (reviewed head); 8e4c2bfad92fc0572dcdb289608895d2f452e4ac (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: Disabled callbacks suppress penalties after source-owned cleanup. Permanent queued effects validate game/encounter/key/phase; captured targets avoid later global lists. Athena/Phone release only their SMODS sources. Thanatos uses actual showdown metadata and recalculates after refreshing expiry; Apotheosis exempts Blind restrictions without erasing other sources/expiry. Callback/event/debuff Lua stubs pass. Winning-hand queue order and actual game cleanup require human testing.

## 20: Consumable-stack quantity badge alignment was confusing

Source: ISSUE.md #20
Classification: STALE; historical local-v6 badge implementation absent from current main
Priority: Cosmetic
Dependencies: 12 only if a separate stacking feature is implemented
State: STALE
Branch: —
PR: —
Commit: —
Manual test requirement: None while no quantity badge exists. If stacking is implemented later, test quantities 2/10/100 at normal, hover, and drag scales with adjacent stacks, hitboxes, and controller focus.
Notes: Current source has no representative quantity badge or local-v6 placement code. The historical top-right to top-center correction cannot be reproduced here; this label is stale on current main, not a verified fix to Reality Warp.

## R1: Encounter parameters are not persisted and shared definitions survive runs

Source: BUG_AUDIT.md R1
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Critical
Dependencies: 1, 18
State: HUMAN_TEST_NEEDED
Branch: fix/botg-encounter-lifecycle
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/3
Commit: a8ff1d020e6f5df9c2cb12a468d90f917e27cfee (reviewed head); 43a90f472b2f251d75dd73175eb9b7dd19722b21 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: One scheduler/commit path, disjoint eligible pools and serialized slot/active parameters; canonical selected identity is retained on defeat. Athena/Net read committed parameters; Hades flag uses runtime effect; Doppelganger resolves saved sort_id. Lua 5.1 and schedule/persistence stubs passed. Old saves with missing target data use marked Pair/Ace migration defaults; cold Balatro verification remains pending.

## R2: Iron Maiden hand size is not restored on ordinary defeat; disable restoration can repeat

Source: BUG_AUDIT.md R2
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 6, 19 (effect ownership PR #4 accepted)
State: HUMAN_TEST_NEEDED
Branch: fix/iron-maiden-restoration
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/5
Commit: 2155e8ccf5f5f6dd30cc4ad1df7d5739eaf10b79 (implementation/disposition); 1d261e97ea18c1b7b7fba1c20fb804dbff9174af (reviewed head); ae9dd607cf13779804f319f3bbfed732d1d0d44e (accepted merge)
Manual test requirement: Required for gameplay/save/load; Iron Maiden hand size, Chicot setup/late disable, Obelisk/Leviathan remaining-resource refunds, zero-resource setups, defeat, next encounter, and cold restart are specified in REGRESSION_TESTS.md.
Notes: Registered callbacks revalidated on accepted main 8e4c2bf. Setup markers and serializable applied deltas are stored on blind.effect; cleanup clears before refund. Sol High approved the implementation at this commit and independently reran the Lua 5.1 suite and diff check. No Balatro runtime/cold-restart test was run. Pre-fix Iron Maiden saves lack an ownership ledger and cannot be safely inferred; new saves carry it.

## R3: Reset-only Blind refresh compounds or erases target scaling

Source: BUG_AUDIT.md R3
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: High
Dependencies: 1, 18
State: HUMAN_TEST_NEEDED
Branch: fix/blind-target-calculation
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/9
Commit: 8b6b0b910fb6466aade2ae2df18b7254fb3fc2c3 (implementation/disposition); 187e53991c6ff4e76713fdde7412924fd67e4930 (reviewed head); 50babb21ba2297437510ecf0ea5eb025fb5b2504 (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: Shared pure formula/native initialization hooks cover semantic Hubris, stake, showdown mult, Rod/Nectar, final cap and eligible Wall forecast; active previews read current serialized chips. Reset-only wrappers no longer scale or rebuild dynamic target. Competing shared-definition UI mutation and delayed Colosseum4000 override removed. Seven stub harnesses and exact installed Lovely pattern counts pass; actual game/number extension/conditional setup eligibility remain manual tests.

## R4: Blanket undebuff erases other systems' restrictions

Source: BUG_AUDIT.md R4
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 6, 19
State: HUMAN_TEST_NEEDED
Branch: fix/blind-effect-ownership
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/4
Commit: e3e3d49ef65836945eec43f8bbb70a4ed581daf9 (reviewed head); 8e4c2bfad92fc0572dcdb289608895d2f452e4ac (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: Disabled callbacks suppress penalties after source-owned cleanup. Permanent queued effects validate game/encounter/key/phase; captured targets avoid later global lists. Athena/Phone release only their SMODS sources. Thanatos uses actual showdown metadata and recalculates after refreshing expiry; Apotheosis exempts Blind restrictions without erasing other sources/expiry. Callback/event/debuff Lua stubs pass. Winning-hand queue order and actual game cleanup require human testing.

## R5: Apotheosis/Exalted interception replaces normal Joker calculation

Source: BUG_AUDIT.md R5
Classification: Source fix independently reviewed and locally approved; actual game validation outstanding
Priority: Normal
Dependencies: 18
State: HUMAN_TEST_NEEDED
Branch: fix/joker-calculation-composition
PR: — (unpublished; required approval pending)
Commit: 62a4cf10945c28580920720c90e51af931a4ef85; correction eadc076a1f61c2db1085bc95a10afe888c83e3c2
Manual test requirement: Required for gameplay/save/load; exact accumulated procedure is in REGRESSION_TESTS.md.
Notes: Local APPROVE; no public PR or accepted-main merge claimed. Local source implementation and independent Luna review are complete; nine harnesses and native patch-state positive/negative checks pass. One review correction normalizes supported true removal sentinels before composition. This branch is unmerged and has no PR; accepted main still contains the issue. Revalidated against accepted main f863d0c; bounded architectural contract in IMPLEMENTATION_BRIEFS.md. Independent of pending local Arrow branch. Full chain includes the outer Potion wrapper omitted by the audit map. Publication awaits the explicit confirmation requested after automatic review required it.

## R6: Arrow rank lookup uses invalid vanilla card keys

Source: BUG_AUDIT.md R6
Classification: Source-confirmed invalid vanilla rank-key lookup; gameplay remains HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: Accepted canonical identity and disabled-effect contracts (PR2/4); current scoring-stage main (PR10)
State: HUMAN_TEST_NEEDED
Branch: fix/arrow-rank-mapping
PR: — (unpublished; required approval pending)
Commit: 31015cf76b9637e6ddcce757b1528ce07e81690e (implementation and locally approved head)
Manual test requirement: Required for gameplay; exact accumulated procedure is in REGRESSION_TESTS.md.
Notes: Local APPROVE; no public PR or accepted-main merge claimed. `SMODS.modify_rank` follows registered `prev`/`prev_behavior` and `SMODS.change_base` resolves registered suit/rank `card_key`s. The current Arrow callback manually constructs invalid face/numeric card keys. Preserve registered custom-rank behavior and compare base rank before/after for feedback; actual gameplay remains unverified. The local fix uses the native previous-rank helper with live ownership, disabled and actual-action dedup guards; full source and focused harness review approved it.

## R7: Direct boss dissolution bypasses destruction-notification bookkeeping

Source: BUG_AUDIT.md R7
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: #6/#19/R4 effect ownership foundation and R2
State: HUMAN_TEST_NEEDED
Branch: fix/blind-destruction-notifications
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/6
Commit: 333c3fd0c27009a540369e449b22d437f3dbfef3 (implementation/disposition); 0ed19edc31853dc6c19965adefccf3a8909b929b (reviewed head); ce82699d5c9d5ca75437d56e416129cb7d7001e2 (accepted merge); 64e7576eeb9b103dfee2bd8936a5c7071fc80321 (correction)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: Ares, Net, and Hades submit deduplicated snapshots with already-removing cards excluded to `SMODS.destroy_cards` once per batch; the API alone checks Eternal eligibility and sends removal notifications/runs normal hooks. Ares permanence commits in `context.after`; only feedback remains delayed. See the R7 bounded brief and REGRESSION_TESTS.md. No Balatro runtime/save test has been run.

## R8: get_straight wrapper discards modern API parameters

Source: BUG_AUDIT.md R8
Classification: Source-confirmed compatibility defect; gameplay remains HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: none
State: HUMAN_TEST_NEEDED
Branch: fix/straight-api-forwarding
PR: — (unpublished; required approval pending)
Commit: 19b60afda787c64d6da37de9ea43923d1893c8dc (implementation)
Manual test requirement: Required for gameplay/save/load; exact accumulated procedure is in REGRESSION_TESTS.md.
Notes: Local APPROVE; no public PR or accepted-main merge claimed. The current wrapper accepts only `hand`, dropping the installed four-argument detector contract and all trailing values; its numeric fallback bypasses custom rank graphs. R8 restores native/helper forwarding and retains Colorful Street through the framework helpers. Sol High independently reviewed the complete immutable diff and surrounding/native dispatch contracts: APPROVE. All repository Lua5.1 compilation, TOML/payload and exact original-or-applied installed dump checks, nine harnesses and git diff --check pass. No Balatro execution is claimed. The original tests/run.py rejects the already-applied target payloads (local N3 repair is pending in the separate R5 branch); the independent read-only checker passed. Real card scoring, classification and cold restart remain pending; main is still f863d0c and has not received this fix.

## R9: Chronos and Guillotine each run at two scoring stages; Void checks before queued score addition

Source: BUG_AUDIT.md R9
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 5, R3
State: HUMAN_TEST_NEEDED
Branch: fix/blind-final-scoring
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/10
Commit: 0b6204ed03f92c191fa3ef39bd6ca3efd8709ba4 (implementation/disposition); 7577bfdd364cd12ca4b982ac70d6ab9740921328 (reviewed head); f863d0c2c543c4befa481803a581847ca8fe7274 (accepted merge)
Manual test requirement: Required; use the final scoring stage ownership fixture in docs/REGRESSION_TESTS.md for Chronos, Guillotine, Void, Chicot, Plasma, Blueprint, cold restart and the actual number extension.
Notes: Source fix independently reviewed APPROVE by Sol High; all Lua5.1 compilation, eight stub harnesses, TOML/payload/pattern checks and git diff --check pass. No Balatro execution is claimed. Current accepted base main `50babb21ba2297437510ecf0ea5eb025fb5b2504` confirms native `modify_hand` precedes Jokers and final Back scoring; native sets `SMODS.last_hand_score` before `context.after`, while its chip ease remains queued. Bounded implementation contract is in `docs/IMPLEMENTATION_BRIEFS.md`; actual gameplay/score-event behavior still needs manual validation.

## R10: Possession draw/discard callbacks can issue repeated or duplicate transfers

Source: BUG_AUDIT.md R10
Classification: Source fix independently reviewed and locally approved; actual game validation outstanding
Priority: Normal
Dependencies: 7
State: HUMAN_TEST_NEEDED
Branch: fix/round-action-draws
PR: — (unpublished; required approval pending)
Commit: 99618014e3ce21a30b0c9b04f632c652343b082d; 0b386690550d3126916492fb42e4dc91d62dcf43; 7c1cd917fbbc80c74e7f3197bbefd0e31ac86995
Manual test requirement: Required for gameplay/save/load; exact accumulated procedure is in REGRESSION_TESTS.md.
Notes: Local APPROVE; no public PR or accepted-main merge claimed. Local implementation, Sol High source review and independent Luna approval complete. All repository Lua/TOML/owned pattern checks and nine harnesses pass through the independent runner (the accepted-main N3 aggregate-runner limitation is documented). One review correction makes draw restriction runtime-owned so disabled Ouroboros alone restores native auto-refill; live Serpent remains independent. No PR/merge exists; publication awaits required human authorization, and accepted main still contains these defects. Revalidated against refreshed accepted main f863d0c; exact physical-card count requires an owned native selection boundary as well as context flags. Shared draw/transfer contract with R10 in IMPLEMENTATION_BRIEFS.md. Independent of local reviewed R5 and R6; publication withheld pending the required human confirmation. New Familiar extra-draw finding N1 is documented on local Joker-composition branch and excluded here.

## R11: Canonical Blind keys are missing from several active-effect detectors

Source: BUG_AUDIT.md R11
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 18
State: HUMAN_TEST_NEEDED
Branch: fix/blind-identity-contracts
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/2
Commit: a2f04ca90122ad87c3b1acbcd871b522cab262f0 (reviewed head); 1afc7e590fa84695938b1936cd0e7b90fa4ae93e (accepted merge)
Manual test requirement: Required for gameplay/save/load; accumulated exact procedures are in REGRESSION_TESTS.md and STABILIZATION_STATUS.md.
Notes: Canonical Mountain/Doppelganger/Pincer detectors restored. Pincer unlock recalculates debuffs once and exempts Chicot; UI cleanup no longer erases Doppelganger state. Lua 5.1 compilation and identity/disabled/unlock harness passed; real game queue pending.

## R12: Free reroll refunds by assigning dollars before delayed payment settles

Source: BUG_AUDIT.md R12
Classification: Source-confirmed delayed-fee/UI allowance defect; gameplay remains HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: Accepted encounter scheduling (PR3), canonical identity and target fixes on main f863d0c2c543c4befa481803a581847ca8fe7274
State: HUMAN_TEST_NEEDED
Branch: fix/divine-ward-reroll
PR: — (unpublished; required approval pending)
Commit: 2e57572528f044da1a002ca492cffd39d2840681
Manual test requirement: Required for zero/low-cash UI and delayed payment, Boss Tag, resets, Ante grant, and cold restart; exact procedure is in REGRESSION_TESTS.md.
Notes: Local APPROVE; no public PR or accepted-main merge claimed. Native ease_dollars(-10) applies through a queued event, so the old immediate dollar snapshot/refund does not cancel payment. Native reroll UI also hides/disables the button based on voucher and $10 checks. The installed dump already includes Steamodded's priority -10 no-UI payload once, leaving exactly two post-Steamodded fee sites. The fix consumes the serialized per-Ante Ward at both native fee boundaries and derives UI allowance/price from the same state. Real-game callback/UI behavior remains unverified.

Independent review: APPROVE by Sol High at 2e57572528f044da1a002ca492cffd39d2840681. All nine headless regressions and all Lua/TOML checks passed, including an independently constructed already-applied Lovely fixture with real match_indent behavior. Source implementation is complete; publication and merge remain pending the existing explicit approval request. Main remains f863d0c2c543c4befa481803a581847ca8fe7274; gameplay/cold restart are HUMAN_TEST_NEEDED.

## R13: The Code punishes one consumable twice and bypasses Eternal filtering

Source: BUG_AUDIT.md R13
Classification: Source fix independently reviewed and merged; agent checks complete, actual game validation outstanding
Priority: Normal
Dependencies: 6, 19, R7 (accepted)
State: HUMAN_TEST_NEEDED
Branch: fix/code-consumable-punishment
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/7
Commit: 8fc3d43fa92ace3818cf03ad7ca8bda805ed7d83 (implementation/disposition); 2faf7fc1193546b3b35d6c5849b09cbc292b5000 (reviewed head); 592b30092d611a7b78694c21fff7d1b68e86a715 (accepted merge)
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
Commit: e4c4fc18c650cab22967ee11f709f83ea6d486b6 (implementation/disposition); df9a632fe28e9495d69e1d2cd6b00a7b715a86e2 (reviewed head); e8212e55654a98e20f571513c5381ddba03f8dc7 (accepted merge)
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

## N1: Familiar extra-draw numeric arguments are ignored

Source: Stabilization source trace; botg_familiars.lua Baby Fish/Serpent draw wrapper versus installed state_events.lua draw_from_deck_to_hand.
Classification: Source-confirmed additional defect outside the original audit
Priority: Normal
Dependencies: 7, R10 for shared draw-boundary design
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: After play/discard with the relevant familiar at levels1/2/4, compare requested and actual extra cards; include hand capacity and Serpent effects.
Notes: The familiar wrapper adds to e, but the installed native routine recomputes and overwrites that argument. Separate from possession R10 and excluded from R5; needs its own focused branch. Do not claim the advertised familiar extra draws are verified.

## N2: Potion Mirror aggregates only selected retrigger fields

Source: Stabilization full-chain trace; potions.lua outer Card.calculate_joker wrapper.
Classification: Source-confirmed additional composition limit outside the audit's listed chain
Priority: Normal
Dependencies: R5 establishes supported composed effects
State: AUDITED
Branch: —
PR: —
Commit: —
Manual test requirement: Mirror active on the rightmost Joker returning legacy Xmult_mod, nested extra effects or secondary post effects; compare both real calculations and effect application with an ordinary native retrigger.
Notes: Current aggregation adds chips/mult/dollars and multiplies x_mult/Xmult only, losing other second-calculation effects/post data and mutating the first return table. R5 preserves the primary forwarding contract and existing supported aggregation without silently redesigning the Potion. A separate branch must address full retrigger composition; it does not block standard R5 calculations with Mirror inactive.

## N3: Regression runner rejects an already patched Lovely dump

Source: R5 validation; tests/run.py versus current installed lovely/dump/blind.lua and UI_definitions.lua.
Classification: Source-confirmed test infrastructure defect; blocks required local checks after dump regeneration
Priority: Normal
Dependencies: Original target patches PR9
State: FIXED
Branch: fix/joker-calculation-composition
PR: —
Commit: 62a4cf10945c28580920720c90e51af931a4ef85
Manual test requirement: None for count validation; game behavior remains separate.
Notes: Local source fix is independently reviewed; no PR/merge yet because publication awaits required human authorization. The runner required exactly one pre-replacement pattern even when the current dump contains the exact complete applied payload instead. The blocking validation repair accepts exactly one original OR one complete applied payload, rejecting missing, partial, duplicate or mixed results; it does not skip the check or claim runtime gameplay verification.

## N4: Familiar draw wrapper drops the native early-return/argument contract

Source: Round-action draw trace; botg_familiars.lua unconditional outer draw_from_deck_to_hand wrapper, installed native game.lua:update_draw_to_hand and state_events.lua draw early return.
Classification: Source-confirmed wrapper defect discovered outside the original audit
Priority: Normal
Dependencies: N1 Familiar draw integration
State: AUDITED
Branch: -
PR: -
Commit: -
Manual test requirement: Zero hand limit with empty hand: native draw returns true for GAME_OVER; the actual full outer chain must preserve it so Game:update_draw_to_hand stops before scheduling SELECTING_HAND. Preserve all optional arguments and return positions through the Familiar wrapper.
Notes: The Familiar wrapper calls orig_draw(e) without returning it and accepts only e, even without a Familiar present. The current draw fix leaves that separately actionable wrapper contract for its own branch rather than claiming full-chain zero-limit game-over behavior. This local N4 is distinct from POST-N4 Echo stacking; keep the source-qualified identifiers in the final report.

## N5: Colorful Street Flush and suit fallback can outlive physical ownership

Source: Sol High surrounding-code review during R8; this is a local source finding, distinct from POST-N5.
Classification: Source-confirmed ownership-filter mismatch; actual transition impact requires gameplay evidence.
Priority: Normal
Dependencies: R8 helper contract
State: AUDITED (outside original audit; separate future branch)
Branch: —
PR: —
Commit: —
Manual test requirement: Slice/destroy/remove Colorful Street while it remains in a pending area snapshot; compare Straight helpers, four-card Flush and mixed red/black suit checks before actual removal and after queue drain. Preserve unrelated live Four Fingers/Shortcut/Smeared effects.
Notes: The unchanged get_flush fallback and Card:is_suit amalgam scan in src/core/utils.lua check nondebuff status but omit the new helpers' physical-area/removal/destruction/slicing filter. A pending-removal Colorful Street left in G.jokers.cards can therefore retain those fallback bonuses while its Straight helpers stop. R8 explicitly excludes rewriting these separate wrappers and preserves them; no speculative gameplay fix is included. Revalidate this separate finding on accepted main before implementation.

## N6: Hypnotist clears independently owned playing-card debuffs

Source: Newly discovered outside the original audit; src/jokers/rare.lua Hypnotist setting_blind callback.
Classification: Source-confirmed ownership risk; gameplay reproduction pending
Priority: Normal
Dependencies: R4 (accepted)
State: DISCOVERED
Branch: —
PR: —
Commit: —
Manual test requirement: Give one playing card an independent SMODS.debuff_card reason and a second only the Boss debuff. Force successful Hypnotist disable; the independent reason must survive while the Boss-only reason clears.
Notes: Tooltip promises to disable only the Boss debuff effect. After Blind:disable performs framework cleanup/recalculation, Hypnotist unconditionally assigns debuff=false to every playing card. This separate path was not named by audit R4. Do not include its cleanup patch in Lucky One probability integration. Local N IDs are distinct from POST_SOL_RUNTIME_FINDINGS.md IDs. No game execution or third-party ownership reproduction is claimed.
