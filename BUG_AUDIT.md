# Reality Warp bug audit

Audit date: 2026-10-03 (Asia/Taipei). Analysis only; no production code changed.

## Scope and evidence

`ISSUE.md` was read completely, including its investigated non-bugs, proposed work order, and historical environment notes, before reaching conclusions. This report covers all twenty numbered items and A–C, plus closely related defects in Blind lifecycle, scoring, RNG, possession, and persistence.

Audited repository: `C:\Users\Davon\AppData\Roaming\Balatro\Mods\balatro-reality-warp`.

- Local branch: `main`, commit `8d732bd3fece32d63aeda285904ce1123a211084`.
- Read-only `git ls-remote` verified both `origin/main` (`benedictdavon/balatro-reality-warp`) and `upstream/main` (`Unknow1022/Balatro-Reality-Warp`) at that same commit during the audit.
- Tracked working-tree files matched `main`. `ISSUE.md` was already untracked. No applicable `AGENTS.md` was found in the repository or checked ancestor directories.
- Framework evidence comes from installed sibling `../smods` (its `version.lua` reports `26.829.0`), its Lua and Lovely patches, and generated `../lovely/dump` files. These dependencies are **outside this repository**. The version string alone does not identify every framework patch; the observed custom Small/Big support matters substantially below.
- No Balatro run, seed replay, save round trip, Amulet run, or optional-mod isolation experiment was performed. There is no discovered repository test suite for these systems. Source-confirmed defects are distinguished from unverified player symptoms. Historical `EYEFTHTG` is a reproduction candidate, not a reproduction achieved here.

All repository file references below are relative to the audited root and have one-based line numbers. Dependency references beginning `../` are supporting framework/game evidence, not Reality Warp implementation. Line spans identify the relevant implementation, not tested coverage.

Source-name shorthand used below resolves to: `battle_of_gods.lua` → `src/core/battle_of_gods.lua`; `utils.lua` → `src/core/utils.lua`; `botg_combat.lua`, `botg_familiars.lua`, `botg_possession.lua`, `black_market.lua` → the same filenames under `src/core`; `boss_blinds.lua` and `fused_blinds.lua` → `src/blinds`; `common.lua`, `rare.lua`, `secret.lua` → `src/jokers`; `decks.lua` → `src/decks/decks.lua`; `tags.lua` → `src/tags/tags.lua`; `jokerdisplay.lua` → `src/compat/jokerdisplay.lua`. Framework filenames are always identified separately.

Classification: **CONFIRMED** means the source establishes the defect under the stated conditions; **LIKELY** means important dependency or intent details remain unverified; **NEEDS RUNTIME REPRODUCTION** means the reported symptom is not established by the current source; **FIXED / STALE** means the old mechanism has been removed or the report concerns absent historical code; **NOT A BUG** means intentional behavior or feature work rather than an established defect.

## Results at a glance

| ISSUE.md item | Classification | Current-main conclusion |
|---|---|---|
| 1. Blind identity / duplicate schedulers | CONFIRMED | Conflicting writers and overwritten choices exist; the specific live display/effect mismatch still needs reproduction. |
| 2. Ares/Vessel forced discards | NEEDS RUNTIME REPRODUCTION | No direct Ares/Vessel Hook callback; Possessed Hook is an independent explanation. |
| 3. Athena target | CONFIRMED | Preview rolls shared definition state, activation rolls again. |
| 4. Net rank | CONFIRMED | Same two-roll defect, with no encounter-state persistence. |
| 5. Hubris preview/combat | CONFIRMED | Divergent calculators, caps, reset behavior, and semantic/slot boss tests. Big-slot Hubris depends on framework behavior. |
| 6. Chicot / disabled effects | CONFIRMED | Twelve normal/showdown calculate callbacks lack a runtime-disabled guard; consequences differ by callback. |
| 7. Ouroboros draw | CONFIRMED | Installed draw routine overwrites the explicit three-card argument. |
| 8. Helin exponent | LIKELY | `e_mult` is not a built-in installed Steamodded scoring key; actual big-number extension must be checked. |
| 9. Expired starter Perishables | LIKELY | Ordinary-slot historical trigger was corrected; broad showdown fallback and debuff clearing remain risky. Showdown refresh itself is intentional. |
| 10. Shortcut one-gap Straight | FIXED / STALE | Current fallback recognizes the reported hand. A separate framework-argument compatibility defect remains (R8). |
| 11. Baby Mark ~ten triggers | NEEDS RUNTIME REPRODUCTION | Mark returns XMult per scoring evaluation, not repetitions. |
| 12. Consumable stacking | NOT A BUG | Feature/compatibility gap; historical local stack implementations are absent from main. |
| 13. Dark Alchemy probability | CONFIRMED | Two extra Negative opportunities, broad poll scope, and ignored poll constraints violate an exact 10× model. |
| 14. Lucky One RNG | CONFIRMED | Active global guarantee bypasses all seed filtering and becomes stale relative to card state. |
| 15. Boss-use pollution | CONFIRMED | Discarded inner rolls count; final outer selections generally do not. |
| 16. Regular/fused overlap | CONFIRMED | Regular pool includes all non-showdown fused definitions. |
| 17. Eligibility | CONFIRMED | Custom selectors bypass eligibility; fused selector even bypasses bans. |
| 18. Overlapping Blind representations | CONFIRMED | Real inconsistencies exist, but multiple representations and slot-valued `get_type()` are not inherently bugs. |
| 19. Delayed effects | CONFIRMED | Effect closures lack encounter validation; actual cross-round manifestations require event-order testing. |
| 20. Stack badge alignment | FIXED / STALE | Historical local-v6 report, no native quantity-badge implementation to audit on main. |
| A. Black Hole exponent copies | NOT A BUG | Sequential exponent composition is expected, with floor/order qualifications. |
| B. Perfectionism replaces edition | NOT A BUG | Single-edition replacement is intentional. |
| C. Upgrade Roulette | NOT A BUG | `before` upgrades scoring enhanced cards; Stone special route and Glass terminal tier exist. |

## Framework contract and wrapper map

The loader `RealityWarp.lua:22–75` loads `utils`, `battle_of_gods`, possession, familiars, combat, and black market before Joker and Blind definitions; aliases are applied after loading. Consequently, wrappers capture earlier wrappers. Two definitions are not dead alternatives.

Relevant chains, outside to inside:

```text
reset_blinds:
  battle_of_gods:811 outer slot scheduler
    -> battle_of_gods:411 inner scheduler / familiar initialization
      -> framework/base reset

get_new_boss:
  battle_of_gods:801 ante > 1 showdown selector
    -> battle_of_gods:466 all-BOTG filtered showdown selector
      -> framework/base selector (outside BOTG)

create_UIBox_blind_choice:
  battle_of_gods:719 shared-definition multiplier mutation
    -> battle_of_gods:377 choice repair + Boss-only Hubris flag
      -> framework UI construction and loc_vars

Blind:set_blind:
  battle_of_gods:668 showdown requirement / Hubris / cap
    -> utils:866 sale reset / rod penalty / UI reset
      -> framework/base setup + definition set_blind

Blind:defeat:
  black_market:142 pending currency reward
    -> battle_of_gods:488 rewards / cleanse / identity rewrite
      -> utils:899 base defeat / delayed UI cleanup / familiar unlock
        -> framework defeat + blind_defeated context

Card:calculate_joker:
  botg_combat:76 glitch modifier
    -> botg_familiars:1249 familiar interception
      -> battle_of_gods:574 Apotheosis / Exalted early returns
        -> utils:1598 Blueprint gate / activation tracking
          -> framework/base calculation

draw_from_deck_to_hand:
  fused_blinds:551 Ouroboros numeric override
    -> utils:2901 ghost/Phone cleanup
      -> installed patched draw routine

Consumable UI use:
  Card:use_consumeable through utils:7626 Code hook and utils:1068 Mountain hook
    -> then SMODS.calculate_context({using_consumeable=true})
```

Steamodded `../smods/src/utils.lua:2474–2478` calls `obj:calculate(active_blind, context)`: `self` in a definition's calculate callback is the **shared definition**; its `blind` parameter is the **runtime instance**. There is no disabled check at this dispatch. In contrast, legacy definition `set_blind`, `disable`, `defeat`, `press_play`, `modify_hand`, and `debuff_hand` are invoked on `obj` by `../smods/lovely/blind.toml`. Base `press_play`, `modify_hand`, and `debuff_hand` have runtime-disabled checks before legacy dispatch; this does not suppress separate calculate-context dispatch.

`../smods/src/overrides.lua:2557–2647` emits `blind_disabled` after disabling, `blind_defeated` after defeat, and calculate contexts even when the base method returned for a disabled Blind. Cleanup must be allowed before an active-effect guard, and must be idempotent.

Installed Small/Big patches replace semantic `self.boss = not not blind.boss` with runtime **slot flags** (`../smods/lovely/blind.toml`, “Handle setting new blinds”; generated `../lovely/dump/blind.lua:113–116`). A boss definition in Big can have `active_blind.big == true` and `active_blind.boss == nil`. Steamodded itself returns the active slot from `Blind:get_type()` (`../smods/src/game_objects/blind.lua:124–135`). Therefore changing `get_type()` to semantic Boss globally would break Ante progression. Semantic checks should read `active_blind.config.blind.boss`, separately from slot checks.

