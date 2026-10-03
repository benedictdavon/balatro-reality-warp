# Implementation briefs

## Blind identity contracts

Issue: #18 identity contracts and R11 canonical detectors.
Classification: confirmed source defects, runtime verification required.
Dependencies: none; scheduler follows on accepted main.
Relevant files/functions: RealityWarp loader, blind_identity, utils detectors/UI cleanup, Blind.get_type wrapper, black_market rewards and botg_combat category checks, Pincer callbacks.
Confirmed root cause: display/legacy aliases omit registered keys; runtime boss flags represent slots; UI reset clears gameplay state; Pincer unlock would blanket-clear debuffs.
Required behavior: exact canonical identity; explicit semantic metadata; framework progression/type behavior; disabled-aware idempotent Pincer unlock via recalculation, with Chicot exemption.
Behavior that must remain unchanged: slot progression, ordinary non-BOTG behavior, card-destroyer exemptions and existing reward amounts.
Explicitly excluded work: scheduler, target formulas, other lifecycle/RNG/Joker fixes and optional stacking.
Required static validation: full diff/callers, Lua 5.1 compile, identity and unlock harness, diff check.
Required runtime/manual validation: canonical detector positive/disabled controls, Big-slot progression/rewards, independent debuff preservation (REGRESSION_TESTS).
Known risks: previously dormant penalties become active; real framework wrappers and optional mods require game tests.
Review: APPROVE after complete diff/source inspection and passing Lua 5.1 checks; #18 remains in progress until scheduler integration.

## Encounter lifecycle and parameters

Issue: #1, #3, #4, #15–18, R1 (inseparable scheduler/identity/persistence root).
Classification: source-confirmed architecture defects; HUMAN_TEST_NEEDED after implementation.
Dependencies: canonical identity PR #2 accepted on main 1afc7e5.
Relevant files/functions: blind_encounters, battle_of_gods reset/get_new_boss/UI/mode entry, Athena/Net/Hades/Doppelganger, fused metadata, utility activation detector.
Confirmed root cause: competing schedule writers, counter mutation during discarded rolls, overlapping pools, absent serialized targets and direct target object references.
Required behavior: pure eligible candidates, explicit counted commits, stable serialized slot IDs/parameters, one future-refresh request per defeat, immutable preview/active target, cold-load stable sort_id reconnection.
Behavior that must remain unchanged: progression slots; familiar initialization; achievements; Ante-1 versus later slot policy where compatible with eligibility; requested post-win future refresh; non-BOTG base selection/counters; played-versus-scored destruction scope.
Explicitly excluded work: requirement formulas, disabled/delayed effects, debuff cleanup, removals, scoring/RNG and optional features.
Required static validation: complete diff and framework reset/selection/save contracts; Lua 5.1; scheduler/parameter/reconstruction stubs; diff check.
Required runtime/manual validation: exact lifecycle/target/cold restart queue in REGRESSION_TESTS.
Known risks: seeded sequences change; earlier invalid pool access no longer allowed; empty showdown/fused pools use eligible fallback; old missing targets cannot be recovered and use marked deterministic migration defaults.
Review: APPROVE after correcting duplicate refresh on Boss transition, standard-mode counter duplication and explicit fused classification; local harness passes. Full game save serialization remains HUMAN_TEST_NEEDED.

## Effect ownership foundation

