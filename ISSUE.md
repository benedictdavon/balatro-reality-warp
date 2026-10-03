# Reality Warp / Witch Brew — Consolidated Issue Log

> **Purpose:** This file consolidates every concrete bug, suspected bug, compatibility issue, and structural problem we have discussed since the original Witch Brew Expansion debugging sessions, then maps those findings onto the current **Balatro: Reality Warp** codebase where possible.
>
> **Current upstream:** `Unknow1022/Balatro-Reality-Warp`
>
> **Historical names:** Witch Brew Expansion / Witcher Expansion → Balatro: Reality Warp
>
> **Audit date:** 2026-10-03
>
> This is intentionally more detailed than a normal GitHub issue. It is meant to be a working engineering backlog for a fork, with enough context to split each item into a dedicated issue/branch later.

---

## Status legend

- **CONFIRMED — CURRENT:** The behavior is supported by the current Reality Warp source and/or directly reproduced.
- **CONFIRMED — HISTORICAL:** Reproduced in Witch Brew, but current Reality Warp code has changed enough that it should be retested.
- **HIGH-CONFIDENCE STRUCTURAL ISSUE:** Source contains conflicting state/logic that can directly explain observed behavior.
- **SUSPECTED:** User-observed behavior is real, but the exact root cause has not yet been isolated.
- **LIKELY FIXED UPSTREAM:** Current Reality Warp appears to contain a relevant correction; regression test still recommended.
- **FEATURE / COMPATIBILITY GAP:** Not necessarily an original mod bug, but something needed for practical use.

---

# 1. Battle of Gods / Colosseum can display one Blind while a different Blind or effect is actually active

**Status:** **HIGH-CONFIDENCE STRUCTURAL ISSUE — CURRENT**

**Priority:** Critical

**Primary file:** `src/core/battle_of_gods.lua`

## User-visible symptom

In Colosseum / Battle of Gods, the Blind displayed on the selection screen has at times not matched the Blind behavior experienced during the round.

Examples discussed:

- The UI can appear to show one boss while behavior associated with another boss occurs.
- Ares or Violet Vessel encounters appeared to trigger the two-random-card discard behavior associated with The Hook / The Minotaur.
- More generally, the displayed Blind, the selected Blind, the internal round state, and the effect being executed cannot currently be assumed to be the same object.

This is the most important system-level issue because many other boss bugs can be false symptoms of incorrect Blind state.

## Expected behavior

For every Blind slot:

```text
displayed blind key
    ==
selected blind key
    ==
G.GAME.round_resets.blind
    ==
G.GAME.blind.config.blind.key
    ==
effects being executed
```

The chosen Blind should remain stable from preview through selection and combat unless the player explicitly rerolls or skips it.

## Current source problem A: `reset_blinds()` is wrapped more than once

Reality Warp still contains two separate Battle-of-Gods layers that wrap `reset_blinds()`.

One generation system assigns:

- pre-Ante-12 Small / Big → regular custom bosses;
- Ante 12+ Small / Big → fused bosses;
- Boss → showdown.

Later in the same file, another wrapper calls the first wrapper and then applies a different model:

- Small slot → vanilla Big Blind;
- Big slot → regular boss / fused / showdown;
- Boss slot → showdown.

This means one call can conceptually become:

```text
vanilla reset_blinds()
    ↓
Battle of Gods generation model A
    ↓
blind choices assigned
    ↓
Battle of Gods generation model B
    ↓
some/all blind choices overwritten again
```

Besides making state difficult to reason about, the discarded first roll can still mutate tracking state such as boss usage counts.

## Current source problem B: `get_new_boss()` is also wrapped more than once

The same file contains multiple Battle-of-Gods overrides of `get_new_boss()`.

An earlier wrapper returns `get_new_boss_filtered(true)` whenever Battle of Gods is active.

A later wrapper applies a different condition and another showdown selector.

This creates nested behavior whose result depends on load order and wrapper capture order rather than one explicit policy.

## Current source problem C: two conflicting slot models coexist

There is no single authoritative design for what Small, Big, and Boss mean in Battle of Gods.

One part of the file treats Small and Big as custom boss slots.

Another part explicitly documents:

```text
Slot 1: always Big Blind
Slot 2: boss / fused / showdown
Slot 3: always showdown
```

Both systems are active.

## Current source problem D: completed custom Small/Big encounters are rewritten as vanilla blinds

In the Battle-of-Gods `Blind:defeat()` wrapper, Reality Warp still contains logic equivalent to:

```lua
if blind_on_deck == "Small" then
    round_resets.blind = bl_small
elseif blind_on_deck == "Big" then
    round_resets.blind = bl_big
end
```

This appears to exist to satisfy vanilla Balatro progression bookkeeping.