## Validation of ISSUE.md

### 1. Battle of Gods Blind identity and conflicting schedulers — CONFIRMED

**Present code:** `battle_of_gods.lua:289–357, 374–481, 486–569, 717–844`; entry transition at `:1008–1035`; `decks.lua:554–580`; base selection in `../lovely/dump/functions/button_callbacks.lua:2562–2592`, base activation in `state_events.lua:280–282`.

**Execution:** The outer reset snapshots Boss defeat, calls the inner reset, then overwrites slots again for Ante > 1. The inner reset always rolls Small/Big/Boss in BOTG, including already completed slots. At Ante < 12 it uses filtered regular selections; at Ante >= 12 it uses fused selections. The outer reset instead assigns `Small=bl_big`, Big=random regular/fused/showdown, Boss=showdown. It refreshes non-Defeated slots on every reset, not only an explicit reroll. At Ante 1 the outer layer does not replace the inner model. At later partial resets, choices in Defeated slots can still change because the inner writer already replaced them. Skipped slots also qualify for the outer overwrite. Two nested `get_new_boss` wrappers use different policies; the later wrapper bypasses the earlier one at Ante > 1. UI repair writes missing/invalid choices during rendering. Defeat overwrites `round_resets.blind` for Small/Big.

**Root cause:** Two active generation policies plus selection, repair, and progression side effects sharing the same state without an encounter identity. RNG advancement and use-count changes survive discarded choices.

**Qualification:** Ordinary valid UI construction reads a choice definition and captures it as the select button's `ref_table`; selection assigns that captured object to `round_resets.blind`. Activation consumes that object. The duplicate reset alone does **not** establish that a visible Ares button activates Minotaur. The dangerous overwrite is confirmed; an actual display/active mismatch requires an intervening writer or stale UI, and must be logged rather than assumed.

**Interactions/regressions:** #3–5, #9, #15–19; skips, boss rerolls, rewards, Chicot, save restoration, framework custom slots. Replacing slot-valued type semantics outright would advance the Ante after Big-slot bosses. Removing an entire wrapper without preserving familiar initialization and Divine Ward would lose unrelated mode setup.

**Minimal reproduction:** Record all three choices and states immediately before/after one reset at Ante 1, 2, and 12; at Ante 2 mark Small Defeated and reset again. Confirm even its historical choice can change. Then log rendered key, button `ref_table.key`, selected definition key, active key, slot, and encounter token across select, skip, reroll, three defeats, and cold reload. Do not compare future `blind_choices` to an already completed encounter as if they were necessarily the same time slice.

**Fix direction:** One scheduler, disjoint eligible pools, explicit commit points and serialized encounter parameters; UI only reads. Preserve slot progression using framework state flags instead of rewriting actual encounter identity. Decide explicitly whether future slots refresh after a win; the current comment permits refresh, so stability between encounters is a product rule, while stability from preview to selection within an encounter is required.

### 2. Ares/Violet Vessel discard two cards — NEEDS RUNTIME REPRODUCTION

**Present code:** Ares `boss_blinds.lua:993–1033`; Minotaur `fused_blinds.lua:199–240`; vanilla Hook `../lovely/dump/blind.lua:504–529`; Possessed Hook `botg_possession.lua:102–142, 359–387`; possession drops `battle_of_gods.lua:534–543`.

**Execution/root cause candidates:** Ares handles `context.after` with a destruction roll, not `press_play` discards. Vessel's native behavior changes requirements. Minotaur queues Hook-like discards on `context.press_play`. Separately, a Joker with `possessed_hook` moves up to two hand cards to discard on `context.before`, irrespective of Blind key. A prior BOTG win can add this sticker; an unmapped god/fused boss falls back to a random possession. Thus correctly selected Ares or Vessel can coexist with intended Hook possession behavior. Delayed Minotaur events or stale selection remain candidates, not established causes.

**Interactions/regressions:** #1, #14, #19, possession and external retrigger mods. Chicot disables the Blind, not a Joker's possession downside. Suppressing every Hook-like action while Ares is active would remove intended possession mechanics.

**Minimal reproduction:** Replay `EYEFTHTG` if available, first with no possessions/familiar/optional mods. Force Ares and Vessel using verified active keys, then add Possessed Hook alone. Record event origin and whether the event uses `press_play` or `before`; count actual moved cards. Check queued Minotaur events at transitions. The possession case is NOT A BUG if it matches its tooltip; the unexplained historical case remains open.

**Fix direction:** Fix scheduling/encounter-bound events if those are responsible. Make possession downsides observable. Do not add an Ares-specific discard patch without identifying the emitting path.

### 3. Athena displayed hand differs from enforced hand — CONFIRMED

**Present code:** `boss_blinds.lua:1056–1152`; framework preview/HUD localization patches in `../smods/lovely/blind.toml`; RNG advancement in `../lovely/dump/functions/misc_functions.lua:328–343`.

**Execution:** Preview `loc_vars` lazily writes definition `self.target_hand`; base setup invokes localization again; definition `set_blind` unconditionally calls `pseudoseed`/`pseudorandom_element` again and updates HUD text. `modify_hand` then compares its poker-hand name to that definition field and debuffs Jokers. `pseudoseed` advances state, so an identical string does not replay the same roll. The two draws can coincide by chance. Two Athena slots share the same field; disabling/defeating one clears it. `calculate(after)` later queues a blanket Joker undebuff.

**Root cause:** Localization owns mutable gameplay state and activation replaces it. Definition state has process lifetime, not encounter lifetime.

**Interactions/regressions:** #1, #6, R1 persistence, R4 debuff ownership. Blueprint is affected indirectly when its copied Joker is debuffed. Using one global Athena field still fails when two slots or a future preview coexist.

**Minimal reproduction:** Force an Athena choice; record preview target and active definition target after selecting. Repeat until rolls differ; play the preview target and actual target separately with an ordinary score Joker. Reopen UI, put Athena in two slots, and cold reload before/during the fight.

**Fix direction:** Generate a target once in serialized slot/encounter state, read it in localization and enforcement, and retain it across reset/reload. Preserve Blessed exemptions and existing matching/nonmatching behavior.

### 4. Net displayed rank differs from destroyed rank — CONFIRMED

**Present code:** `boss_blinds.lua:1416–1454`; same framework localization and RNG paths as #3.

**Execution/root cause:** `loc_vars` rolls and caches definition `target_rank`; `set_blind` rolls again on the advancing RNG stream. `calculate(after)` compares `c.base.value` against the newly rolled definition value, sets `destroyed`, and dissolves matching scoring cards. There is no custom defeat/disable clear for the definition's cached rank, so later previews can retain an earlier encounter's rank until activation replaces it. No encounter parameters are serialized.

**Interactions/regressions:** #1, #6, R1, R7 destruction notifications, rank-changing Jokers/Arrow. Numeric and face ranks must use the framework's rank representation. The code targets `scoring_hand`, so unscored played cards are outside this destruction path; this differs from a literal reading of “Played cards.”

**Minimal reproduction:** Force Net, compare preview and post-setup target, score each rank, and repeat on a second Net encounter plus cold reload. Include one unscored card of the target rank to settle tooltip scope.

**Fix direction:** The same serialized encounter-parameter mechanism as Athena; use one stored target for display and action. Resolve played-versus-scored intent before broadening destruction, and use the supported removal lifecycle.

### 5. Hubris / Blind requirement preview differs from combat — CONFIRMED

**Present code:** `battle_of_gods.lua:359–405, 614–735`; `utils.lua:866–883`; `decks.lua:571–579`; preview formula `../lovely/dump/functions/UI_definitions.lua:1749`, runtime formula `../lovely/dump/blind.lua:136`.

**Execution:** The inner UI wrapper marks Hubris only for the Boss slot. `get_blind_amount` scales that base by `H=1+0.5*god_count`. The outer UI wrapper temporarily changes shared showdown `mult` to 5, or 8 for Chronos/Vessel. Preview multiplies base × definition multiplier × stake scaling. Runtime base setup instead uses the original definition multiplier, then the BOTG wrapper recomputes showdown chips with multiplier 5/8, omitting `starting_params.ante_scaling`; it additionally applies Hubris only if runtime `self.boss` is truthy, then caps the completed target. Preview caps the base before multiplication, so a high-Ante showdown preview can exceed `1e365` while combat is capped at `1e365`.

**Critical correction to ISSUE.md:** With the installed slot-flag framework, Big-slot bosses generally have runtime `self.boss == nil`, so Hubris is omitted in **both** Big preview and runtime. On a framework retaining semantic runtime `boss`, the reported Big-preview/runtime discrepancy follows directly. On this installation, missing semantic Big Hubris, showdown stake scaling, and cap disagreement are the stronger findings. “Divine” counting here means Legendary/Secret tests, not every card bearing a deity-style flag.

