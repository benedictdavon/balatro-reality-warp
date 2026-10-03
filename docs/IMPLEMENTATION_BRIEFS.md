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
