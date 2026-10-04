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
Classification: Historical symptom; current source validation complete
Priority: Normal
Dependencies: 1, 6, 19, R10
State: HUMAN_TEST_NEEDED
Branch: docs/ares-vessel-discard-validation
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/19
Commit: ca0f92ace6828911e1286e441a41c41e0c434b07 (source validation)
Manual test requirement: Exact isolated game procedure in REGRESSION_TESTS.md; no Balatro execution.
Notes: Fresh branch from accepted d0f83b461d0777ffb52bb2a1af727f0906f7c967. Source-extracted native/Steamodded press-play dispatch, real registered Violet Vessel record, current Ares/Minotaur callbacks and possessed Hook exercise separate owners. Ares/Vessel cause no held-card discard; Ares destroys only scored cards after scoring. Native Hook and Minotaur discard two distinct held cards. Actual defeat wrapper, disabled state and reused same-key/new-ID encounters cancel stale Minotaur events. Possessed Hook remains an independent once/action owner while the Blind is disabled. All 16 Lua harnesses, Lua 5.1 compilation and shipping target/native-boundary controls pass. Luna's draft was taken over after a usage-limit failure; Sol corrected the native fixture and reviewed surrounding contracts. No speculative production change. Historical exact inventory remains unavailable. PR19 accepted at 0474ed39013d53bd96f3af08fb956832a644afe1.

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
Notes: Shared pure formula/native initialization hooks cover semantic Hubris, stake, showdown mult, Rod/Nectar, final cap and eligible Wall forecast; active previews read current serialized chips. Reset-only wrappers no longer scale or rebuild dynamic target. Competing shared-definition UI mutation and delayed Colosseum4000 override removed. Seven stub harnesses and exact installed Lovely pattern counts pass; actual game/number extension/conditional setup eligibility remain manual tests. Corrective N7 restores the actual native Vessel key in its own branch; see N7.

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
Classification: Source-confirmed draw defect; real gameplay and save behavior remain HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: 1, 6, 19
State: HUMAN_TEST_NEEDED
Branch: fix/round-action-draws
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/13
Commit: 99618014e3ce21a30b0c9b04f632c652343b082d; 0b386690550d3126916492fb42e4dc91d62dcf43; 7c1cd917fbbc80c74e7f3197bbefd0e31ac86995; accepted-main integration ddd97d7
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Local source implementation is APPROVED by Sol High and Luna; PR #13 is accepted and merged at 98ffbbc999263f334e4d0b9e600c746f8e4df339 and actual gameplay/save behavior remains unverified. The existing branch integrates accepted main 004387097ca286256363fb42e442d7f138049c99, including merged R5 and R6. The state-aware tests/run.py passes Lua 5.1 compilation, TOML/payload and installed target checks, validator negative controls, and all eleven harness files. Runtime-owned draw restriction restores native auto-refill for disabled Ouroboros alone while live Serpent remains independent. The physical-card selection boundary, pending counters, ownership and stable-ID partial/completed plan are covered by focused source/model checks; real Balatro event/save behavior remains in the manual queue. N1 and N4 Familiar issues remain separate and excluded.

## 8: Helin's exponent effect can do nothing in big-number mode