**Additional path:** Base callbacks/Card add/remove hooks can call `set_blind(nil,true)`. A regular Boss retains chips on reset in the base routine, but BOTG multiplies those chips by H again; showdown recalculation instead resets its dynamic target. See R3. Rod penalty is applied in the inner wrapper and overwritten by outer showdown calculation. Disabled guards also alter which correction applies.

**Interactions/regressions:** #18, possession Wall, Nectar/stake scaling, dynamic Void/Code targets, Chicot, Amulet, reset versus new encounter. `p_blind.mult` and `botg_hubris_in_blind_choice` restoration are not exception/reentrancy-safe.

**Minimal reproduction:** Compare preview and runtime for a regular/fused/showdown in Big and Boss, with 0/1/2 Legendary/Secret Jokers and stake scaling 1/2. Include Ante 24, a reset-only refresh, Rod carryover, Wall possession, and Chicot. Capture the actual definition boss metadata and runtime slot flags.

**Fix direction:** One pure requirement calculator for preview and initial combat, final cap after all initial multipliers, and separate persisted dynamic target adjustments. Reset-only refresh must not compound initial scaling or erase dynamic adjustments. Keep temporary definition mutation out of UI.

### 6. Disabled custom Blind effects continue — CONFIRMED

**Present code:** `boss_blinds.lua` calculate callbacks below; dispatch `../smods/src/utils.lua:2474–2478`; legacy disabled gates `../lovely/dump/blind.lua:504–508, 550–566`; framework contexts `../smods/src/overrides.lua:2559–2647`.

| Callback | Location | Effect still reachable through calculate with a disabled runtime Blind |
|---|---|---|
| Pole | 323–331 | Money loss on edition scoring cards. |
| Cube | 500–530 | Final chip/Mult halving. |
| Void | 554–565 | Target increase. |
| Phone | 613–631 | New scoring-card debuffs as well as cleanup. |
| Doppelgänger | 846–882 | Repicks target and marks a Joker; final penalty separately has a disabled check. |
| Ares | 993–1033 | Schedules card destruction. |
| Athena | 1098–1132 | Delayed undebuff/status; legacy wrong-hand enforcement is already gated. |
| Hades | 1228–1253 | After-hand destruction; stale definition nullify flag can also affect `before`. |
| Zeus | 1279–1295 | Enhancement removal. |
| Arrow | 1318–1348 | Rank mutation attempt; separate key lookup defect in R6. |
| Net | 1436–1454 | Card destruction. |
| Code | 1517–1543 | Joker destruction/target increase through the context path; the global use wrapper is separately gated. |

The issue's twelve-callback inventory is accurate. Magician checks the `blind` parameter. Poison checks the global active disabled flag. All twelve fused calculate callbacks include a runtime-disabled guard, with some cleanup before it.

**Root cause:** Treating framework context dispatch as disabled-aware when it is not. Missing guards are not equivalent to all listed punishments always surviving Chicot: Athena's legacy enforcement, Hades's legacy press/modify/debuff, and global Code wrapper have distinct gating.

**Interactions/regressions:** #19 queued work, R4 cleanup ownership, slot boss flags. Chicot at `setting_blind` uses the **definition** `context.blind.boss` (`../lovely/dump/card.lua:2896–2907`), so it can disable a Big-slot boss even when runtime `self.boss` is nil. Buying Chicot during a Blind uses runtime `.boss`, creating a framework-sensitive distinction. Do not put an unconditional return before required `blind_disabled`/`blind_defeated` cleanup.

**Minimal reproduction:** For each row, activate its relevant context with verified runtime disabled=true and assert no new penalty/mutation. In game test Chicot from the start, then disable between scheduling and event execution. Run the same checks enabled as positive controls, including each fused cleanup.

**Fix direction:** Guard active effects using the passed runtime Blind; handle owned cleanup separately and revalidate delayed callbacks. Do not globally skip all Blind calculate dispatch, since that would suppress restoration.

### 7. Ouroboros does not draw exactly three — CONFIRMED for installed framework

**Present code:** `fused_blinds.lua:507–559`; `utils.lua:2898–2913`; dependency `../smods/lovely/card_limit.toml:287–322`, generated draw function `../lovely/dump/functions/state_events.lua:302–338`, draw registration `../smods/src/game_objects/blind.lua:67–69`, `../smods/src/utils.lua:3931, 3995`.

**Execution:** Enabled Ouroboros plus any played/discarded hand and nil argument replaces the call with `orig_draw(min(deck_count,3))`. The underlying installed function starts with `hand_space=e` but then recomputes available space and overwrites `hand_space` at line 328. Only native Serpent gets the dedicated later override. Thus Ouroboros normally refills available space rather than obeying 3. Explicit-argument callers bypass its wrapper, and it does not check `G.STATE==DRAW_TO_HAND`, so unrelated draws after the first play can be affected in frameworks that honor e. Ouroboros also lacks `modifies_draw=true`, unlike native Serpent registration.

**Root cause:** Wrapping an argument no longer authoritative in Steamodded's draw pipeline.

**Interactions/regressions:** Possessed Serpent/Water (R10), hand card-limit accounting, Booster draw paths, deck exhaustion, Chicot. A direct extra draw event can double-draw alongside normal refill and desynchronize pending-card accounting.

**Minimal reproduction:** Hand size 8, leave 2 cards after playing; with at least 10 in deck, count cards actually transferred. Expected +3, installed refill can produce +6. Repeat discard-one, near-full hand, empty/fewer-than-three deck, hand modifiers, explicit draw requests, packs, disabled state, reload.

**Fix direction:** Implement one post-play/discard draw restriction through the framework's drawing-cards/card-limit mechanism, register draw modification, and retain initial-hand and pack behavior. Verify whether the intended rule permits exceeding normal hand capacity, as native Serpent does.

### 8. Helin exponent ignored with big numbers — LIKELY

**Present code:** `secret.lua:488–523`; Black Hole comparison `:250–288`; `jokerdisplay.lua:1289–1302`; Blueprint gate `utils.lua:249–270, 1598–1602` and wrapper chain above; framework scoring keys `../smods/src/utils.lua:1544–1600`.

**Execution/root cause:** Helin on `joker_main` returns `e_mult=power` whenever `to_big` exists (even if Mult is a small Lua number) or Mult is a table. It does not directly change Mult on this branch. Installed Steamodded's built-in scoring parameter keys omit `e_mult`, and Reality Warp does not register a handler for it. Native fallback directly floors `mult^power`. Both Helin and Black Hole allow Blueprint and have no calculate Blueprint exclusion. JokerDisplay merely presents the exponent, so a visible tooltip is not proof of scoring.

**Qualification:** Amulet or another big-number/scoring extension may register `e_mult`. Its runtime handler and supported version were not available in the inspected installation; lack of a base Steamodded key does not prove every Amulet environment ignores it. The issue's unconditional API conclusion is therefore too strong. Unsupported dispatch is established for bare installed SMODS; practical big-number behavior remains to verify.

**Interactions/regressions:** Blueprint ordering, later Joker/edition multipliers, R5 early-return wrappers, numeric metatables and floor handling. “End of scoring” currently means this Joker's `joker_main` position, not necessarily the final score stage. Moving to a final context changes composition and must preserve copying semantics deliberately.

**Minimal reproduction:** Trace recognized scoring keys with the actual big-number extension. Start Mult at 12, exclude all other score effects, test Helin alone and 1/2 Blueprint copies: 144, 20,736, 429,981,696. Test numeric and big-number Mult, late multipliers, reload, and JokerDisplay. Record whether e_mult is consumed.

**Fix direction:** Use a supported exponent effect for the installed big-number API or a verified live-Mult operation; establish desired stage/copy order. Leave Black Hole unchanged unless a separate failure is reproduced.

### 9. Starting Perishable Jokers revive — LIKELY residual; historical mechanism partly corrected

**Present code:** `decks.lua:615–624`; `battle_of_gods.lua:505–527, 546–552`; `utils.lua:1598–1602`; Athena and Phone undebuff paths in R4.

**Execution:** Current starters are **one Stencil and one Blueprint**, not two Stencils; both have perish_tally=4. On BOTG defeat, explicit showdown metadata permits the cleanse, which restores all Perishable tallies to `perishable_rounds or 5`, sets `j.debuff=false`, and removes Rental. The old “Boss slot alone” trigger has been replaced, but the fallback also treats a boss/Boss-slot fight at an Ante divisible by win_ante as showdown even without showdown metadata. BOTG win_ante is 24. Ordinary early Boss-slot victory no longer meets that fallback. Frequent actual showdowns can intentionally keep starters alive under the current scheduler.

**Root cause assessment:** Timer revival after a real showdown is intended Thanatos behavior. Remaining wrong eligibility can arise with a forced/other-mod non-showdown Boss at Ante 24; unconditional debuff clearing and Apotheosis can separately reactivate expired cards without correctly resetting the timer. The historical report cannot simply be marked confirmed-current.

**Interactions/regressions:** #1, #18, slot framework, rental billing, Athena/Phone, expiration debuff ownership, save/run state. Restricting all revival would remove an advertised mode reward; clearing debuff directly can also erase another system's legitimate debuff.

