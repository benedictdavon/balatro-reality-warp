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