Issue: #6, #19, R4 and #9 residual cleanse eligibility (shared lifecycle/debuff root).
Classification: confirmed unsafe callbacks/cleanup; historical revival symptom remains a game case.
Dependencies: identity and encounter PRs #2/#3 accepted on main 43a90f4.
Relevant files/functions: normal calculate callbacks, Athena/Phone lifecycle, Pincer predecessor cleanup, Minotaur/Iron Maiden events, combat counterattack, Thanatos/Apotheosis, utility highlight/background hooks.
Confirmed root cause: disabled dispatch still runs active effects; delayed closures read reused runtime/global lists; cleanup assigns a shared debuff Boolean.
Required behavior: cleanup before active guards; source-owned SMODS debuffs; event game/id/key/phase validation and captured cards; explicit showdown cleanse; retain framework expiry/other restrictions.
Behavior that must remain unchanged: enabled penalties, Blessed protection, legitimate showdown refresh/Rental removal, Apotheosis Blind immunity, progression and scoring scope.
Explicitly excluded work: Iron Maiden/refund deltas R2, removal notifications R7, duplicate Code use R13, scoring/Joker/RNG rules and optional features.
Required static validation: complete diff and ownership/dispatch/card debuff contracts; Lua 5.1 and actual callback/event/source stubs; diff check.
Required runtime/manual validation: disabled/queued/winning/next/cold controls and cleanse cases in REGRESSION_TESTS.
Known risks: framework event blocking must allow normal winning-hand penalties before defeat; optional mod debuff hooks require real game checks; missing queued events do not survive cold restart.
Review: APPROVE after correcting press-play captured cards, removing duplicate Magician guard and stale delayed UI reset. Agent-executable checks pass; real gameplay remains HUMAN_TEST_NEEDED.

## Iron Maiden hand-size and resource refund ownership

Issue: BUG_AUDIT R2.
Classification: source-confirmed lifecycle defect; HUMAN_TEST_NEEDED after code/checks.
Dependencies: #6/#19 effect ownership foundation accepted as PR #4.
Relevant files/functions: `src/blinds/fused_blinds.lua`: Obelisk, Leviathan, and Iron Maiden `calculate` callbacks; Steamodded `blind_disabled` and `blind_defeated` contexts.
Confirmed root cause: Iron Maiden applies hand-size -1 without tracking its ownership, restores only on disable, and can restore repeatedly. Obelisk/Leviathan persist setup amounts but neither guard duplicate setup nor clear refunds after cleanup; Obelisk bases its removal on configured round hands rather than remaining hands.
Required behavior: store serializable applied deltas and one-time setup markers on the runtime Blind's `effect`; reverse Iron Maiden's actual -1 once on disable or defeat; on disable refund only resources removed by Obelisk/Leviathan, once; clear those ledgers on defeat. Obelisk setup leaves one remaining hand, using `current_round.hands_left`; Leviathan setup leaves zero remaining discards. Cleanup claims/clears each delta before calling the refund API. Preserve legacy `hands_sub`/`discards_sub` save fields where present.
Behavior that must remain unchanged: all enabled effects, Iron Maiden's per-card money penalty, Obelisk's prior-play debuff, Leviathan's face-down cleanup and its refund-before-flip ordering, slot progression, and original resource amounts except over-refunds.
Explicitly excluded work: other Blind bugs/refactors, R14 history, effect/event ownership changes, card draw, destruction/removal paths, and balance changes outside erroneous resource refunds.
Required static validation: Lua 5.1 compile; callback harness for repeat setup, disable twice, disable/defeat, next encounter, simulated saved-effect reconstruction, disabled-at-setup, and remaining-resource math; complete diff/status review.
Required runtime/manual validation: Iron Maiden hand size before/after win/disable/defeat/next encounter and cold restart; Chicot at setup and late disable; Obelisk/Leviathan remaining-resource and zero-resource cases, recorded in REGRESSION_TESTS.
Known risks: Balatro hand-area reconstruction and callback/event ordering need a real cold-restart run; resource easing must remain idempotent if cleanup is re-entered. Pre-fix Iron Maiden saves have no ownership ledger, so an in-progress save cannot safely distinguish an applied -1 from a disabled-at-setup Blind; no compensation is inferred. New saves carry the serialized ledger. This work does not alter event ownership.
Review: APPROVE at `2155e8ccf5f5f6dd30cc4ad1df7d5739eaf10b79`. Sol High independently inspected the complete diff and callback surroundings, then reran `tests/run.py` and `git diff --check`; both passed. No Balatro runtime or cold-restart validation was performed, so the issue remains HUMAN_TEST_NEEDED.

## Boss destruction notification contract