**Minimal reproduction:** Allow both current starters to expire in controlled non-showdowns; test regular/fused/showdown in Big and Boss and a forced non-showdown Boss at Ante 24. Record tally, perishable/rental flags and debuff separately before/after each victory. Add an expired unrelated Perishable, Rental-only, and Perishable+Rental. Test Apotheosis and Athena with expired Jokers.

**Fix direction:** Use authoritative encounter showdown metadata with an explicit documented fallback policy, and clear only expiration state legitimately reset by the cleanse. Regression-test the ordinary early-Boss correction before closing the historical item.

### 10. Shortcut rejects 10,9,8,7,5 — FIXED / STALE for the stated hand

**Present code:** `utils.lua:2265–2328`; framework `../smods/src/overrides.lua:624–687`; `_straight` call `../smods/src/game_object.lua:2989`.

**Execution:** The wrapper first calls the original detector. If that fails, it finds nondebuffed Shortcut, groups ranks, and scans ascending ranks with a single missing rank permitted between present ranks. In the reported hand the scan begins at 5, skips 6, then accepts 7/8/9/10, returning five cards. Four Fingers lowers its fallback requirement to four. The source directly removes the old failure mechanism; no game replay was performed.

**Root cause/history:** Old hand-detector override/compatibility behavior; current fallback handles this case. Its reset of `skipped_rank` on every found rank means it permits multiple separated one-rank gaps, matching Shortcut's gap-of-one rule; it does not mean a single total missing rank per hand. Two *consecutive* missing ranks should fail. ISSUE.md's “two missing ranks” test needs that clarification.

**Interactions/regressions:** Four Fingers, Colorful Street, custom ranks and wrap semantics. Current wrapper drops modern detector arguments; see R8. Avoid replacing the detector with fixed vanilla rank logic.

**Minimal reproduction:** Reported hand with/without/debuffed Shortcut; A,K,Q,J,9; A,2,3,4,6; a two-consecutive-rank gap; separated one-rank gaps; duplicate ranks; Four Fingers and Colorful Street combinations. Test framework explicit parameters/custom ranks separately.

**Fix direction:** No speculative patch for the historical hand. Preserve all framework arguments and delegate rank topology through the framework for the separate current compatibility defect.

### 11. Baby Mark triggers about ten times — NEEDS RUNTIME REPRODUCTION

**Present code:** `botg_familiars.lua:1226–1254, 1521–1559`; framework scoring repetitions `../smods/src/utils.lua:2216–2256`; mod enables Joker retriggers at `botg_familiars.lua:1242–1243`.

**Execution:** Familiar area registration appends once to the Joker-area list after checking for duplicates. Familiar cards route to `botg_calculate_familiar`. Baby Mark returns XMult only for an `individual` evaluation of a played face card; it returns no `repetitions`. Red Seal causes an additional actual evaluation; Polychrome affects scoring but is not itself a repetition source. Baby Bell explicitly returns one repetition, and Baby Acorn can retrigger a Joker. Framework retrigger paths or optional mods can produce more evaluations/messages.

**Root cause assessment:** No source evidence that Baby Mark independently generates ten repetitions. Animation alone cannot distinguish card rescoring, familiar retriggering, and repeated messages. The global familiar hook bypasses lower calculation wrappers for familiar cards, which should be considered in diagnostics.

**Interactions/regressions:** Red Seal, retrigger Jokers, profile Familiar level, JokerDisplay, global calc interception. Suppressing `context.individual` repeats would remove intended Mark bonuses on real retriggers.

**Minimal reproduction:** Baby Mark alone plus one unsealed King; then Red Seal, then Polychrome, then each other retrigger source. Count `SMODS.score_card` iterations, Mark callback evaluations, and status messages separately. Record registered area count and Familiar level; repeat after reload.

**Fix direction:** Fix duplicate dispatch only if counts prove it. Otherwise explain per-evaluation bonuses and the external repetition source; do not add an arbitrary once-per-hand Mark guard.

### 12. Consumable stacking / buried cards — NOT A BUG on current main; feature gap

**Relevant current code:** Ordinary generation/use wrappers `utils.lua:1528–1594, 1068 onward, 7626–7658`; copy/load compatibility `:2183–2197`; Potion-specific UI and run storage in `consumables/potions.lua`; Cauldron in `core/cauldron_synthesis.lua`. No upstream stack quantity model, representative/split use lifecycle, stack save codec, or described local v1–v6 implementation was found.

**Execution/root cause:** Current consumables remain real separate Cards under normal CardArea layout; many Negative copies remain numerous because no native stack feature exists. The buried/hitbox behavior described is from historical local visual-only patches, not present production code here. The correctness of Cartomancer/Incantation/Saturn versions or local v6 cannot be inferred from this repository.

**Interactions/regressions:** Code punishment must occur once per actual use; Perkeo copy-one semantics, use/sell, weighted selection, Observatory, save/load, Cauldron and Potion Pouch make a stack model a gameplay change. Excluding Potion/Job is sensible but not currently implemented stacking.

**Minimal reproduction:** With required mods only, create several Negative Tarot/Planet/Spectral copies and confirm separate objects. Test any candidate stack feature in isolation with use-one, sell-one, copying, reload, weighted random target selection, and Observatory. Add other stack mods only as separate compatibility tests.

**Fix direction:** A dedicated optional feature with explicit quantity serialization and one-copy lifecycle, preserving use callback counts. Do not mark absence as a confirmed upstream defect or port unseen local patches blindly.

### 13. Dark Alchemy does not implement a clean 10× Negative chance — CONFIRMED

**Present code:** `tags.lua:404–436`; `utils.lua:1528–1590, 1696–1719, 813, 1616–1618`; framework `../smods/src/overrides.lua:2233–2308`, vanilla edition weights in `../smods/src/game_object.lua:3664–3768`.

**Execution:** Tag sets a global active flag, generally through shop tag processing, and adds reroll-cost changes. The `poll_edition` wrapper makes an extra 3% × modifier Negative roll before ordinary polling. It ignores `_no_neg` and has no Joker/area restriction. Then `create_card`, after normal generation, voucher replacement and duplicate rerolls, gives remaining editionless nonforced Jokers in shop/packs another 3% Negative roll. Forced Jokers skip the latter but still may pass the global polling path. The wrapper drops the framework's fifth `_options` argument even when the tag is inactive.

**Derived check, not a Monte Carlo run:** With only vanilla editions, unit modifier/rate, and the inspected nonweighted poll path, weights 3/3/14/20 give base Negative `3/1000=0.003` and base uneditioned 0.96. If the flag is active throughout generation, the first wrapper yields `0.03 + 0.97*0.003 = 0.03291`; post-create gives another `0.97*0.96*0.03 = 0.027936`, for total **0.060846 (6.0846%)**, about 20.282× baseline, not 10×. This formula excludes custom edition pools, replacement rolls, forced cards, and activation timing; those alter exact rates, but cannot justify the duplicate opportunities as a universal 10× rule.

**Root cause:** Independent additive probability overrides and unrestricted global polling instead of edition-weight policy. UI/shop activation order may mean the initial stock gets different treatment from later rerolls.

**Interactions/regressions:** Aura/standard packs with no-Negative polling, custom edition options, shop vouchers, other edition mods, Lucky One (whose forced zero defeats these `>threshold` checks), and tag expiry. Rate fixes change seeded outcomes and must preserve exclusions/options.

**Minimal reproduction:** Trace initial shop and reroll creation with the active flag, all edition polls, and both custom rolls. With flag=true force a successful tag roll while `_no_neg=true` and observe illegal Negative. Pass a fifth options list with only Foil while inactive and verify forwarding. Derive the actual installed edition pool, then sample a large fixed-seed population only after removing duplicate paths.

**Fix direction:** One constrained edition-weight adjustment for qualifying Jokers, preserving all poll arguments and exclusions, with explicit activation/expiry. Document whether 10× means base probability or relative edition weight under modifiers.

### 14. Lucky One consumes guarantees on unrelated RNG — CONFIRMED

**Present code:** `utils.lua:2330–2383`; `rare.lua:486–558`; `jokerdisplay.lua:877–905`; framework probability API `../smods/src/utils.lua:3224–3229`; scheduler/shop rolls such as `battle_of_gods.lua:270, 849–853`.

**Execution:** Five scored Clubs set both `card.ability.extra.guaranteed=true` and `G.GAME.lucky_one_guaranteed=true`. The next no-range `pseudorandom(seed)` consumes the global flag and returns 0 **before any seed filter or ownership/debuff check**. This includes numeric seeds produced by `pseudoseed`, shop/pack category rolls and decorative/global callers. The card's guaranteed flag is not cleared at consumption; the card can keep displaying Guaranteed until round end. The filtered path applies only to a legacy `extra.charges` model not created by current Lucky One config. Its broad substring list still classifies arbitrary strings containing `roll`/`luck` as probabilities.

**Root cause:** Boolean global state disconnected from the current card state and an untyped RNG entry point. Guaranteed zero makes `< odds` succeed but fails `>threshold` success paths. Multiple Lucky Ones collapse into a single global Boolean. Returning without delegating also skips normal seed advancement at that wrapper level.