Source: ISSUE.md #8
Classification: Historical scoring symptom; installed extension supports e_mult
Priority: Normal
Dependencies: R5
State: READY
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: READY on accepted main 36c4283 after accepted R5 (PR 12). Installed Amulet supports e_mult; actual numeric/Omega source checks contradict the unsupported-key theory. Create a fresh bounded original-calculation/mode/Blueprint validation branch. Preserve supported dispatch and sequential exponentiation; retain exact human cold-runtime validation.

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
Classification: No Mark-generated repetition is source-confirmed; the historical symptom remains HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: The accepted R5 composer, draw integration, R8 straight API and R12 reroll fix are integrated at current accepted main be91b9b3cc1a72836b5b00b68c30d24265cae1e8. No production fix for Baby Mark is proposed.
State: HUMAN_TEST_NEEDED
Branch: docs/baby-mark-retrigger-validation
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/16
Commit: 74e5961fc2407d6c14ed477e12af05308e0d6eed (source validation); e1f23a4bc62e3024c9dcaa4258afc4b6667d88bf (accepted R5 composer harness integration); 8593e599082fbd7893270c60472313871a2a3e51 (accepted-main merge)
Manual test requirement: Required to resolve the historical ~ten-message report; exact isolated procedure is in REGRESSION_TESTS.md.
Notes: Current Mark code returns XMult for `context.individual` on a scored face card and returns no `repetitions`. Installed `SMODS.score_card` owns repeated scoring passes; Red Seal supplies one repeat and Polychrome supplies an XMult edition effect. The Familiar scoring area wrapper checks for the same area before appending it. On the original `f863d0c` base, nine harness files passed; the test uses source-extracted native loops/callbacks with explicit evaluation/UI adapters and cannot recreate the reported run. After merging accepted main `be91b9b3cc1a72836b5b00b68c30d24265cae1e8`, its harness loads the actual accepted R5 composer before the Familiar wrapper and the stock runner passes all fourteen harnesses, Lua 5.1 compilation, TOML/payload checks and target-validator controls. The exact game symptom remains unverified; do not suppress Mark on legitimate repeated evaluations. PR #16 is accepted and merged at c7879d9ad4c170a565c0a3d438a4bdf05a852982.

## 12: Consumable stacking compatibility / UI: no clean native stacking, and early visual-only patches buried cards