Issue: BUG_AUDIT R7.
Classification: source-confirmed installed-framework contract defect; HUMAN_TEST_NEEDED for gameplay/save behavior.
Dependencies: #6/#19/R4 effect ownership foundation and accepted R2.
Relevant files/functions: `src/core/blind_effects.lua` destruction helper; Ares, Net, and Hades `calculate` callbacks in `src/blinds/boss_blinds.lua`.
Confirmed root cause: these after-context callbacks directly dissolved cards after the normal destroyed-card collection had already emitted `remove_playing_cards`, bypassing the framework notification and destruction-hook path.
Required behavior: snapshot/deduplicate eligible card references and omit removed, destroyed, shattered, or getting-sliced cards. Call `SMODS.destroy_cards` once per nonempty batch with immediate acceptance and let the API make the sole Eternal eligibility check, returning its accepted list. Ares retains one 1-in-5 roll for `scoring_hand`, Net uses its encounter's saved rank, and Hades snapshots held cards before callbacks can mutate the hand area.
Behavior that must remain unchanged: odds/seeds, scoring versus held-card scope, target rank, disabled guards, Chicot handling, native destruction notifications, Glass/custom/Spectral hooks, and removal-aware Joker behavior.
Explicitly excluded work: R13 Code, RNG/target/draw changes, broad wrapper rewrites, and unrelated formatting.
Required static validation: Lua 5.1 whole-repository compile and all harnesses; registered callback contract checks for batch IDs, notification counts, native-destroyed exclusion, duplicate/repeated references, Eternal/disabled cases and hand-list mutation; full diff/status and `git diff --check`.
Required runtime/manual validation: Canio, Glass Joker, standard consumable comparison, Net match/nonmatch, Hades held/unplayed cards, Chicot, winning hands, next encounter and cold-save/event boundary (REGRESSION_TESTS.md).
Known risks: Steamodded's `immediate` option dispatches bookkeeping synchronously but still uses native animation/removal scheduling; the API alone evaluates Eternal state once per candidate. Ares permanence now commits at `context.after`, and its existing delay applies only to visual feedback. No Balatro runtime, reload or save-codec test has been run.
Implementation commits: `333c3fd0c27009a540369e449b22d437f3dbfef3` (initial) and `64e7576eeb9b103dfee2bd8936a5c7071fc80321` (Eternal eligibility correction); PR #6 is open.
Review: APPROVE at `0bda04c6a299dbd303c4cb624b8ee938264f7b72` after one correction round removed redundant Eternal evaluation. Sol High independently reviewed the complete diff, callback surroundings and installed destruction contract, then reran all five Lua 5.1 harnesses and `git diff --check`; they pass. No real game or save-boundary test ran; gameplay remains HUMAN_TEST_NEEDED.

## Code consumable punishment ownership

Issue: BUG_AUDIT R13.
Classification: source-confirmed duplicate punishment and Eternal eligibility defect.
Dependencies: accepted encounter/effect/destruction contracts, main `ce82699`.
Relevant files/functions: Code.calculate, Card:use_consumeable wrappers in utils/potions/vouchers, Potion Pouch use, blind_effects helper.
Confirmed root cause: UI calls the use method and then using_consumeable; both independently punish. Pouch bypasses the use method/context entirely. Existing selection can fall back to Eternal Jokers.
Required behavior: the real Card use method owns one punishment per invocation; remove duplicate Blind calculate implementation, route Pouch through the normal method and notify ordinary consumable listeners once. Capture encounter before use, revalidate afterward, exclude debuffed unsuccessful uses and removed/ineligible targets. Select among framework-destroyable Jokers, use supported destruction, increase the same encounter target once even with no eligible Joker. Preserve wrapper arguments/returns.
Behavior that must remain unchanged: consumable effects, sound/particle/voucher hooks, UI listener coverage, normal mode, disabled Code, Doctor Jo/framework removal hooks and X1.25 amount.
Explicitly excluded work: quantity stacking, RNG ownership, target formulas, unrelated wrapper refactors and Doctor Jo redesign.
Required static validation: Lua 5.1 compilation and all harnesses; actual wrapper/helper callbacks under stubs for UI method plus context, repeated real uses, Pouch/direct use, all-Eternal/disabled/debuffed controls, changed encounter during use, original arguments and multiple returns.
Required runtime/manual validation: enabled Code with three ordinary Jokers, direct use, Pouch, all-Eternal, Chicot, Doctor Jo and actual destruction counts; exact procedure in regression queue.
Known risks: eligibility selection and committed destruction each query framework protection, so final protection is revalidated. Native animations remain queued; external mods that call a definition directly must use the normal Card method to receive Code's punishment. Balatro execution remains unavailable.