**Adjacent tooltip mismatch:** Growth is tied to `other_card.lucky_trigger`, not every probability success; the current guarantee path does not increase XMult. Non-Lucky successes need explicit probability-result integration if the tooltip is literal.

**Interactions/regressions:** #1/15 RNG distribution, #13 edition generation, destructive boss probability outcomes, Blueprint, debuffed/sold Lucky One, save/load of the global and per-card flags. A single token mechanism must define stacking and whether harmful probabilities count.

**Minimal reproduction:** Set a current Lucky One guarantee by five Clubs, then make a known unrelated no-range RNG call; verify it returns 0, consumes global state, and leaves card state marked guaranteed. Repeat with Lucky One sold/debuffed, two copies, a `>threshold` event, an ordinary non-Lucky probability, and cold reload.

**Fix direction:** Consume owner-specific tokens through the supported probability API/contexts, update card/UI state atomically, preserve normal random sampling behavior, and define growth on qualifying probability results. Inventory old direct RNG-based probability effects before removing the compatibility path.

### 15. Discarded rolls pollute boss-use counters — CONFIRMED

**Present code:** `battle_of_gods.lua:289–331, 409–444, 737–844`; framework counter normalization `../smods/src/game_objects/blind.lua:71–121`.

**Execution/root cause:** Inner pre-12 reset increments filtered Small, Big and Boss use counts before the outer scheduler replaces their choices. At >=12 the inner fused selections do not increment, but inner filtered Boss still does. Outer regular/showdown/fused selectors generally never commit use counts at all. At Ante > 1 the later get_new_boss also avoids the counted filtered selector. Pollution is therefore both **phantom counted candidates** and **uncounted final encounters**, not merely extra increments. Framework's bosses_used metatable preserves flat-key compatibility here; flat syntax alone is not proof of a crash.

**Interactions/regressions:** #1, #14, #16–17, save persistence and long-run fairness. Whether “used” means committed preview or actually fought must be specified, particularly for skips and paid rerolls. Do not decrement arbitrary counts after the fact, since they can belong to earlier committed encounters.

**Minimal reproduction:** Snapshot counters and choices around reset at Antes 2/12; compare every increment with finalized slots. Reroll and skip, then save/reload. Confirm outer final choices can have unchanged counters while overwritten keys increment.

**Fix direction:** Pure candidate selection plus a single commit operation, respecting installed typed counters. Fold into scheduler repair before evaluating encounter distribution or seeded symptom reproduction.

### 16. Regular and fused pools overlap — CONFIRMED

**Present code:** `battle_of_gods.lua:333–357, 737–751, 777–790`; all twelve `fused_blinds.lua` definitions carry non-showdown boss metadata.

**Execution/root cause:** Big category is selected from three strings. The regular branch accepts every non-showdown `v.boss` except Wall/Vessel, including all fused bosses; the fused branch independently returns the explicit fused list. Before Ante 12, even the dedicated fused branch is available because the outer scheduler has only Ante > 1 gating.

**Interactions/regressions:** #15/17 eligibility/fairness and third-party Blind registration. Configured category odds cannot be inferred from final content frequency. A hardcoded list risks excluding future fused content, while classification by showdown alone is insufficient.

**Minimal reproduction:** Enumerate eligible regular keys and intersect with FUSED_BOSS_KEYS; force each Big category at Ante 2/12. Nonempty intersection proves overlap without a random sample.

**Fix direction:** Explicit mutually exclusive category metadata, one eligibility helper, and category availability by Ante. Decide category probabilities as policy rather than trying to fix bias with more RNG rolls.

### 17. Boss eligibility and bans bypassed — CONFIRMED

**Present code:** `battle_of_gods.lua:289–357, 737–790`; `boss_blinds.lua` metadata and Supreme `in_pool`; `utils.lua:5219–5254`; framework eligibility `../smods/src/utils/weights.lua:175–206`.

**Execution/root cause:** Filtered, regular and showdown selectors inspect only boss/showdown (plus some bans/exclusions); they do not call `SMODS.add_to_pool`, evaluate min/max or run `in_pool`. They sample strings/Boolean sets, so pseudorandom_element cannot automatically evaluate the original Blind object's in_pool. Fused selection merely checks key existence: it ignores banned_keys as well as min/max, mode and configuration. Custom boss toggle checks at `utils:5244` are bypassed. The outer fused category can produce Ante-12 definitions at Ante 2.

**Qualification:** A showdown scheduler intentionally overriding vanilla modulo-win-Ante rules is legitimate mode policy, not inherently a bug. Some Supreme own `in_pool` callbacks supersede the class-wide config hook; enforce configuration centrally rather than assuming inheritance handles every definition.

**Interactions/regressions:** #1/16, challenged banned keys, optional mod restrictions, empty pools. Existing fallbacks (`bl_hook`, `bl_vessel`, `bl_cerulean_bell`) can also violate bans, and must be checked. Applying every ordinary vanilla showdown-eligibility rule unchanged would empty intentional BOTG showdown slots.

**Minimal reproduction:** Ban all but one fused key and call get_new_fused_boss; turn custom bosses off; enumerate candidates below min/above max; register a test Blind with in_pool=false. Check regular/showdown/fused and empty-pool fallback independently in a test harness.

**Fix direction:** Central eligible-candidate construction using framework pool contracts and an explicit BOTG showdown override. Respect bans/configuration in every category and fallback; handle an empty category without silently selecting prohibited content.

### 18. Multiple Blind representations disagree — CONFIRMED, with important contract correction

**Present code:** `battle_of_gods.lua:474–481, 506–509, 562–566, 668–687`; `utils.lua:866–916, 1621–1622, 7554–7605`; `black_market.lua:119–155`; installed slot metadata described above.

**Execution/root cause:** Selection state is a future-slot schedule; round_resets.blind is a selected definition; active Blind is a runtime object; its config points at shared definition. They are legitimately separate objects and need explicit conversion rather than literal object equality. The defeat hook deliberately rewrites selected definition to vanilla slot identity. Runtime `.boss` in installed SMODS denotes slot, whereas definition `.boss` denotes semantic category. Reusing `.boss` for Hubris/counterattack/EXP/market semantics loses Big-slot boss status. Global `get_type` override additionally returns the active slot even for a different Blind object, whereas Steamodded limits its active-slot behavior to the active instance.

**Concrete interaction:** `black_market:127–133` classifies Big-slot showdowns as Big payouts under installed runtime flags, despite README's showdown reward description; confirm whether reward policy is slot or semantic category. UI reset in `utils:879–880` can clear newly selected Doppelgänger target state for non-Boss slots. See R11 for independent canonical-key failures.

**Regression warning:** `get_type` returning Small/Big/Boss slot is correct for progression in this framework. Base end_round advances Antes when get_type is Boss. Globally forcing semantic Boss would end Antes early. `round_resets.blind` is a definition table, so ISSUE.md's equality invariant must compare keys at equivalent lifecycle points, not equate a string to an object or compare completed slots with refreshed previews.

**Minimal reproduction:** At Big-slot Ares/Minotaur/showdown, log slot, definition `.boss`, runtime `.boss/.big`, get_type, counters/reward/EXP, selection key and active key before/after defeat. Query get_type on a second nonactive Blind object. Cold reload and repeat.

**Fix direction:** Explicit current-slot, encounter-key and semantic-category helpers; retain progression API behavior and stop rewriting encounter keys. Separate reward policy and UI cleanup from identity and gameplay state.

### 19. Delayed boss effects outlive disable/encounter changes — CONFIRMED unsafe paths

**Present code:** Ares `boss_blinds.lua:1000–1026`; Athena `:1101–1130`; Code `:1523–1531`; Minotaur `fused_blinds.lua:203–220`; Iron Maiden `:405–419`; counterattack `botg_combat.lua:19–47`; delayed UI cleanup `utils.lua:902–908`.

**Execution/root cause:** Ares copies scoring-card references, then later destroys them without rechecking runtime disabled/key or encounter. Minotaur checks disabled only while queueing; the event later reads the then-current global hand and discards from it. Code queues destruction with no target-existence/encounter check. Athena's delayed cleanup undebuffs the then-current global Joker list. Iron Maiden later reads global played cards and applies money loss. Counterattack rechecks captured `self.disabled` and chips, but the runtime Blind object is reused; the same object can represent a different encounter when the event fires. UI cleanup can clear new Doppelgänger global state because it calls a function that mutates gameplay state.

**Interactions/regressions:** #1, #6, R1, R4, destruction/save timing, Doctor Jo rescue, external event scheduling. Queue delay alone does not prove a normal round transition races it: blocking order can prevent a manifestation. Yet direct disable after queueing is enough to show why entry guards are insufficient. Some after-score removals on a winning hand may be intended and should complete before defeat; blindly cancelling every event at win would change that rule.

**Minimal reproduction:** In a test/debug harness, capture each queued mutation, disable or select a new Blind before draining it, and verify no old encounter mutates the new hand/Jokers. In game, use an authorized disable consumable at the relevant timing and log event creation/execution tokens; test a winning hand separately. Cold restart tests lost pending effects, not just same-process resume.