However, it means that immediately after defeating a custom boss in a Small/Big slot, the stored identity can become the vanilla Small Blind / Big Blind even though the encounter that actually happened was something else.

That is a dangerous state mutation because later hooks may inspect `round_resets.blind` and infer the wrong encounter.

## Current source problem E: `Blind:get_type()` returns the slot, not necessarily the semantic Blind type

Reality Warp overrides `Blind:get_type()` in Battle of Gods to return:

```text
G.GAME.blind_on_deck
```

Therefore, a real boss placed in the Big slot can report itself as `"Big"`.

This may be intentional for progression, but it conflates two different concepts:

- **slot type**: Small / Big / Boss;
- **actual Blind category**: vanilla big, normal boss, fused boss, showdown boss.

Any downstream code that uses `get_type()` to answer “is this a Boss?” may therefore receive the slot instead of the Blind's actual semantic category.

## Current source problem F: pool selection is not fully filtered

The current selectors primarily classify `G.P_BLINDS` using `v.boss` and showdown flags.

They do not consistently enforce all of:

- `boss.min`;
- `boss.max`;
- `in_pool()`;
- Battle-of-Gods-only restrictions;
- fused-vs-regular category membership;
- current Ante eligibility.

In particular, `get_botg_regular_boss()` accepts any non-showdown boss. Fused bosses are also non-showdown bosses, so the “regular boss” path can select a fused boss even though `"fused"` is separately offered as another branch.

The categories are therefore not mutually exclusive.

## Likely consequences

- displayed Blind differs from actual active Blind;
- unexpected boss behavior;
- wrong reroll result;
- wrong boss usage tracking;
- wrong boss payout/type handling;
- wrong showdown handling;
- stale effect state appearing to “leak” between bosses;
- confusing save/load behavior.

## Recommended fix direction

Create one Battle-of-Gods blind scheduler with a single source of truth.

Suggested model:

```lua
botg_slots = {
    Small = {key = "...", category = "..."},
    Big   = {key = "...", category = "..."},
    Boss  = {key = "...", category = "..."}
}
```

Only one function should roll a new set of slots.

Only explicit actions should mutate a slot:

- start a new Ante;
- defeat current Blind if the design intentionally rerolls remaining slots;
- skip;
- boss reroll;
- explicit mode transition.

Do not reroll while constructing UI.

Do not rewrite a custom Blind key to `bl_small` / `bl_big` merely to satisfy vanilla progression; patch the progression bookkeeping instead.

## Debug instrumentation recommended

Temporarily log at three points:

1. Blind-select UI construction;
2. `G.FUNCS.select_blind`;
3. `Blind:set_blind`.

Log:

```text
slot
blind_choices[slot]
round_resets.blind.key
active G.GAME.blind.config.blind.key
active name
active boss/showdown flags
disabled
ante
round
```

A mismatch should be treated as a hard assertion failure while debugging.

## Validation

Test at minimum:

- regular pre-fused Ante;
- Ante 12+ fused pool;
- Big-slot boss;
- Big-slot fused boss;
- Big-slot showdown;
- Boss-slot showdown;
- boss reroll;
- skip;
- save/reload on Blind Select;
- save/reload during a Blind;
- three consecutive Blind defeats.

---

# 2. Ares / Violet Vessel sometimes behave like The Hook / Minotaur and discard two random cards

**Status:** **CONFIRMED — HISTORICAL / NEEDS REALITY WARP RETEST**

**Priority:** High

**Historical reproduction seed:** `EYEFTHTG`

## User-visible symptom

During a run, encounters shown as **Ares** and **Violet Vessel** unexpectedly discarded two random cards when a hand was played.

That behavior belongs to The Hook / Minotaur family, not Ares or Violet Vessel.

## Why this is significant

This is stronger than a cosmetic display bug. It indicates that either:

1. the active Blind object was not the Blind shown in the UI;
2. an old Blind callback remained active;
3. a global hook was checking stale state;
4. Battle-of-Gods selection state changed after the preview was rendered.

## Historical analysis

The Minotaur explicitly implements Hook-like behavior: on play, it chooses and discards two random cards.

Ares should instead have a chance to destroy scored cards after scoring.

Violet Vessel should not perform Hook-style random discards.

Therefore the observed two-card discard strongly points to wrong Blind state or effect leakage.

## Current Reality Warp relevance

Reality Warp has migrated many fused Blind behaviors into newer `calculate(self, blind, context)` callbacks, which reduces one possible source of leakage.

However, the broader Battle-of-Gods state inconsistencies described in Issue #1 are still present.

Therefore this should be retested after fixing Issue #1 before making an Ares-specific patch.

## Validation

When the displayed Blind is Ares or Violet Vessel:

- inspect/log the active Blind key;
- verify no `context.press_play` Minotaur logic runs;
- play 20+ hands if practical;
- confirm zero Hook-style forced discards.

---