Review: APPROVE at `5042ea2` after complete Sol High source/diff review and independent Luna review of the same diff, wrapper load order and installed consumption/destruction contracts. All six Lua 5.1 harnesses and compilation pass, and `git diff --check` is clean. Implementation: `8fc3d43fa92ace3818cf03ad7ca8bda805ed7d83`, PR https://github.com/benedictdavon/balatro-reality-warp/pull/7. Actual Balatro, Doctor Jo and cold-save tests remain HUMAN_TEST_NEEDED. This is an agent maintainer approval; GitHub disallows the shared author account approving its own PR.

## Ante-history hook disposition

Issue: BUG_AUDIT R14.
Classification: STALE on the verified installed framework stack; no runtime verification claimed.
Dependencies: Accepted main `592b30092d611a7b78694c21fff7d1b68e86a715`; installed Lovely/Steamodded sources and Reality Warp Lovely patches inspected.
Relevant files/functions: `docs/BUG_BACKLOG.md` R14, this disposition, and `docs/REGRESSION_TESTS.md`; source evidence in `src/core/utils.lua`, `src/core/botg_possession.lua`, `src/blinds/fused_blinds.lua`, and `../lovely/dump/functions/state_events.lua`.
Confirmed root cause: The audit assumed the bare global `evaluate_play` existed. The installed framework only calls/defines `G.FUNCS.evaluate_play`; Reality Warp's conditional wrapper captures the absent bare global at `src/core/utils.lua:7817–7829`, and source searches found no alias bridge in required framework files or this mod's Lovely patches. Native evaluation dispatches `context.after` before queuing `played_this_ante` markers for every played card (`state_events.lua:908–917`).
Required behavior: Preserve R14 and its source evidence in the backlog, classify the reported early-marking defect STALE for this stack, and make no production change.
Behavior that must remain unchanged: Native post-after history marking; Possessed Pillar and Obelisk prior-play checks; Reality Warp's separate `ease_ante` history reset; all 34 existing issue/audit labels.
Explicitly excluded work: Production fixes, target/scoring changes, and speculative support for optional mods that might introduce a bare alias.
Required static validation: Confirm source references against accepted main and installed framework; review all changed documentation, `git diff --check`, and verify the 20 ISSUE plus 14 R-label headings remain present.
Required runtime/manual validation: No runtime result is claimed. An optional first/repeat-play, played-versus-scored, Obelisk, Ante-reset and reload fixture is documented in REGRESSION_TESTS.md and remains unrun.
Known risks: Another optional mod could define a bare global alias in a different stack; that would require fresh evidence and revalidation. The accepted installed stack contains no such bridge.
Review: APPROVE at e4c4fc18c650cab22967ee11f709f83ea6d486b6. Sol High independently inspected all three changed documents, the namespaced/native history path and a fresh no-alias search. No production code changes, all 34 labels remain, and git diff --check passes. PR: https://github.com/benedictdavon/balatro-reality-warp/pull/8.

## Initial target calculation and reset ownership