**Fix direction:** Capture stable encounter ID, expected key, permitted phase and card IDs; revalidate them at mutation time. Define winning-hand completion semantics and settle permanent removals before save/transition. Cleanup should act on owned state and old targets, not whichever globals exist later.

### 20. Quantity badge alignment — FIXED / STALE

**Relevant code/search:** Current consumable UI wrappers in `utils.lua`/`potions.lua`; no upstream quantity badge or local-v6 stack representation was found. This item describes a correction in external historical local code, not production main.

**Execution/root cause:** The old representative badge placement cannot execute in this checkout. Its top-right anchoring and v6 top-center correction are historical claims, not verifiable current implementation.

**Interactions/regressions:** If #12 is implemented, card drag scaling, overlays, multiple-digit quantities and touch/controller focus could misplace a badge. Cosmetic fixes must not mask hidden duplicate Cards.

**Minimal reproduction:** On a future stacking branch, compare quantities 2/10/100 at normal/hover/drag scales and adjacent stacks, with a screenshot and hitbox inspection. No current-main runtime reproduction exists for this absent feature.

**Fix direction:** No production fix here; validate badge layout with the eventual quantity model.

### Investigated non-bugs A–C

**A. Black Hole + Blueprint — NOT A BUG.** `secret.lua:250–288` directly raises live Chips/Mult at each `joker_main` invocation and allows copying; `jokerdisplay.lua:1153 onward` displays its exponent. Three exponent applications mathematically compose as `x^(1.2^3)`, not `x^(1.2*3)`. This code floors each intermediate result and other Jokers/editions can intervene, so the ideal algebra is not always an exact numerical equality. Root cause of suspiciously large numbers is composition. Reproduce in a controlled lineup with the precise position/copy target and trace intermediate values. Fixing normal exponential growth would regress intended Blueprint behavior; no fix is warranted. Stage-label consistency is discussed under #8, not an established Black Hole score bug.

**B. Perfectionism replacing Polychrome with Negative — NOT A BUG.** `rare.lua:741–798` excludes Negative/self from candidates, prefers uneditioned cards, otherwise targets existing editions, chooses Polychrome or Negative, then calls `set_edition` once in an event. The single-edition model replaces Polychrome. Interactions include expanded Negative slots and Blueprint candidate exclusion. Reproduce with only an eligible Polychrome target and a successful Negative roll, then verify edition/slot count across reload. Preserving both editions would be a new mechanic and compatibility risk; no fix is proposed for replacement. Event ownership and probability behavior belong to #14/#19 rather than this expected result.

**C. Upgrade Roulette — NOT A BUG.** `common.lua:934–958` on `before` upgrades nondebuffed enhanced cards in scoring_hand, excluding Blueprint; chain Bonus→Mult→Wild→Lucky→Steel→Gold→Glass, Stone→Steel, Glass terminal. The scoring step can then observe the new enhancement. It does not alter unscored played cards. Reproduce Bonus/Stone/Glass plus an unscored enhanced card and Blueprint, and verify the enhancement before evaluation. Broadening to all played cards changes power and interactions with Zeus; no correction to the established pre-scoring behavior is warranted. Clarify tooltip scope only if a literal all-played requirement is intended.

## Additional closely related findings

These are independently actionable current paths, not a general code-quality review. Every R item is present in audited main unless explicitly dependency-qualified.

### R1. Encounter parameters are not persisted and shared definitions survive runs — CONFIRMED

**Code/path:** Athena/Net/Hades legacy fields in `boss_blinds.lua:1056–1073, 1187–1240, 1416–1431`; Doppelgänger target object `:811, 853–879`; framework `../lovely/dump/blind.lua:774–822` saves fixed runtime fields plus `effect`, not arbitrary definition fields. No Reality Warp Blind save/load override serializes these definition fields. UI rerolls can consequently change targets after a fresh process; same-process reload can appear correct because G.P_BLINDS still retains the old field. Net has no target clear at defeat; Hades has no set/disable/defeat initialization of its nullify flag.

**Root/interactions:** Runtime data on shared registered objects, and a direct Card reference inside G.GAME instead of a stable target ID. Doppelgänger reference aliasing after serialization is **LIKELY** to be wrong and needs an actual save round trip; this audit does not assert a serializer crash. Future-slot previews and two same-key encounters can share targets. Fused `blind.effect` is a better existing persistence location, but preview parameters also need serialized slot ownership.

**Test:** Cold restart in Athena/Net/Hades, compare exact targets/flags; start a second run in the same process; two same-key slots; load Doppelgänger and compare target object identity to the actual Joker in G.jokers.

**Fix/risk:** Serialize encounter-owned parameters and stable Card IDs, reconnect references on load, and reset only on encounter creation. Migration defaults must not silently reroll established targets; distinguish unknown old-save state from new fights.

### R2. Iron Maiden hand size is not restored on ordinary defeat; disable restoration can repeat — CONFIRMED

**Code/path:** `fused_blinds.lua:389–402` subtracts one hand size on setting_blind and adds one only on blind_disabled. `../smods/src/overrides.lua:2565–2568` sends blind_defeated, which its callback ignores. Base defeat restores native Manacle by name, not Iron Maiden. Thus an enabled Iron Maiden win leaves -1 size for subsequent rounds. Repeated disable dispatch can add +1 repeatedly. Obelisk/Leviathan also refund stored hands/discards on disable without clearing refund fields (`:157–169, 334–357`); double disable can refund twice, although round resets normally restore these round resources.

**Root/interactions:** Setup deltas lack a single owned applied/refunded state. Chicot ordering, Card resets, familiar hand-size modifiers and saved effect state matter.

**Test:** Record hand size, fight/win Iron Maiden, enter the next fight, repeat twice, then test disable→defeat and two disables. Compare current remaining hands/discards for Obelisk/Leviathan; include reload and Chicot present at setup.

**Fix/risk:** Persist an applied delta and reverse it once on disable or defeat. Refund only changes actually applied, using remaining resources where appropriate; unconditional restores can grant bonuses when setup was suppressed.

### R3. Reset-only Blind refresh compounds or erases target scaling — CONFIRMED

**Code/path:** `battle_of_gods.lua:668–693` calls base setup and applies target changes regardless of reset=true. Base `set_blind` only recalculates initial chips inside `if not reset` (`../lovely/dump/blind.lua:99–139`). Card add/remove can queue `set_blind(nil,true)` (`../lovely/dump/card.lua:818, 878`). Regular Boss chips get Hubris multiplied again; showdown chips are rebuilt from base, dropping Void/Code/Wall/Rod dynamic adjustments and stake scaling. This is a second source of #5 symptoms independent of preview rendering.

**Test:** A regular Boss with one Legendary: initialize, snapshot chips, call the ordinary Card add/remove refresh twice and compare. In Void or Code modify target, then refresh. Repeat disabled and with no Legendary.

**Fix/risk:** Separate initialization, recalculation of card debuffs, and explicit target modifiers. Store unmodified initial target and dynamic adjustments; prevent geometric growth while preserving intentional target recalculation when Joker inventory changes, if that is desired.

### R4. Blanket undebuff erases other systems' restrictions — CONFIRMED

**Code/path:** Athena setup/after/defeat/disable (`boss_blinds.lua:1077–1080, 1105–1108, 1137–1150`) sets all Joker debuffs false. Phone before marks cards; after and global cleanup (`:614–628`; `utils.lua:2598–2615`) set them false without preserving prior debuff reasons. Thanatos/Apotheosis also assign `j.debuff=false` (`battle_of_gods.lua:515, 552, 578`). An expired Perishable can therefore become active after an Athena hand even with zero perish_tally. Phone can temporarily override independently debuffed playing cards after it marks them.

**Root/interactions:** One mutable Boolean used as ownership. Expiration, possession, other mods and Blessed protection are conflated. Simply adding #6 guards would still leave unowned cleanup.

**Test:** With an expired Perishable in Athena, play a hand and inspect tally/debuff after cleanup. Start Phone with one independently debuffed scoring card; check its state after scoring. Disable between setup and cleanup and ensure only this Blind's contribution clears.

**Fix/risk:** Use framework debuff recalculation/ownership APIs; release only a Blind-specific reason. Preserve actual legitimate cleanse exemptions; otherwise fixes can re-debuff intentionally protected cards.

### R5. Apotheosis/Exalted interception replaces normal Joker calculation — CONFIRMED

**Code/path:** `battle_of_gods.lua:574–600` returns X2 for an ascended card or X1.25 for the leftmost Joker with a level>20 hand before reaching captured Card.calculate_joker. It omits that Joker's original bonus, permanent growth/side effects, lower Blueprint compatibility checks, and returned post effects. Blueprint copying a qualifying card can hit this early return rather than the copied card's actual effect. Combat wrapper (`botg_combat.lua:75–90`) and familiar wrapper (`botg_familiars.lua:1247–1254`) also drop the second return value and extra arguments when forwarding ordinary Jokers.

