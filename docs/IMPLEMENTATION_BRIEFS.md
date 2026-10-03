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