Issue: ISSUE #5 and BUG_AUDIT R3, one inseparable initial-target/refresh root.
Classification: source-confirmed on accepted main e8212e55654a98e20f571513c5381ddba03f8dc7.
Dependencies: accepted encounter/category/effect/destruction/Code contracts; R14 revalidated STALE.
Relevant files/functions: native Blind:set_blind initial expression and blind-choice UI expression via narrow Lovely patterns; new blind_targets helper; battle_of_gods target/get_blind_amount/UI wrappers; utils Rod wrapper; Nectar wrapper; Colosseum delayed target bypass; Wall setup modifier.
Confirmed root cause: several post-base wrappers rebuild/multiply target on reset=true; showdown override drops stake/Rod; semantic Hubris uses progression flags; preview mutates shared definition mult and lacks Hubris/final-cap parity. Nectar also repeats on reset; Colosseum queues a conflicting 4000-base override.
Required behavior: one pure target formula fed read-only run modifiers for UI and native initial setup, canonical showdown keys, semantic boss Hubris, stake/Rod/Nectar order and cap after initial modifiers; consume Rod only at actual new setup. Reset-only refresh preserves authoritative current chips, including dynamic reductions/growth. Preserve native serialized chips. Active run-info preview reads current target. Forecast eligible Wall setup multipliers; retain framework conditional sticker dispatch and use same cap.
Behavior that must remain unchanged: progression/get_type, target curve 15000..36B/endless fallback, original definition mult, custom definition callbacks and dynamic effects, Wall eligibility/reward/history, ordinary non-BOTG targets absent relevant modifiers, wrapper arguments/returns and saved target state.
Explicitly excluded work: R9 score timing, Joker composition, RNG, new persistence codecs, speculative third-party callback forecasting, and unrelated gameplay/refactors.
Required static validation: Lua5.1 compile/all harnesses; pure formula slot/category/stake/Hubris/Rod/Nectar/cap cases; source-extracted actual wrappers, new-setup versus repeated disabled/enabled refresh, custom target callback, current-preview versus next-slot; Wall composition; wrapper arguments/multiple/trailing returns; TOML parse and exact Lovely pattern counts against installed dump.
Required runtime/manual validation: baseline/Colosseum/transition, Big/Boss semantic normal/fused/showdown including Chronos/Vessel, divine counts0..3, stakes1/2, Rod/Nectar/Wall, Chicot, dynamic Code/Void/reductions plus repeated add/remove refresh and cold restart; actual big-number extension at Ante24.
Known risks: fixed missing Big-slot Hubris and showdown stake/Rod changes historical incorrect targets. Preview Wall forecast uses current calculation eligibility; a custom/random setup callback may change that eligibility before sticker dispatch, which must remain a conditional runtime effect. Big-number conversion/rounding and actual Lovely patch application require game validation. Sol High implements directly because target ownership crosses several global wrappers.

Review: APPROVE at production8b6b0b910fb6466aade2ae2df18b7254fb3fc2c3 / metadata03f027e. Complete Sol High diff/surrounding-source review plus independent Luna review found no concrete callback, reset, cap-order or forwarding issue. Compilation, seven Lua harness files, TOML/payload checks, exact installed pattern counts and git diff --check pass. PR https://github.com/benedictdavon/balatro-reality-warp/pull/9. Native game application, actual number extension, cold saves and conditional setup-debuff forecasts remain HUMAN_TEST_NEEDED.

## Final scoring stage ownership