**Root/interactions:** Bonus hooks replace a compositional API rather than augmenting it. Helin/Black Hole tests in BOTG may fail for this reason even after exponent dispatch is repaired. Glitched calculation also lacks a debuff/compatibility guard and can manufacture a bonus after an underlying debuffed call returns nil; its per-hand behavior warrants runtime checks.

**Test:** Use a simple +Mult Joker leftmost with hand level 21, then ascended, then Blueprint copying it. Trace underlying callback invocation, bonus, scaling state, and both return values. Repeat with a Blueprint-incompatible/debuffed target and Glitched sticker.

**Fix/risk:** Add mode bonuses via supported independent contexts/effects, preserve underlying returns/varargs, and enforce copy/debuff rules. Composing X2/X1.25 changes current underpowered behavior; tests must specify ordering and avoid double application.

### R6. Arrow rank lookup uses invalid vanilla card keys — CONFIRMED for numeric/face targets

**Code/path:** `boss_blinds.lua:1320–1335` builds `Hearts_Queen` or `H_Queen`, `Spades_10` or `S_10`, etc. Registered vanilla card keys use short suit/rank codes (e.g. `H_Q`, `S_T`). Therefore Ace→King, King→Queen, Jack→10, and 2→Ace commonly find no base card; numeric 9→8 may work through `H_8`. This makes the effect rank-dependent even when enabled.

**Root/interactions:** Manual name-to-card-key reconstruction bypasses the framework rank/suit mapping. Other rank-changing effects and custom ranks complicate partial fixes.

**Test:** Enabled Arrow with scored 9, Jack, Queen, King, Ace and 2; compare keys and resulting ranks. Repeat with a custom rank and Chicot as a negative control.

**Fix/risk:** Use framework rank-changing APIs/actual registered rank codes; clarify 2→Ace wrap as policy. Correcting face transitions may be a substantial difficulty increase; cover #6 before changing disabled behavior.

### R7. Direct boss dissolution bypasses destruction-notification bookkeeping — LIKELY gameplay defect

**Code/path:** Ares/Net/Hades call dissolve/shatter directly (`boss_blinds.lua:1004–1011, 1241–1244, 1439–1443`) instead of the framework destroyed-card collection. Framework normal scoring removal sends `remove_playing_cards` for a collected list (`../lovely/dump/functions/state_events.lua:795–816`). These after-context removals occur later and do not explicitly send that context. Consequently Glass Joker/Canio and other removal-aware consumers may miss these removals. Some Card wrappers may observe dissolution; notification coverage must be measured, not inferred from disappearing sprites.

**Test:** Destroy a face card with Ares/Net/Hades while Canio is present; Glass destruction with Glass Joker; compare a standard destruction consumable and collect remove_playing_cards events/counts. Test winning hands and reload boundaries.

**Fix/risk:** Supported destruction stage/central removal API with exactly-once notifications and captured card set. Do not both emit manually and let the framework emit again; that would double permanent scaling and unlocks.

### R8. get_straight wrapper discards modern API parameters — CONFIRMED compatibility defect

**Code/path:** Framework `_straight` requests `get_straight(hand, SMODS.four_fingers('straight'), SMODS.shortcut(), SMODS.wrap_around_straight())` (`../smods/src/game_object.lua:2989`). Reality Warp's `utils.lua:2267–2268` accepts only hand and forwards only hand to a detector that supports min_length/skip/wrap (`../smods/src/overrides.lua:624`). Its hardcoded vanilla fallback rescues #10 but cannot generally rescue custom min lengths, wrap or custom rank topology. If the original defaults find a five-card Straight, the wrapper also returns early rather than preserving a requested stricter min_length.

**Test:** Direct explicit min_length=3 and min_length=6 calls, wrap-enabled ranks, custom-rank Shortcut/Four Fingers. Compare captured framework detector with wrapper. Keep #10's vanilla hand as a positive regression control.

**Fix/risk:** Preserve the full API and use framework mechanisms for Colorful Street additions. Returning more/different scoring cards can alter hand identity and flush combinations; test both detector output and final poker-hand classification.

### R9. Chronos and Guillotine each run at two scoring stages; Void checks before queued score addition — CONFIRMED duplicate paths, LIKELY Void timing defect

**Code/path:** Chronos legacy `modify_hand` (`boss_blinds.lua:946–966`) reduces pre-Joker base values if they meet its threshold; final Back hook (`utils.lua:7558–7578`) repeats the threshold/reduction after scoring. A hand meeting both can lose 0.90 twice on each component. Guillotine rolls at legacy modify_hand (`boss_blinds.lua:1374–1395`) and again at final Back stage (`utils.lua:7581–7596`), creating two chances and allowing later bonuses to recover from the earlier zero. Under ordinary independent 1/5 rolls this is a 36% chance of at least one hit, not one 20% roll; actual final-zero frequency depends on intervening scoring.

Void `boss_blinds.lua:555–558` compares live G.GAME.chips during `context.after`. The framework queues an ease of chips (`../lovely/dump/functions/state_events.lua:870–878`) before dispatching after synchronously (`:907–908`); it does not wait for the ease to finish. A winning hand can therefore raise the target while its score is still pending. This timing path is likely but requires a game/event-manager reproduction.

**Test:** For Chronos use base and final score safely above target and trace both reductions. For Guillotine trace per-hand RNG calls and force success/failure at each stage. For Void start below target with a hand that should cross it; log current chips, pending/final hand score and target during after and after queue drain.

**Fix/risk:** One final-score rule per encounter/hand, one stored probability result; compare Void against the settled/projected round total at a defined stage. Changing stage alters Joker synergy, target growth and RNG sequence; verify Chicot and Blueprint.

### R10. Possession draw/discard callbacks can issue repeated or duplicate transfers — CONFIRMED structural defects; exact transfers need runtime counting

**Code/path:** Possessed Serpent (`botg_possession.lua:288–293`) calls draw(3) on `context.after` **and each** `context.discard` callback, then ordinary refill still runs. Discard context is per discarded card (`../smods/lovely/better_calc.toml` discard calculations), so a five-card discard can request draw five times. Possessed Water (`:324–327`) requests draw(4) before scoring, also relying on the overwritten draw argument from #7. Possessed Hook (`:120–128`) samples the still-current global hand twice and schedules asynchronous transfers without removing the first candidate from a local pool, so it can choose the same Card twice and count two bonuses for one actual discard.

**Root/interactions:** Wrong lifecycle stage and asynchronous sampling. Multiple possessed Jokers can multiply requests; pending-draw accounting may clamp them but does not make them exactly three/four. Possessions are independent from Blind disable.

**Test:** One possessed Joker at a time; discard 1/5 cards, then play with 2 cards remaining. Count draw calls, pending draw counters, actual transferred cards and Hook selected IDs. Force repeated Hook choice and compare hook_bonus to actual discard count.

**Fix/risk:** One draw rule at the correct round action boundary through the same framework mechanism as #7; sample Hook targets without replacement and count successful distinct transfers. Define how multiple possession effects combine; don't silently disable their advertised upsides.

### R11. Canonical Blind keys are missing from several active-effect detectors — CONFIRMED

**Code/path:** Steamodded prefixes object keys before register (`../smods/src/game_object.lua:24–37, 65–72`); Blind register defaults `name=self.key` (`../smods/src/game_objects/blind.lua:22–24`). Reality Warp's custom Blind definitions omit an explicit name, using loc_txt.name only. Its clean-name registration wrapper changes **SMODS.Center**, not SMODS.Blind (`utils.lua:1884–1898`). Thus e.g. runtime name and definition key are `bl_reality_warp_doppelganger`; a display label is not the runtime name.

Doppelgänger activation detector (`utils.lua:1621–1622`) accepts display/short names or legacy `b_reality_warp_doppelganger`, omitting canonical `bl_reality_warp_doppelganger`. Final penalty hook recognizes the canonical key, but its activation flag is never set by this detector on normal registration. Mountain consumable detector (`:1069`) and Pincer destruction detectors (`:1795, 2401, 2558`) likewise omit canonical name/config-key checks. This can leave Mountain's next-hand penalty inactive and Pincer locked even after a playing card is destroyed. Pincer setup also lacks a Chicot exemption and can debuff Chicot before the setting_blind calculation.