# 3. Athena can display one required poker hand and enforce another

**Status:** **CONFIRMED — CURRENT**

**Priority:** High

**Primary file:** `src/blinds/boss_blinds.lua`

## User-visible symptom

Athena's Blind description can show one required hand, while gameplay can use a different target.

Example:

```text
Blind Select:
Must play Straight
```

but the active Blind may internally require:

```text
Flush
```

## Root cause

Athena chooses `self.target_hand` in `loc_vars()` so that the Blind description can render the target.

Then `set_blind()` chooses `self.target_hand` again.

Even if both calls use similar seeds, state such as round counters and call timing can differ. More importantly, the architecture unnecessarily rolls gameplay state from a localization function and then rerolls it at activation.

A localization function should not be responsible for establishing authoritative encounter state.

## Expected behavior

Athena's target should be generated exactly once for the encounter.

The preview, HUD text, and scoring logic should all read the same stored value.

## Recommended fix

Generate the target as part of Blind-slot creation or another authoritative encounter-initialization step.

Store it in run state keyed to the specific slot / encounter, for example:

```lua
G.GAME.botg_blind_params[slot] = {
    key = blind_key,
    athena_target_hand = "Straight"
}
```

`loc_vars()` should only read this value.

`set_blind()` should reuse it rather than roll again.

## Validation

- open Blind Select and record displayed target;
- enter Athena;
- inspect active `target_hand`;
- play displayed target → Jokers should not be debuffed;
- play another hand → Jokers should be debuffed;
- save/reload before selecting Athena and verify target does not change.

---

# 4. The Net can display one target rank and destroy another

**Status:** **CONFIRMED — CURRENT**

**Priority:** High

**Primary file:** `src/blinds/boss_blinds.lua`

## User-visible symptom

The Net can preview a specific rank to be destroyed after scoring, but the actual active Blind can use another rank.

Example:

```text
Preview: Kings are destroyed
Actual internal target after set_blind(): 8
```

## Root cause

This mirrors Athena.

`loc_vars()` initializes `self.target_rank` when the Blind description is rendered.

`set_blind()` then generates `self.target_rank` again.

## Expected behavior

Target rank is generated once and remains immutable for that encounter.

## Recommended fix

Use the same encounter-parameter system as Athena.

The description should never create gameplay state.

## Validation

- note preview rank;
- inspect target rank immediately after `Blind:set_blind`;
- score both the displayed rank and a non-target rank;
- repeat across save/reload.

---

# 5. Godly Hubris / Blind chip requirement can differ between preview and actual combat

**Status:** **HIGH-CONFIDENCE STRUCTURAL ISSUE — CURRENT**

**Priority:** High

**Primary file:** `src/core/battle_of_gods.lua`

## Problem

Battle of Gods can place actual Boss / Showdown objects into slots that are not the vanilla `"Boss"` slot.

The UI-side Hubris handling is gated differently from the combat-side Hubris handling.

One UI wrapper marks `botg_hubris_in_blind_choice` only when constructing the `"Boss"` slot.

The active-Blind chip calculation later applies Godly Hubris based on the Blind being a boss.

Therefore a boss placed in `"Big"` can be previewed with one chip requirement and then receive additional scaling when combat starts.

## Expected behavior

The same pure function should calculate the target used by:

- Blind Select preview;
- HUD;
- actual `Blind:set_blind()` state.

There should be no temporary mutation of `p_blind.mult` solely to make the UI look right.

## Recommended fix

Create one function, conceptually:

```lua
get_botg_blind_chips(blind_key, slot, ante, run_state)
```

Both UI and runtime should call it without mutating shared Blind definitions.

## Validation

Compare displayed and actual `G.GAME.blind.chips` for:

- boss in Big slot;
- fused boss in Big slot;
- showdown in Big slot;
- showdown in Boss slot;
- 0, 1, 2, 3+ Divine/Legendary/Secret Jokers.

---

# 6. Chicot can visually disable custom bosses while their custom effects still execute

**Status:** **CONFIRMED — CURRENT FOR MANY CUSTOM BOSSES**

**Priority:** High

**Primary files:**

- `src/blinds/boss_blinds.lua`
- Steamodded Blind `calculate()` dispatch

## User-visible symptom

Chicot can mark a custom Blind as disabled, but some custom boss effects continue to happen.

Ares was specifically suspected to keep executing while disabled.

## Root cause

Steamodded dispatches custom Blind `calculate()` callbacks. The callback itself must respect the active Blind's disabled state.

Reality Warp has improved this for its **fused** bosses: the current fused Blind implementations generally start with logic such as:

```lua
if blind.disabled then return end
```

However, many normal/showdown Reality Warp Blind `calculate()` functions still lack an equivalent guard.

## Current Reality Warp audit

At the time of this audit, the following custom boss `calculate()` callbacks did **not** contain a disabled guard:

- The Pole
- The Cube
- The Void
- The Phone
- The Doppelgänger
- Ares
- Athena
- Hades
- Zeus
- The Arrow
- The Net
- The Code

Examples that do contain disabled-aware logic include:

- The Magician
- The Poison
- current fused Blind implementations

This list should be regenerated after each refactor rather than maintained manually forever.

## Expected behavior

When Chicot or another mechanism disables a Blind:

- no destructive effect;
- no score modification;
- no forced card debuff;
- no target increase;
- no card rank change;
- no Joker destruction;
- no lingering delayed effect generated after disable.

Cleanup effects may still need to run.

## Recommended fix

Use a consistent first line in all active-effect callbacks:

```lua
if blind.disabled then return end
```

For callbacks that need cleanup during the disable transition, handle the explicit `context.blind_disabled` path first, then return.

Avoid mixing:

```text
self.disabled
blind.disabled
G.GAME.blind.disabled
```

Choose the runtime Blind instance consistently.

## Validation

With Chicot active, individually test every custom boss.

Pay special attention to:

- Ares card destruction;
- Zeus enhancement removal;
- Arrow rank decrease;
- Net card destruction;
- Code consumable punishment;
- Void target increase;
- Cube score modification;
- Phone scoring-card debuff behavior;
- Hades random punishment.

---

# 7. Ouroboros does not reliably enforce “always draw 3 cards” after Play or Discard

**Status:** **CONFIRMED — HISTORICAL; CURRENT CODE STILL USES THE SAME BASIC HOOK**

**Priority:** High

**Primary file:** `src/blinds/fused_blinds.lua`

## User-visible symptom

The Ouroboros tooltip says:

> After Play or Discard, always draw 3 cards.

In testing, the game did not consistently draw exactly three cards.

## Historical implementation

The mod wraps:

```text
G.FUNCS.draw_from_deck_to_hand
```

and, when Ouroboros is active, calls the original function with an explicit value of up to 3.

The historical problem is that later/underlying draw logic may recompute normal available hand space, and not every draw route necessarily enters the wrapper with the assumptions the patch expects.

The hook also keys its behavior partly on whether the draw call receives an explicit `e` argument, which can make behavior depend on the caller rather than only on the Blind rule.

## Current Reality Warp

Current Reality Warp still contains a dedicated global `draw_from_deck_to_hand` wrapper for Ouroboros with essentially the same design.

Therefore this should still be treated as an active regression target even though other fused Blind logic was modernized.

## Expected behavior

After every valid Play or Discard during Ouroboros:

```text
draw min(3, number of cards remaining in deck)
```

independent of normal refill-to-hand-size behavior.

If the design instead intends “hand size becomes three,” the tooltip should be changed; current wording means **three cards drawn**.

## Recommended fix direction

Prefer a context/event-based implementation tied specifically to the post-play/post-discard draw event rather than globally altering all `draw_from_deck_to_hand` calls.

The Blind should calculate the intended number of cards directly and issue exactly that many draws.

## Validation

Test:

- play with 0 cards in hand after scoring;
- play leaving 2/4/6 cards in hand;
- discard 1 card;
- discard 5 cards;
- deck has fewer than 3 cards;
- hand-size modifiers;
- Chicot disabling Ouroboros;
- save/reload during the Blind.

---

# 8. Helin's exponent effect can do nothing in big-number mode

**Status:** **CONFIRMED — CURRENT**

**Priority:** High

**Primary file:** `src/jokers/secret.lua`

## User-visible symptom

Helin says it raises Mult to a power at the end of scoring, but in testing it sometimes visibly did nothing.

This was reproduced with Helin and Blueprint copies.

## Root cause

Current Reality Warp still has a branch conceptually equivalent to:

```lua
if to_big or type(mult) == "table" then
    return {
        e_mult = pow
    }
end
```

The problem is that the current Steamodded scoring API does not treat this returned `e_mult` field as the normal equivalent of directly exponentiating the live Mult value.

As a result, when the big-number path is active, Helin can return an unsupported/ignored scoring field instead of modifying Mult.

The non-big-number fallback directly performs:

```text
mult = mult ^ pow
```

which is why behavior can differ by number implementation / run state.

## Expected behavior

For power 2:

```text
12 Mult
→ 144 Mult
```

A Blueprint copying Helin should apply another exponent:

```text
12
→ 144
→ 20,736
```

Two Blueprint copies plus Helin:

```text
12
→ 144
→ 20,736
→ 429,981,696
```

## Important comparison

The mod's **Black Hole** secret Joker directly exponentiates live Chips and Mult and worked correctly in testing.

A test with Black Hole plus two Blueprint copies produced the exact expected score, so Black Hole should not be “fixed” as part of Helin.

## Recommended fix

Use a supported big-number-safe exponent operation on the live Mult value rather than returning `e_mult`.