Issue: BUG_AUDIT R9, Chronos and Guillotine duplicate scoring stages plus Void's early win check.
Classification: Source-confirmed duplicate `modify_hand`/final-score paths; source-confirmed queued-score timing for Void, with game-event behavior still requiring manual confirmation.
Dependencies: Accepted Blind identity/lifecycle/effect contracts and initial/dynamic target reset ownership (#5/R3), main `50babb21ba2297437510ecf0ea5eb025fb5b2504`.
Relevant files/functions: `src/blinds/boss_blinds.lua` Chronos and Guillotine `modify_hand`, Void `calculate`; `src/core/utils.lua` final Blind score logic; `src/decks/decks.lua` outer extensible `Back:trigger_effect`; installed `../lovely/dump/functions/state_events.lua` scoring sequence and `../smods/src/overrides.lua` `Blind:modify_hand` dispatch.
Confirmed root cause: Chronos and Guillotine each run once during pre-Joker `modify_hand` and again during final scoring. The current final-score wrapper is inside the outer Reality Warp deck dispatcher, so registered deck callbacks can change its result afterward. Void compares current chips during `context.after` while native score addition is still queued; `SMODS.last_hand_score` is already set before that callback.
Required behavior: Remove only Chronos and Guillotine's early `modify_hand` callbacks. Apply the existing final Blind rules once at the end of the outer Back dispatcher, after the original Back callback and registered deck hooks, only for `final_scoring_step`, a matching canonical Blind key, and an enabled runtime Blind. Chronos projects a win as current round chips plus `math.floor(final returned chips * final returned mult) >= Blind.chips`, then applies the existing X0.90 Chips/Mult floor/minimum-once math and feedback once. Guillotine consumes one existing `pseudorandom('guillotine')` result at the existing `normal / 5` odds and sets its final-scoring result to zero after deck scoring. Preserve canonical Doppelgänger ÷4 behavior, rounding, conditions, and flag cleanup in that same helper. Void compares `G.GAME.chips + math.floor(SMODS.last_hand_score)` to the current Blind target during a real, non-Blueprint `context.after` with a scoring hand; it grows the target by X1.5 only when that projected total is below target, without queuing another target mutation.
Behavior that must remain unchanged: Other Blind `modify_hand`/calculate effects; existing deck callback order and its first-two-result override rules; all wrapper arguments and original extra/post/trailing-nil returns; zero chip or mult results; native Plasma and other Back behavior; target save state; Void's X1.5 target growth and UI feedback; Chicot/disabled behavior; seeded RNG API/name and base Guillotine odds.
Explicitly excluded work: Other early Blind callbacks, R5 Joker composition, Lucky RNG ownership, target formulas, persistence redesign, or unrelated Back/wrapper refactoring.
Required static validation: Lua 5.1 compile and all existing harnesses; focused real registered callbacks and full Back chain for Chronos below/at/above projected win threshold, cumulative prior chips, early nonwin but Joker-final win; one Guillotine roll per final call and post-Joker zero; custom/Plasma-style deck mutation and callback order; disabled, nil context, nonmatching canonical key, localized misleading name, zero values, original arguments and all return positions including trailing nil; Void winning/nonwinning, fractional final score flooring, and no real-hand/after controls; `git diff --check` and complete diff/status/stat review.
Required runtime/manual validation: Exact procedures in `docs/REGRESSION_TESTS.md`: baseline and Colosseum at eligible Ante 8 / White stake using EYEFTHTG and recorded salt; Chronos with final score below/at/above target and prior round chips; Guillotine seeded one-call success/failure trace; Void crossing target before queued ease and cold restart; Chicot, Blueprint, normal Plasma, extensible deck callbacks, with and without the number extension.
Known risks: Moving Chronos and Guillotine to post-Joker/deck scoring intentionally changes score-stage synergy and seeded RNG consumption. The static contract does not establish actual game animation/score-engine behavior; cold-game testing remains required.

Review: APPROVE by Sol High at production 0b6204ed03f92c191fa3ef39bd6ca3efd8709ba4. Complete immutable diff and surrounding/native framework review verified final dispatcher ordering, canonical/disabled rules, one seeded Guillotine roll, projected-score flooring, Void runtime ownership, Plasma mutation, Doppelganger cleanup and full return preservation. The floor correction and Plasma coverage were completed on the same branch before approval. Independent full Lua5.1 compilation, eight test files, TOML/payload/pattern checks and git diff --check passed. PR https://github.com/benedictdavon/balatro-reality-warp/pull/10. Shared GitHub author identity cannot submit a separate GitHub self-approval; this is the documented maintainer/agent review, with controlled merge authorized by the goal. R9 remains HUMAN_TEST_NEEDED for the exact game fixture. Push and PR automatic-review rejections were resolved on the same tool paths after fresh GitHub verification that the existing owned fork is public; no approval bypass or user approval request remains.


## Round action draw rules (#7 / R10)

Issue: ISSUE #7 Ouroboros ignores three-card rule; audit R10 possession callbacks issue per-card/repeated draws and Hook can transfer/count one Card twice.
Classification: Source-confirmed; final source fix remains HUMAN_TEST_NEEDED for real native queue/scoring/save behavior.
Dependencies: Accepted encounter identity, disabled/owned effects and destruction contracts through main f863d0c. R6 ranks and R5 Joker calculation are independent unmerged local fixes, neither is used as a base.
Relevant files/functions: fused_blinds.lua Ouroboros registration/calculate/old draw wrapper; botg_possession.lua Serpent/Water/Hook; new focused core draw helper loaded before possession callbacks; Lovely native draw selection boundary; installed state_events draw and CardArea card-limit contracts.
Confirmed root cause: Numeric e is recomputed/ignored. drawing_cards count is a slot-cost budget, not an exact physical Card count with Negative/extra-slot cards. Serpent's after/per-card-discard requests duplicate ordinary refill. Hook samples global unchanged hand twice and delayed remove_card returns a specified Card even if no longer present, permitting duplicate emplacement.
Required behavior: One physical min(3, deck count) draw per valid post-play/discard DRAW_TO_HAND action, regardless remaining hand capacity, for enabled canonical Ouroboros or any live nondebuffed possessed Serpent. Register Ouroboros modifies_draw and preserve framework auto-refill suppression for live possession restriction. Use drawing_cards flags plus an owned native selection boundary after Steamodded's slot-cost loop so native draw queue/pending counters remain authoritative. Initial hands, packs, unrelated draws and disabled Ouroboros alone retain native behavior; a possession is independent of Blind disable. Serialize the completed action marker by accepted encounter ID and action counters to prevent duplicate calls/cold reload reissuing this draw. Multiple Serpents share one fixed-three restriction while retaining each individual +30 Chips. Water uses SMODS.draw_cards(4) exactly once per real action before calculation per owning Joker, with a serialized owner marker and non-copy/non-retrigger guards, scoped against restriction flags; multiple Waters each contribute four. Hook snapshots distinct eligible hand Cards once per owner/action, selects without replacement, synchronously commits verified hand-to-discard membership and sets its bonus from actual successful transfers before joker_main; multiple Hooks operate successively on remaining cards. No queued mutation of later encounters.
Behavior that must remain unchanged: Ouroboros face-down probability and disable flip cleanup, possession score benefits and independent eligibility, native draw callback/event/pending machinery, initial/packs/ordinary refill, seeded Hook choice stream per actual selection, no formal discard-context/hand-count charge added to Hook, existing Water zero-discards setup.
Explicitly excluded work: Familiar extra-draw N1 (own issue), RNG Lucky guarantee redesign, Arrow/ranks, Joker composition, unrelated possession effects and formatting.
Required static validation: Source extraction of installed native draw routine with injected own Lovely boundary (do not persist third-party source), real registered blind/sticker callbacks, exactly3/2/1/0 physical IDs including Negative/extra-slot cards and remaining-hand 0/2/4/6/overfull; initial/packs/disabled/noncanonical/nonfacing controls; same-action duplicate guard, next action, encounter change, JSON-like serialized marker reload; one restriction for multiple Serpents and no per-card discard/after requests; full native pending counter before/drain and auto-refill suppression; Water four per owner/copy/retrigger guards and combination with Serpent; Hook repeated-first sampler, one/zero cards, multiple Hooks, membership mutation, no duplicate IDs and bonus actual success. Lua5.1 compile, TOML/new patch match count, existing accepted-main harnesses by independent local runner if known unmerged N3 blocks the old aggregate driver; full diff/status/stat.
Required runtime/manual validation: EYEFTHTG+recorded salt, White stake, Colosseum Ante12+ forced Ouroboros; hand size8 and modifiers/Negative extra-slot playing Cards; play leaving0/2/4/6, discard1/5, deck0/1/2/3+, Chicot, initial and packs, cold save/restart at action/queue boundary. Separate each possession then combine multiple Serpents/Waters/Hooks, actual moved Card IDs, pending counters/callbacks and final score, ordinary/Chicot Blind. Record optional mods/version. No game execution claim.
Known risks: Lovely boundary requires installed Steamodded priority -10 to precede Reality Warp priority0, validate one unique resulting boundary. Exact-three physical draw intentionally bypasses hand capacity as tooltip/native Serpent contract. Hook now commits promised discards before scoring instead of merely counting scheduled transfers; this can change held-card effects to the intended order. SMODS.draw_cards Water remains queued; real pending/order/save codec needs human validation. N3 runner fix is local on R5, so source validation must explicitly identify old-driver limitation without importing unaccepted production dependencies.