**Root/interactions:** Inconsistent identity tests after identifier migration and confusing localized names with registered object identity. External name-rewriting mods can mask the defect. Global UI reset clearing Doppelgänger targets compounds it (#18/#19).

**Test:** Log actual name/config.blind.key immediately after each setup. For Doppelgänger trigger the selected +Mult Joker and inspect activation flag/final score; Mountain use a consumable then play; Pincer destroy a card through each supported route and observe unlock; start Pincer with Chicot. No external renamer in the baseline.

**Fix/risk:** One canonical active-key helper and per-Blind owned state. Preserve deliberate legacy aliases only at load/migration boundaries. Once dormant penalties become active, independently test #6, cleanup, and destruction notification so fixes don't expose destructive behavior while disabled.

### R12. Free reroll refunds by assigning dollars before delayed payment settles — NEEDS RUNTIME REPRODUCTION

**Code/path:** `battle_of_gods.lua:448–459` snapshots dollars, invokes original reroll, immediately assigns old dollars, and consumes divine_ward_free. Original reroll calls `ease_dollars(-10)` before queuing the new choice (`../lovely/dump/functions/button_callbacks.lua:2851–2881`). If easing charges asynchronously, the assignment precedes payment and the “free” reroll still costs money. The UI availability button remains the original affordability logic, so a free allowance may not permit clicking when poor; check the installed button conditions. Reset wrapper grants another free allowance on every reset, not explicitly once per Ante.

**Test:** At $0/$5/$20 with a free allowance, record button state and dollars before click, immediately afterward, and after queue drain. Repeat at a partial reset and Boss Tag reroll. Inspect voucher requirements independently from price.

**Fix/risk:** Pass/consume an explicit zero-cost reroll condition at the payment and UI checks, preserving asynchronous charge/other reroll behavior. This is downstream of the scheduler, since slot refresh currently obscures what a reroll actually changes.

### R13. The Code punishes one consumable twice and bypasses Eternal filtering — CONFIRMED

**Code/path:** Global `Card:use_consumeable` wrapper in `utils.lua:7623–7658` applies Code punishment after the original use. The normal UI subsequently calls `SMODS.calculate_context({using_consumeable=true})` (`../lovely/dump/functions/button_callbacks.lua:2268–2269`), reaching `boss_blinds.lua:1517–1543`, which applies a second punishment. With Code enabled, chips become `initial * 1.25 * 1.25` (subject to each floor), not one X1.25. Both paths can select/dissolve a Joker; depending on asynchronous removal, that can be two different Jokers or two removal attempts on one dying Joker. With Code disabled the global path skips, but the unguarded calculate path still punishes (#6).

The global wrapper prefers non-Eternal candidates but falls back to the entire lineup when none exist; its dissolution does not mark getting_sliced first. The calculate callback uses the entire lineup without Eternal filtering. Native dissolution has a conditional Joker-destruction context when getting_sliced is set, but these paths use different setup and do not consistently honor `SMODS.is_eternal`. Whether Code is meant to override Eternal is not stated in its tooltip and should be decided explicitly.

**Root/interactions:** Duplicate implementation at different callback layers, inconsistent target eligibility, stale delayed targets, Doctor Jo rescue, Potion/Job custom use paths and any future stack split-use path. A direct API use may trigger only the global path, explaining different results from clicking the UI.

**Test:** Enabled Code, three ordinary Jokers, one clicked consumable: log both call sites, exact target chips and selected Card IDs. Repeat direct use, Chicot, all-Eternal lineup, Doctor Jo and a Potion Pouch use. Count actual removals after events settle.

**Fix/risk:** One authoritative consume-use context with one punishment per real item, consistent Eternal/destruction rules and encounter-bound target validation. Preserve trigger coverage for custom use routes; removing either implementation blindly can leave those routes unpunished.

### R14. Ante-history wrapper marks the current hand as previously played before evaluation — CONFIRMED for Possessed Pillar; related Obelisk risk

**Code/path:** `utils.lua:7934–7959` wraps evaluate_play and marks every current G.play card's `ability.played_this_ante=true` **before** calling the original evaluation. Possessed Pillar's `individual` effect (`botg_possession.lua:89–99`) tests that same flag, so first-use cards receive the bonus advertised for cards played previously this Ante. The normal framework instead schedules played_this_ante marking after scoring (`../lovely/dump/functions/state_events.lua:910 onward`). Obelisk (`fused_blinds.lua:172–174`) also reads this flag to debuff previously played cards; an intervening recalc during the current hand can now debuff first-use cards, but that manifestation needs runtime reproduction.

**Root/interactions:** History is committed before consumers finish evaluating prior history. The global wrapper also marks unscored played cards; semantics should remain “played,” not arbitrarily change to “scored.” Ante reset clears the flag, and changing history timing affects vanilla Pillar, Obelisk and possession together.

**Test:** First hand of an Ante, Possessed Pillar and a card never played this Ante: trace flag before wrapper, during individual, and after completion. Repeat a second play of that card as the positive control. In Obelisk repeat with/without a mid-hand debuff recalculation and verify the first-use card is allowed. Save between hands and advance Ante.

**Fix/risk:** Read prior history during evaluation and commit it afterward, using the existing framework hook where possible. Preserve genuine prior-use bonuses/debuffs and save/Ante-clear behavior; correcting this will reduce an unintended Possessed Pillar bonus.

## Minimal controlled validation protocol

Use the audited commit and record the exact installed Steamodded/Lovely build, not just advertised versions. Start with required frameworks plus Reality Warp; add the actual supported big-number extension for BOTG/Helin numerical checks. Reintroduce Cartomancer, JokerDisplay, Incantation and other mods individually after the baseline. Record seed, stake, mod config (including new_runs seed salt in `utils.lua:5278–5286`), Familiar/profile level, possessions and Joker positions; the same visible seed alone is insufficient.

Diagnostic work for future fixes should be on a separate test branch/harness, not silently included in this analysis. Log lifecycle sequence, slot, schedule key, button key, selected key, runtime config key, definition category, runtime slot flags, disabled, encounter ID, target parameters, initial/current chips, RNG source, and event creation/execution encounter. Distinguish initial target changes, intentionally dynamic target changes, and prospective choices from the fight already in progress.

For every permanent-state boss effect test: enabled positive control; disabled at setup; disabled after enqueue; defeat; another encounter; same-process reload; **cold restart**; legitimate preexisting debuff; Blueprint if a Joker is involved. Check actual state/counts and notification callbacks, not tooltip/animation alone. Shared-definition persistence and delayed events make same-process testing deceptively reassuring.

## Dependency-aware remediation order

1. **Establish canonical identity and callback contracts first (#18, R11).** Separate slot semantics from boss/showdown semantics; use canonical keys and keep progression/get_type behavior. Add test-only lifecycle traces/assertions. Without this, tests can target the wrong category, and currently dormant hooks make Chicot/score tests falsely pass. Preserve evidence for #2 including possession origin.
2. **Repair encounter scheduling, commits and persistence together (#1, #15–17, R1).** One policy, one writer, disjoint eligible pools, explicit usage commits, stable serialized choices/parameters. Fold Athena/Net parameter generation (#3–4) into this encounter model. Decide future-slot refresh and old-save migration. This is the main prerequisite for trustworthy seeded Blind-specific reproductions and distribution tests.
3. **Make effect ownership and lifecycle cleanup reliable (#6, #19, R2, R4, R7, R13–14).** Active guards, encounter-bound events, idempotent disable/defeat restoration, owned debuffs, prior-history timing and exactly-once removals. Keep destructive boss effects disabled in development until their dormant-key repairs and guards are verified together. #2 leakage, #9 reactivation, and long-run hand-size drift cannot be diagnosed reliably while this layer corrupts state. Repair Code's duplicate use-context punishment here: one use must yield one +25% target and one destruction.
4. **Unify initial/dynamic requirements and refresh behavior (#5, R3), then scoring-stage rules (R9).** Depend on stable encounter/category state and cleanup. Incorporate stake scaling, Hubris, caps, Rod/Wall adjustments and reset-only semantics. Only then validate Void, Code and winning-hand interactions; their dynamic measurements remain unreliable while duplicate punishments or stale events exist.
5. **Repair compositional Joker interception (R5), then Helin (#8).** Preserve original effects, both return values and copy/debuff rules before scoring-copy tests. Confirm the actual Amulet/big-number API and desired stage. Helin can be investigated independently in a non-BOTG harness, but BOTG Blueprint conclusions depend on R5.
6. **Repair draw integration (#7, R10).** Depends on lifecycle/disabled correctness and a known framework draw contract. Share a draw mechanism between Ouroboros and possession effects, then test hand limits and queue accounting. Do not compensate by inserting additional draws.
7. **Repair probability ownership before measuring odds (#14, then #13).** This track can proceed independently of scheduler implementation, but rerun seeded scheduler/scoring regressions afterward because RNG consumption changes. Dark Alchemy statistics are not trustworthy while Lucky One intercepts arbitrary polls. Preserve full poll_edition options even for inactive tag state.
8. **Validate remaining individual behaviors (#2, #9–11, R6, R8, R12).** Retest unexplained discards with possessions separated; test corrected Perishable policy/debuff ownership; count Mark evaluations. Repair Arrow mapping and get_straight API forwarding with focused regression tests. Free reroll tests require stable schedule behavior. The reported Shortcut hand needs a regression check, not a speculative new detector.
9. **Keep optional stacking work separate (#12/#20).** It has no blocking relationship to the Blind audit and should not delay correctness fixes. Port only an inspected implementation and test copy/use/sell/save semantics. Preserve non-bugs A–C as controls.

The first reliable milestone is a reproducible, persisted encounter identity and lifecycle—not just deleting a duplicate wrapper. Completion criteria: keys agree across preview/button/selection/activation at equivalent times; no unexplained schedule writes; no discarded candidate increments; targets survive cold reload; semantic boss checks do not alter slot progression; disabled/old-encounter events cannot mutate the next fight; temporary state restores exactly once. Only then can historical Ares/Vessel symptoms and the dependent boss tests be closed with confidence.