The final implementation should be validated with the actual big-number library used by the current Steamodded environment.

## Validation

- Helin alone;
- one Blueprint;
- two Blueprints;
- low Mult;
- large `to_big` Mult;
- save/reload;
- JokerDisplay if enabled.

---

# 9. Colosseum starting Perishable Stencils can expire, then become active again

**Status:** **CONFIRMED — HISTORICAL; CURRENT REALITY WARP APPEARS PARTIALLY/LIKELY FIXED**

**Priority:** Medium–High

**Historical environment:**

- Witch Brew Expansion 3.2.1
- Colosseum Deck
- Battle of Gods
- Balatro 1.0.1o-FULL
- Steamodded v26.829.0
- Lovely 0.9.0
- Windows 11
- Cartomancer 4.173 / 4.17e
- JokerDisplay 1.10.9
- reproduction seed used in the investigation: `EYEFTHTG`

## User-visible symptom

The two starting Perishable Joker Stencils:

1. started with their short Perishable countdown;
2. reached zero;
3. became debuffed as expected;
4. later regained a Perishable timer and became usable again.

This allowed an expired starting Stencil to reactivate.

## Historical source explanation

The Colosseum starting Stencils were explicitly created as Perishable with a short timer.

The Battle-of-Gods Thanatos Hourglass cleanup was documented as a **Showdown** cleanse, but the historical implementation checked whether the current slot was simply `"Boss"`.

It then reset Perishable Jokers roughly as follows:

```text
perish_tally = normal perishable duration
debuff = false
```

Therefore an ordinary Boss-slot victory could reactivate an expired Perishable Joker.

## Current Reality Warp status

Current Reality Warp has changed this section.

It now computes an `is_showdown` condition using Blind/showdown metadata rather than only checking `blind_on_deck == "Boss"`.

That is directionally the correct fix.

However, the current condition is broad and includes an Ante/win-Ante fallback. The historical bug should therefore be regression-tested before closing it.

## Expected behavior

If Thanatos Hourglass is intended to cleanse only Showdowns:

- ordinary boss victory must not refresh expired Perishables;
- showdown victory may refresh them;
- the behavior should match tooltip/documentation exactly.

## Validation

Test:

- starting Stencil expiry;
- ordinary boss;
- fused boss;
- showdown;
- Boss-slot non-showdown if possible;
- other Perishable Jokers;
- Rental-only Joker;
- Perishable + Rental Joker.

---

# 10. Shortcut failed a valid one-gap Straight

**Status:** **CONFIRMED — HISTORICAL / NEEDS CURRENT RETEST**

**Priority:** Medium

## Historical user reproduction

With vanilla **Shortcut** active, the following hand was reported as **High Card** instead of a Straight:

```text
10♦ 9♥ 8♥ 7♣ 5♥
```

Shortcut should allow one rank gap, so the missing 6 should be skipped:

```text
5 - [6 skipped] - 7 - 8 - 9 - 10
```

## Why Witch Brew / Reality Warp is relevant

The mod overrides `get_straight()` in `src/core/utils.lua` to support custom mechanics such as Colorful Street and compatibility with Shortcut / Four Fingers.

Any global replacement of a core poker-hand detector can unintentionally alter vanilla Joker semantics.

## Current Reality Warp

Reality Warp still has a custom `get_straight()` wrapper, but the implementation has changed since the earliest Witch Brew report.

The current code explicitly detects Shortcut and contains one-gap handling.

Therefore this issue should be **retested before editing**.

## Expected behavior

With Shortcut active:

```text
10, 9, 8, 7, 5
```

must resolve as a Straight.

Without Shortcut it must not.

## Validation matrix

Test:

- `10 9 8 7 5`;
- `A K Q J 9`;
- `A 2 3 4 6`;
- two missing ranks → not Straight;
- duplicate ranks;
- Four Fingers + Shortcut;
- Colorful Street + Shortcut;
- debuffed Shortcut.

---

# 11. Baby Mark appeared to trigger roughly ten times from one Red Seal Polychrome King

**Status:** **SUSPECTED / NEEDS ISOLATED REPRODUCTION**

**Priority:** Medium

**Primary file:** `src/core/botg_familiars.lua`

## User-visible symptom

A Red Seal Polychrome King appeared to make **Baby Mark** trigger around ten times.

That looked like Baby Mark itself was retriggering the card repeatedly.

## Current intended behavior

Baby Mark's code is straightforward:

- on `context.individual`;
- while scoring a played card;
- if the card is a face card;
- return XMult based on Familiar level.

It does **not** itself return a repetition count.

By contrast, **Baby Bell** explicitly implements scored-card retriggers.

Therefore repeated Baby Mark messages may be a symptom of the same card genuinely being evaluated multiple times due to another retrigger source, rather than Baby Mark creating the retriggers.