Source: ISSUE.md #12
Classification: NOT_A_BUG on current main; optional feature gap, with historical local implementations absent
Priority: Optional
Dependencies: None for this source-only disposition; any future feature waits for correctness stabilization
State: NOT_A_BUG
Branch: docs/consumable-stacking-disposition
PR: [#18](https://github.com/benedictdavon/balatro-reality-warp/pull/18) (open for independent review)
Commit: c6c78485bb752df26e8347c313465875b93b0548 (source disposition; Sol High APPROVE)
Manual test requirement: None for the source-only disposition. Optional baseline confirmation and future feature acceptance tests are in REGRESSION_TESTS.md.
Notes: Current Reality Warp and installed framework use separate real Card objects; no quantity/representative/split-use/save model or local v1–v6 patch is present. The old visual-only buried-card behavior cannot execute in this checkout. Potion Pouch is separate serialized storage for up to six potions, and Cauldron consumes two real cards into a recipe result; neither is stacking. This closes the reported current-main defect claim without implementing the requested optional feature. Preserve A/B/C controls.

## 13: Dark Alchemy Tag tooltip/code probability deserves verification

Source: ISSUE.md #13
Classification: Source-confirmed defect; revalidate before implementation
Priority: Normal
Dependencies: 14
State: READY
Branch: —
PR: —
Commit: —
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: READY on accepted main 36c4283 after accepted Lucky probability ownership (PR 17). Two overlapping 3% paths plus native polling imply approximately 0.060846 versus baseline 0.003, not 10x. Activation is already synchronous before first shop stock. Establish a single owned edition-weight/options/sample contract on a fresh branch without hijacking RNG.

## 14: Lucky One probability logic has historically been broader than the tooltip suggests

Source: ISSUE.md #14
Classification: Source fix independently reviewed and locally approved; actual game validation outstanding
Priority: Normal
Dependencies: Accepted R5 composition, R6 Arrow, round-action draw, R8 forwarding, R12 reroll, and ISSUE #11 validation are integrated on current accepted main `c7879d9ad4c170a565c0a3d438a4bdf05a852982`.
State: HUMAN_TEST_NEEDED
Branch: fix/lucky-one-rng
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/17
Commit: c53fffc6a9fac38f2a2816b3e9359cd706e54bb3 (implementation); 305ad622a5bcf03dab0498be6e8a4f88abad76b2 (unowned preview correction); 39a503d6c5701427709ba2cb342c752fd5485a6e (Blueprint/retrigger controls); 288e6ba4720326f4189aaad41ed061d4d98f88eb (Echo/Miner correction); f0cc1ed64b38a823ad2c25785bc582541e20216e (accepted-main merge); 65aef4ef908d64955f6155b8b37385c866f4c954 (integrated harness adapters)
Manual test requirement: Exact seeded Club/token, typed probability, UI/simulation, end-round and cold-restart cases are in REGRESSION_TESTS.md; real game remains unrun.
Notes: Historical isolated review started from `f863d0c2c543c4befa481803a581847ca8fe7274`; its nine-harness result and initial publication state apply only to that base. The branch now merges current accepted main `c7879d9ad4c170a565c0a3d438a4bdf05a852982`. The integrated stock runner passes all fifteen harnesses, Lua 5.1 compilation, TOML/payload and native patch-state controls; the focused Lucky One harness also passes under LuaJIT with installed Amulet Omega. Root's in-memory fully-applied reset-payload control passes and rejects mixed/duplicate states. Global `pseudorandom` stays native; per-card charges and private result/reservation scopes preserve copy/simulation/disabled/end-round semantics. PR #17 (https://github.com/benedictdavon/balatro-reality-warp/pull/17) was opened at reviewed integrated code head `7592eac6d03e8a2a1ffd1e1f4af342ebfa1d70f6`; its later documentation metadata commit is included for independent review. Hypnotist cleanup remains separate local N6.

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
Classification: STALE; historical local-v6 badge implementation absent from current main
Priority: Cosmetic
Dependencies: 12 only if a separate stacking feature is implemented
State: STALE
Branch: docs/consumable-stacking-disposition
PR: [#18](https://github.com/benedictdavon/balatro-reality-warp/pull/18) (open for independent review)
Commit: c6c78485bb752df26e8347c313465875b93b0548
Manual test requirement: None while no quantity badge exists. If stacking is implemented later, test quantities 2/10/100 at normal, hover, and drag scales with adjacent stacks, hitboxes, and controller focus.
Notes: Current source has no representative quantity badge or local-v6 placement code. The historical top-right to top-center correction cannot be reproduced here; this label is stale on current main, not a verified fix to Reality Warp.

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
Notes: Shared pure formula/native initialization hooks cover semantic Hubris, stake, showdown mult, Rod/Nectar, final cap and eligible Wall forecast; active previews read current serialized chips. Reset-only wrappers no longer scale or rebuild dynamic target. Competing shared-definition UI mutation and delayed Colosseum4000 override removed. Seven stub harnesses and exact installed Lovely pattern counts pass; actual game/number extension/conditional setup eligibility remain manual tests. Corrective N7 restores the actual native Vessel key in its own branch; see N7.

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
Classification: Source-confirmed composition defect; runtime interactions remain HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: 18
State: HUMAN_TEST_NEEDED
Branch: fix/joker-calculation-composition
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/12
Commit: 62a4cf10945c28580920720c90e51af931a4ef85; correction eadc076a1f61c2db1085bc95a10afe888c83e3c2; accepted-main integration 2b0d9d3; N3 matcher correction 6856781df919d338e9fdb8b393a80e80ecd0358a
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Local source implementation and independent review are complete; PR #12 is accepted and merged at 004387097ca286256363fb42e442d7f138049c99. The branch preserves the supported true-removal-sentinel correction and integrates accepted main add5727837c396fff2b5af12283fc3f25904d242 (including merged Arrow R6). Ten Lua harness files, Lua 5.1 compilation, TOML/payload checks, original/applied target-patch validation, and negative validator controls pass. The test runner rejects missing, partial, duplicate, and mixed target-patch states, including an original pattern combined with a partial applied payload. Runtime/save/load/optional-mod gameplay remains unverified and required.

## R6: Arrow rank lookup uses invalid vanilla card keys

Source: BUG_AUDIT.md R6
Classification: Source-confirmed invalid vanilla rank-key lookup; gameplay remains HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: Accepted canonical identity and disabled-effect contracts (PR2/4); current scoring-stage main (PR10)
State: HUMAN_TEST_NEEDED
Branch: fix/arrow-rank-mapping
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/11
Commit: 31015cf76b9637e6ddcce757b1528ce07e81690e
Manual test requirement: Required for gameplay; exact procedure will be recorded in REGRESSION_TESTS.md.
Notes: Local source review APPROVE at implementation commit 31015cf76b9637e6ddcce757b1528ce07e81690e. The original-base nine Lua harnesses and Lua 5.1 compilation passed; at that historical checkpoint the stock aggregate runner had the N3 exact-pattern limitation, and an independent original-or-fully-applied check confirmed both owned Lovely target payloads. N3 is now FIXED in accepted PR 12; all fifteen harnesses pass on current main. `SMODS.modify_rank` follows registered `prev`/`prev_behavior` and `SMODS.change_base` resolves registered suit/rank `card_key`s. Actual Balatro gameplay remains unverified and required.

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
Dependencies: None (independent API fix); integrated accepted main 98ffbbc999263f334e4d0b9e600c746f8e4df339
State: HUMAN_TEST_NEEDED
Branch: fix/straight-api-forwarding
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/14
Commit: 19b60afda787c64d6da37de9ea43923d1893c8dc (implementation); 528ec0d34b0bb8c249efb5e27cf12bddcba143ab (accepted-main integration)
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: The pre-fix wrapper accepted only `hand`, dropping the installed four-argument detector contract and all trailing values; its numeric fallback bypassed custom rank graphs. R8 restores native/helper forwarding and retains Colorful Street through framework helpers. Sol High independently reviewed the complete immutable diff and surrounding/native dispatch contracts: APPROVE. PR #14 is accepted and merged at 31886a8dca4b22b47c5f05e1e9795b18c63d5286. The branch integrates accepted main 98ffbbc999263f334e4d0b9e600c746f8e4df339; the state-aware runner passes all twelve harness files, Lua 5.1 compilation, TOML/payload, installed original/applied target checks and git diff --check. No Balatro execution is claimed. ISSUE #10's historical hand remains classified STALE for its original fallback failure and stays in the regression controls; R8 addresses the separate modern API contract. Real card scoring, custom ranks, optional helper behavior and cold restart remain pending.

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
Classification: Source-confirmed possession draw/transfer defects; exact runtime behavior remains HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: 7
State: HUMAN_TEST_NEEDED
Branch: fix/round-action-draws
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/13
Commit: 99618014e3ce21a30b0c9b04f632c652343b082d; 0b386690550d3126916492fb42e4dc91d62dcf43; 7c1cd917fbbc80c74e7f3197bbefd0e31ac86995; accepted-main integration ddd97d7
Manual test requirement: Required for gameplay/save/load; exact procedure will be accumulated in REGRESSION_TESTS.md.
Notes: Local source implementation is APPROVED by Sol High and Luna; PR #13 is accepted and merged at 98ffbbc999263f334e4d0b9e600c746f8e4df339 and actual gameplay/save behavior remains unverified. The branch integrates accepted main 004387097ca286256363fb42e442d7f138049c99, including R5 and R6. The state-aware runner passes all eleven harness files and installed target checks. Possessed Serpent draw restriction and score contribution remain independent, Water is once per eligible physical owner/action, and Hook selects and commits distinct successful transfers. Native pending/event order and the actual save codec still require the documented gameplay fixture. N1 and N4 Familiar issues are separate and excluded.

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
Classification: Source-confirmed delayed-fee/UI allowance defect; gameplay remains HUMAN_TEST_NEEDED
Priority: Normal
Dependencies: Accepted PR3 provides the once-per-Ante Ward grant; the reroll payment/UI fix is otherwise independent. Integrated accepted main 31886a8dca4b22b47c5f05e1e9795b18c63d5286.
State: HUMAN_TEST_NEEDED
Branch: fix/divine-ward-reroll
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/15
Commit: 2e57572528f044da1a002ca492cffd39d2840681 (implementation); d271c4504c31f79af7cde0fc8291c0787ecb357c; 76bdcea1186425baf45dd36fb20339b4c8c8f7ca (review record); 844a30ca2f338fa09d5666985ba1ef7a43ab8780 (accepted-main integration)
Manual test requirement: Required for zero/low-cash UI and delayed payment, Boss Tag, resets, Ante grant, and cold restart; exact procedure is in REGRESSION_TESTS.md.
Notes: Native ease_dollars(-10) applies through a queued event, so the old immediate dollar snapshot/refund does not cancel payment. Native reroll UI also hides/disables the button based on voucher and $10 checks. The installed dump already includes Steamodded's priority -10 no-UI payload once, leaving exactly two post-Steamodded fee sites. The fix consumes the serialized per-Ante Ward at both native fee boundaries and derives UI allowance/price from the same state. The original R12 branch passed nine harness files; its then-current stock runner still had the separate N3 applied-payload limitation. After integrating accepted main 31886a8dca4b22b47c5f05e1e9795b18c63d5286, the stock tests/run.py passes all thirteen harnesses, Lua 5.1 compilation, TOML/payload checks, installed patch-state checks and validator controls. Sol High's source review approved the implementation; PR #15 is accepted and merged at be91b9b3cc1a72836b5b00b68c30d24265cae1e8. Real-game callback/UI and cold-restart behavior remain unverified.

Independent review: APPROVE by Sol High at 2e57572528f044da1a002ca492cffd39d2840681. All nine headless regressions and all Lua/TOML checks passed on the original base, including an independently constructed already-applied Lovely fixture with real match_indent behavior. Sol High re-reviewed the integrated source and harness after accepted main 31886a8dca4b22b47c5f05e1e9795b18c63d5286; no source correction was requested, and all thirteen stock harnesses now pass. PR #15 is accepted and merged at be91b9b3cc1a72836b5b00b68c30d24265cae1e8. Gameplay, live UI, event timing and cold restart remain HUMAN_TEST_NEEDED.

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
## Queued follow-up: post-stabilization runtime audit

The user extended the goal to audit POST_SOL_RUNTIME_FINDINGS.md after the original ISSUE #1-20 and R1-R14 pass finishes, then repeat sequential Option A for its confirmed actionable findings. The file is present and was read completely; it reports user gameplay on main f863d0c, Balatro1.0.1o-FULL/Steamodded26.829.0/Lovely0.9.0/Amulet3.6.2/JokerDisplay1.10.9, with retrigger_joker enabled. This is reported human evidence, not agent game execution. Preserve that checkpoint for revalidation against the eventual accepted main.

The report remains untracked and unchanged as a user-authored input while the current draw issue branch is in progress. Track it in the follow-up documentation branch so it is not silently mixed into this production fix. Its IDs will be source-qualified as POST-N3 through POST-N9 and POST-#9, avoiding collisions with local stabilization discoveries N1-N3. The next phase must revalidate underlying causes (including the reported starter Perishable refresh behavior), preserve the stated non-bug observations, and profile the performance finding before proposing a speculative production fix. No follow-up source patch has begun.

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
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/12
Commit: 62a4cf10945c28580920720c90e51af931a4ef85; matcher correction 6856781df919d338e9fdb8b393a80e80ecd0358a
Manual test requirement: None for count validation; game behavior remains separate.
Notes: PR #12 carries the runner fix. The runner previously required exactly one pre-replacement pattern even when the installed dump contained the complete applied payload. R5's state-aware validator now accepts exactly one original OR one complete applied payload and rejects missing, partial, duplicate, or mixed states, including an original pattern with a partial applied payload. It does not skip the check or claim runtime gameplay verification. Ten Lua harnesses, Lua 5.1 compilation, TOML and installed payload controls pass on the integrated R5 branch.


## N7: Violet Vessel target uses a nonexistent native key

Source: Original #5 follow-up discovered during #2 source validation; not POST
Classification: Source-confirmed regression in accepted unified target helper
Priority: High
Dependencies: 5, R3; finish #2 branch first
State: HUMAN_TEST_NEEDED
Branch: fix/vessel-target-key
PR: https://github.com/benedictdavon/balatro-reality-warp/pull/20
Commit: 0c1e38fc3a32d1818efcebad4cb295e5b7799add (canonical correction)
Manual test requirement: BOTG base ×8 and ordinary native base ×6, preview/selection/runtime/reset/cold restart with exact versions, salt and modifiers recorded.
Notes: Native registration and Steamodded use bl_final_vessel, not bl_vessel. PR9's helper and synthetic fixture copied the nonexistent key, causing actual Colosseum Vessel to use generic5 instead of its prior8. The smallest canonical-key correction restores8. The target fixture now source-extracts actual native Vessel metadata, checks ordinary6 and localized-name-spoof5, and retains the full preview/runtime/modifier/slot/reset matrix. All16 stock harnesses and Lua5.1/TOML/native boundary checks pass. No game execution.