## Possible explanations

- Red Seal retrigger;
- Baby Bell;
- another Joker/familiar retrigger;
- boss effect;
- repeated `context.individual` dispatch caused by another mod;
- UI/status text making repeated scoring events look like additional physical retriggers.

## Expected behavior

Baby Mark should apply once for each actual scoring evaluation of a face card.

It should not create repetitions by itself.

## Recommended diagnostic

Create a minimal run with:

- Baby Mark only;
- one face card without Red Seal;
- then add Red Seal;
- then add Polychrome;
- then add known retrigger effects one at a time.

Count both:

- actual card scoring evaluations;
- Baby Mark status messages.

Do not infer retrigger count from animation alone.

---

# 12. Consumable stacking compatibility / UI: no clean native stacking, and early visual-only patches buried cards

**Status:** **FEATURE / COMPATIBILITY GAP; LOCAL FIX WORKING**

**Priority:** Medium

## User need

Large numbers of Negative Tarot / Planet / Spectral consumables become difficult to manage visually.

The desired behavior is:

```text
actual copies:
A A A B B B B B C C

display:
A×3 B×5 C×2
```

with only one draggable representative card per stack.

Using the representative should decrement the quantity.

## External-mod investigation

Cartomancer 4.17e does not actually provide consumable stacking. Its “stack” functionality is primarily related to deck-view playing-card grouping.

Cartomancer contains compatibility references to Saturn, indicating Saturn is a separate stack implementation.

Incantation was reported not to work satisfactorily with Witch Brew.

## Problems with local visual-only versions v1–v4

The first local approach kept every underlying `Card` object and only changed positions.

That caused:

- cards visually peeking out;
- excessively wide stacks;
- overlapping hitboxes;
- hidden cards buried beneath stacks;
- unrelated consumables becoming difficult to see;
- multiple draggable cards occupying the same apparent location.

This was fundamentally a data-model problem, not a spacing problem.

## Correct architecture adopted in local v5/v6

After reviewing Saturn's approach, the local patch was rewritten so that:

```text
one real Card object = one visible stack representative
quantity = stored state on representative
```

Using or selling one item:

1. splits one temporary real card;
2. decrements representative quantity;
3. passes the temporary card through the normal Balatro use/sell path.

This eliminates buried duplicate Card objects.

Additional compatibility behavior was added for:

- save/load;
- selling one at a time;
- Perkeo/copying one copy rather than an entire stack;
- random selection weighted by represented quantity;
- Observatory scaling for stacked Planets.

Current local v6 only changes the badge position from v5, moving `×N` to the top-center of the card.

## Scope

Current local implementation intentionally stacks only **Negative**:

- Tarot;
- Planet;
- Spectral.

It excludes:

- Potion;
- Job;
- non-Negative consumables.

Potions/Jobs are excluded because Reality Warp has custom systems such as the Potion Pouch.

## Porting note

The local patch was originally named around Witch Brew identifiers.

When integrating into Reality Warp, rename identifiers cleanly and review all hooks against the current Reality Warp main branch.

Do not run Saturn/Incantation and the custom stack implementation simultaneously because both may wrap the same core functions.

---

# 13. Dark Alchemy Tag tooltip/code probability deserves verification

**Status:** **SOURCE INCONSISTENCY / NOT YET PROVEN WRONG**

**Priority:** Low–Medium

**Primary files:**

- `src/tags/tags.lua`
- `src/core/utils.lua`

## Observation

The Dark Alchemy Tag says:

> Jokers in next shop and booster packs have 10X chance to be Negative.

The custom application path currently performs an explicit random roll and applies Negative when the roll is above approximately `0.97`, i.e. an explicit ~3% threshold in that additional path.

Whether that is exactly “10×” depends on the intended/base Negative-generation probability and how this custom roll composes with normal edition generation.

## Why this is listed

This was noticed during the debugging sessions as a tooltip/code consistency concern.

It should not be changed until the base probability and intended stacking behavior are confirmed.

## Validation

Measure or derive:

- normal shop Negative chance;
- Dark Alchemy effective chance;
- whether normal edition polling still occurs before the custom roll;
- whether the intended behavior is additive, replacement, or multiplier-based.

Then either:

- implement exactly 10× base probability, or
- rewrite the tooltip to state the actual probability.

---

# 14. Lucky One probability logic has historically been broader than the tooltip suggests

**Status:** **SOURCE-RISK / NEEDS BEHAVIORAL TEST**

**Priority:** Low–Medium

**Primary file:** `src/core/utils.lua`

## Historical concern

Lucky One modifies global pseudorandom behavior to guarantee a probability event.

The historical implementation could consume the “guaranteed next roll” on a global `pseudorandom()` call that was not necessarily the gameplay probability the player expected.

Current Reality Warp has added filtering for many known probability seeds, which is an improvement.

However, the separate `G.GAME.lucky_one_guaranteed` path still warrants testing because global RNG wrappers are inherently sensitive to unrelated calls.

## Expected behavior

A stored guaranteed probability trigger should be consumed only by the intended qualifying probability event.

It should not be consumed by:

- UI randomness;
- cosmetic randomness;
- boss selection;
- unrelated shop generation;
- unrelated non-probability RNG.

## Validation

Instrument every consumption of the guarantee and record its seed/caller.

---

# 15. Battle-of-Gods boss usage counters can be polluted by blind rolls that are immediately overwritten

**Status:** **HIGH-CONFIDENCE STRUCTURAL ISSUE — CURRENT**

**Priority:** Medium

**Primary file:** `src/core/battle_of_gods.lua`

## Problem

`get_new_boss_filtered()` increments `G.GAME.bosses_used` when it returns a boss.

Because the first Battle-of-Gods `reset_blinds()` wrapper can roll blinds and the later wrapper can replace those choices, a Blind may count as “used” even if the player never saw or fought it.

## Consequences

The balancing algorithm that prefers least-used bosses can become skewed.

Over a long Colosseum run this can alter encounter distribution in ways that are difficult to reproduce.

## Expected behavior

Only a committed Blind choice should update usage tracking.

A temporary candidate that gets overwritten should not count.

## Recommended fix

Separate:

```text
choose candidate
```

from:

```text
commit candidate + increment usage
```

The scheduler should increment usage only when the slot assignment is finalized.

---

# 16. Fused and regular boss categories overlap in the current selector

**Status:** **CONFIRMED — CURRENT**

**Priority:** Medium

## Problem

The second Battle-of-Gods scheduler chooses Big-slot category from:

```text
boss / fused / showdown
```

However, the “regular boss” selector accepts any:

```text
v.boss == true-ish
AND not showdown
```

Fused bosses also satisfy this.

Therefore:

```text
"boss"
```

can return a fused boss, while:

```text
"fused"
```

also returns a fused boss.

## Consequence

Configured category probabilities are not the probabilities actually experienced by the player.

For example, if the design intends an equal one-third choice among regular/fused/showdown, fused bosses receive extra probability through the regular path.

## Recommended fix

Define explicit sets:

```text
vanilla/custom regular bosses
fused bosses
showdown bosses
```

and make them mutually exclusive.

---

# 17. Boss eligibility ignores or inconsistently applies `min`, `max`, and `in_pool()`

**Status:** **CONFIRMED — CURRENT**

**Priority:** Medium

## Problem

Custom Blind definitions contain eligibility metadata such as:

```text
boss.min
boss.max
in_pool()
showdown
```

Battle-of-Gods selectors do not consistently honor all of these.

This can result in content appearing outside the range its definition claims to support.

## Special concern

Supreme gods use `in_pool()` to restrict themselves to Battle of Gods, while fused bosses have Ante ranges. A generic selector should respect those contracts rather than reconstruct only part of the eligibility logic.

## Recommended fix

Create one eligibility helper that evaluates:

- banned keys;
- mode;
- `boss.min`;
- `boss.max`;
- showdown requirement;
- fused/regular category;
- `in_pool()` safely;
- any explicit exclusions.

All blind selectors should call that helper.

---

# 18. Battle-of-Gods state has too many overlapping representations of “what Blind are we fighting?”

**Status:** **STRUCTURAL DESIGN ISSUE — CURRENT**

**Priority:** Medium

This is related to Issue #1 but worth tracking explicitly because it affects many fixes.

At different moments, code uses:

- `G.GAME.blind_on_deck`;
- `G.GAME.round_resets.blind_choices[slot]`;
- `G.GAME.round_resets.blind`;
- `G.GAME.blind`;
- `G.GAME.blind.config.blind`;
- `Blind:get_type()`;
- `self.name`;
- `self.key`;
- center key;
- showdown flags on more than one object.

These are not guaranteed to describe the same concept.

## Recommended architecture

Define helpers with unambiguous names:

```text
get_current_slot()
get_selected_blind_key(slot)
get_active_blind_key()
is_active_blind_boss()
is_active_blind_showdown()
is_active_blind_fused()
```

Avoid inferring semantic type from slot name.

This refactor should be done before attempting many isolated boss patches.

---

# 19. Potential stale/delayed boss effects should be audited after Blind changes

**Status:** **SUSPECTED SYSTEMIC RISK**

**Priority:** Medium

Several Blind effects schedule delayed events with `G.E_MANAGER`.

If a Blind is disabled, replaced, defeated, or state-mutated after the event is scheduled but before it executes, that delayed callback may still affect cards/Jokers unless it revalidates the active Blind.

This is particularly relevant for destructive effects.

## Recommended rule

Any delayed boss callback that changes permanent state should re-check:

```text
current active blind key
disabled state
card still exists
encounter token/id still matches
```

before applying the effect.

A per-encounter generation/token would make this robust.

---

# 20. Consumable-stack quantity badge alignment was confusing

**Status:** **LOCAL PATCH FIXED IN v6**

**Priority:** Cosmetic

## Symptom

After real quantity stacking worked, the `×N` badge was anchored near the top-right and visually appeared to belong between cards.

## Desired behavior

The quantity must clearly belong to the representative card.

## Local correction

v6 moves the badge to top-center with a minimum badge width so:

```text
   ×10
[ CARD ]
```

remains visually centered.

This is not an upstream Reality Warp bug unless the custom stacking feature is merged.

---

# Investigated behaviors that should NOT currently be filed as bugs

The following were investigated during the same sessions but were either explained or behaved as intended.

## A. Black Hole + Blueprint exponent stacking

This initially looked suspicious because multiple `^1.2` applications produce very large values.

A concrete hand was calculated exactly and matched the observed score.

Three sequential `^1.2` effects compose as:

```text
x^(1.2^3) = x^1.728
```

They do not mean:

```text
x^(1.2 × 3)
```

No Black Hole bug was established.

## B. Perfectionism replacing Polychrome with Negative

Perfectionism can target a Joker that already has another edition and set it to Negative.

That replaces the previous edition.

This is consistent with the implementation; it is not currently considered a bug.

## C. Upgrade Roulette

The implementation upgrades scoring enhanced cards through its enhancement chain before scoring, so the new enhancement can apply immediately.

Stone has a special route to Steel; Glass is the terminal tier.

No confirmed bug was established from the discussion.

---

# Suggested branch / issue split

Do **not** fix all of the above in one branch.

Recommended work order:

```text
fix/colosseum-blind-state
    Issues 1, 3, 4, 5, 15, 16, 17, 18

fix/chicot-custom-blinds
    Issue 6

fix/ouroboros-draw
    Issue 7

fix/helin-exponent
    Issue 8

test/perishable-stencil-regression
    Issue 9

test/shortcut-straight
    Issue 10

test/baby-mark-retrigger
    Issue 11

feature/consumable-stacking
    Issues 12, 20

audit/dark-alchemy-probability
    Issue 13

audit/lucky-one-rng
    Issue 14

audit/delayed-blind-effects
    Issue 19
```

The Ares/Violet Vessel discard symptom in Issue #2 should first be retested after `fix/colosseum-blind-state`.

---

# Recommended first milestone

The first milestone should be:

> **Battle of Gods: one authoritative Blind state**

Definition of done:

- exactly one `reset_blinds()` Battle-of-Gods wrapper/pipeline;
- exactly one Battle-of-Gods boss-selection policy;
- no duplicate reroll of already-rendered encounter parameters;
- no custom Blind identity rewritten to vanilla `bl_small` / `bl_big`;
- displayed key == selected key == active key;
- mutually exclusive regular/fused/showdown pools;
- eligibility metadata respected;
- preview target == actual target;
- Athena / Net parameters immutable for the encounter;
- save/load preserves all three slot choices and encounter parameters;
- debug assertions show zero state mismatches across a multi-Ante Colosseum run.

Only after that milestone should individual boss-effect bugs be considered trustworthy to reproduce.

---

# Historical test environment notes

The earliest reported issues were observed across Witch Brew 3.2.1 and later 4.0 builds before the project was rebranded to Reality Warp.

Common environment during those reports:

```text
Balatro:      1.0.1o-FULL
Steamodded:   v26.829.0
Lovely:       0.9.0
OS:           Windows 11
Cartomancer:  4.17e / 4.173
JokerDisplay: 1.10.9
```

Not every issue was isolated with the other gameplay mods disabled, so regression tests should ideally begin with Reality Warp alone plus its required framework, then add optional mods.

---

# Current Reality Warp migration notes

Reality Warp is not a completely separate project. Its repository history shows a fresh-start commit containing the Witcher/Witch Brew codebase, followed by a broad identifier rename and subsequent updates.

Therefore historical Witch Brew bug reports remain valuable, but each one should be labeled as one of:

```text
still present in current Reality Warp source
likely fixed during migration
needs behavioral retest
```

Do not blindly apply old Witch Brew patches to Reality Warp without checking the current implementation first.

---

# Checklist before opening upstream PRs

For each fix:

- reproduce on current Reality Warp `main`;
- record seed if deterministic;
- test with only required mods first;
- add a minimal debug log if the bug is state-related;
- change one subsystem per branch;
- document expected vs actual behavior;
- test save/reload;
- test Chicot where relevant;
- test Blueprint where relevant;
- verify no unrelated global hook changed;
- keep old Witch Brew compatibility code out unless still necessary;
- avoid combining feature work with bug fixes.
