# Reality Warp — Post-Sol Runtime Findings

Testing checkpoint:

- Repository: `benedictdavon/balatro-reality-warp`
- Branch tested: `main`
- Main commit: `f863d0c`
- Balatro: `1.0.1o-FULL`
- Steamodded: `26.829.0`
- Lovely: `0.9.0`
- Amulet: `3.6.2`
- JokerDisplay: `1.10.9`
- Platform: Windows
- Optional feature observed: `retrigger_joker`

This document contains findings discovered during manual gameplay after the first Sol stabilization round. It is intended to be handed back to Sol High after the current `/goal` pass finishes.

---

## Summary

| ID | Finding | Status | Priority |
|---|---|---|---|
| N3 | Adopted Familiar can remain shown as Locked | CONFIRMED BY RUNTIME + SOURCE | High |
| N4 | Multiple Echo Tags do not stack on the next non-Echo Tag | CONFIRMED BY RUNTIME + SOURCE | Medium |
| #9 | Starter Perishable Stencil/Blueprint do not expire normally | REOPENED / CONFIRMED BY RUNTIME | High |
| N5 | `$2` loss while fighting The Manacle | LIKELY NOT A BUG / NEEDS ISOLATION | Low |
| N6 | Hieroglyph lowers Ante but not BOTG requirement and rerolls Boss | CONFIRMED BY RUNTIME + SOURCE | High |
| N7 | Croupier/Dice sticker crashes due missing `dice.ogg` | CONFIRMED BY RUNTIME + SOURCE | Critical |
| N8 | Duplicate Jokers can appear in the same shop without Showman | CONFIRMED BY RUNTIME + SOURCE | High |
| N9 | Long runs progressively lose performance; cold restart restores it | CONFIRMED BY RUNTIME; RUNTIME ACCUMULATION/LEAK LIKELY | High |

Suggested implementation order:

1. N7 — hard crash
2. N6 — Ante/encounter compatibility regression
3. #9 — Perishable starter immortality
4. N8 — duplicate shop Joker generation
5. N3 — Familiar unlock persistence
6. N4 — Echo Tag stacking
7. N9 — performance profiling
8. N5 — only if controlled reproduction disproves the global counterattack explanation

---

# N3 — Adopted Familiar remains locked

**Status:** CONFIRMED BY RUNTIME + SOURCE

## Observed

A Familiar obtained through the Battle of Gods random Familiar reward could be adopted and used, but the Familiar card still displayed as **Locked**.

The Familiar could exist as the active companion despite not being permanently unlocked/discovered in the registered Familiar/profile state.

## Relevant code

Primary area:

```text
src/core/botg_familiars.lua
```

Battle of Gods can select a Familiar independently of its normal unlock condition.

The adoption path can create an active Familiar card instance and set instance properties such as:

```lua
card.discovered = true
card.unlocked = true
```

However, this does not necessarily update:

- the registered Familiar center;
- permanent profile discovery/unlock state;
- Nursery/collection state.

This creates an inconsistent state:

```text
Familiar reward appears
→ player adopts Familiar
→ Familiar becomes active
→ active instance works
→ registered/profile Familiar remains Locked
```

## Expected behavior

A design decision is required.

Preferred behavior:

> Successfully adopting a Familiar from a Battle of Gods Familiar reward permanently unlocks/discovers that Familiar.

Alternative:

> Random Familiar rewards may only offer already-unlocked Familiars.

The current state, where a Familiar is simultaneously active and locked, should not occur.

## Regression tests

1. Receive a previously locked Familiar through BOTG reward.
2. Adopt it.
3. Verify it becomes active.
4. Verify its effect works.
5. Verify its card/collection no longer shows Locked.
6. Verify Nursery recognizes it.
7. Quit Balatro completely.
8. Reload profile/run.
9. Verify unlock persists.

---

# N4 — Multiple Echo Tags do not stack on the next non-Echo Tag

**Status:** CONFIRMED BY RUNTIME + SOURCE

## Observed

Given:

```text
Echo Tag
Echo Tag
then Negative Tag
```

the result was:

```text
1 Echo Tag remains
3 Negative Tags
```

Only one Echo was consumed.

## Relevant code

Primary area:

```text
src/tags/tags.lua
```

The Echo Tag handler:

1. excludes Echo itself from triggering duplication;
2. searches stored Echo Tags;
3. duplicates the acquired non-Echo Tag twice;
4. marks one Echo as triggered;
5. executes `break`.

The `break` means only one stored Echo processes the acquired Tag.

## Recommended semantics

Avoid recursive Echo → Echo duplication.

However, all pending Echo Tags should independently trigger on the next **non-Echo** Tag.

Expected:

```text
2 Echo + 1 Negative
=
1 original Negative
+2 from Echo #1
+2 from Echo #2
=
5 Negative
```

Both Echo Tags should then be consumed.

Recommended rule:

> Echo Tags do not duplicate Echo Tags, but multiple pending Echo Tags stack on the next non-Echo Tag.

## Regression tests

```text
1 Echo + Negative -> 3 Negative, 0 Echo
2 Echo + Negative -> 5 Negative, 0 Echo
3 Echo + Negative -> 7 Negative, 0 Echo
Echo + Echo -> no recursive duplication
Echo + Echo + non-Echo -> both Echoes trigger on the non-Echo Tag
```

Suggested branch:

```text
fix/echo-tag-stacking
```

Suggested commit:

```text
fix: stack pending Echo Tags
```

---

# Issue #9 — Starter Perishable Stencil and Blueprint do not expire normally

**Status:** REOPENED / CONFIRMED BY RUNTIME

This upgrades the previous source-only suspicion to an actual gameplay reproduction.

## Observed

The Battle of Gods starting:

```text
Joker Stencil
Blueprint
```

remain functional beyond the expected Perishable lifetime rather than becoming permanently debuffed when the Perishable countdown reaches zero.

## Starter setup

Relevant file:

```text
src/decks/decks.lua
```

The starter Jokers are explicitly made Perishable and appear to be initialized with:

```lua
perish_tally = 4
```

This should also be reviewed against the intended normal duration of 5 rounds.

## Likely root cause

Relevant area:

```text
src/core/battle_of_gods.lua
```

Thanatos Hourglass refreshes Perishable Jokers after a semantic Showdown:

```lua
j.ability.perish_tally = G.GAME.perishable_rounds or 5
SMODS.recalc_debuff(j)
```

The current Battle of Gods encounter model places a Showdown in the Boss slot each Ante.

This creates the cycle:

```text
Perishable countdown decreases
↓
Boss-slot Showdown defeated
↓
Thanatos resets perish_tally to 5
↓
next Ante
↓
repeat
```

The starters can therefore remain active indefinitely.

## Design question

Determine whether Thanatos cleansing should apply:

- to every BOTG Boss-slot Showdown;
- only milestone/final Showdowns;
- only already-expired Perishables;
- only specific reward events;
- or whether starter Perishables should be exempt.

The current combination:

```text
Boss slot always Showdown
+
Showdown refreshes all Perishables
```

makes Perishable substantially less meaningful in Battle of Gods.

## Regression tests

- Allow both starter Jokers to naturally reach zero.
- Verify their effects stop when expired.
- Defeat regular/fused/showdown Blinds and inspect `perish_tally`.
- Test a milestone/final Showdown separately.
- Verify Rental cleanse behavior remains correct.
- Cold restart with partially depleted Perishable tally.
- Verify intended starting tally: `4` versus normal `5`.

Suggested branch:

```text
fix/perishable-starter-refresh
```

---

# N5 — `$2` loss while fighting The Manacle

**Status:** LIKELY NOT A BUG / NEEDS ISOLATION

## Initial observation

During The Manacle, with the starter Perishable Stencil and Blueprint, playing a hand appeared to deduct `$2`.

The Jokers did **not** have a Parasitic sticker, so the earlier Parasitic hypothesis is rejected.

## Current source explanation

Reality Warp has a global Battle of Gods boss counterattack system in:

```text
src/core/botg_combat.lua
```

After a hand fails to defeat a semantic Boss, a counterattack can trigger.

One outcome is:

```text
Divine Zap -> lose up to $2
```

This can make The Manacle appear to have an undocumented `$2` penalty even though the loss is actually caused by the global BOTG counterattack system.

## Current disposition

Do **not** patch The Manacle specifically unless a controlled reproduction shows:

- the `$2` loss occurs without the Divine Zap counterattack;
- or the counterattack fires when it should not.

## Suggested isolation test

1. Fight a semantic Boss with no relevant money-loss Jokers/stickers.
2. Fail to clear the Blind in one hand.
3. Observe whether `"Boss Counter: Divine Zap (-$2)"` appears.
4. Repeat on a different Boss.
5. Compare with The Manacle.

If the `$2` always corresponds to Divine Zap, classify as `NOT_A_BUG`.

---

# N6 — Hieroglyph is incompatible with Battle of Gods Ante state

**Status:** CONFIRMED BY RUNTIME + SOURCE

## Observed

Using Hieroglyph at Ante 1 caused:

```text
HUD Ante: 1 -> 0
Hands per round: reduced
Blind score requirement: unchanged
Upcoming Boss: changed/rerolled
Current Blind slot: preserved
Existing skip Tags: preserved
```

## Expected behavior

Hieroglyph should reduce difficulty progression without rewinding current Small/Big/Boss progression.

Expected:

```text
Ante decreases by 1
Hands per round decreases by 1
Blind score requirement uses reduced Ante
current slot/progression remains unchanged
existing Boss identity remains unchanged
existing skip Tags remain unchanged
```

Not returning to Small Blind is expected.

Existing skip Tags remaining unchanged is also expected.

The defects are:

1. BOTG requirement does not use the reduced Ante.
2. Upcoming Boss is regenerated merely because the numeric Ante changed.

## Root cause A — Ante 0 is clamped to Ante 1

Relevant area:

```text
src/core/battle_of_gods.lua
```

Current base-requirement logic includes behavior equivalent to:

```lua
local a = math.max(1, ante)
```

Therefore:

```text
Ante 0
→ treated as Ante 1 for score requirement
```

The HUD can show Ante 0 while the actual BOTG target remains at Ante 1 difficulty.

## Root cause B — numeric Ante change is treated as a new progression event

Relevant area:

```text
src/core/blind_encounters.lua
```

Encounter state stores an Ante value and the scheduler compares it against the current `round_resets.ante`.

Hieroglyph changes `round_resets.ante`, so the scheduler interprets this as a new Ante schedule even though the player has not completed/advanced the Blind sequence.

This causes the Boss to be rerolled.

## Required fix concept

Separate:

```text
Ante difficulty value changed
```

from:

```text
actual new Ante progression event
```

Do not use raw Ante-value inequality alone as proof that encounter choices must be regenerated.

Also allow BOTG target scaling to represent Ante 0.

## Regression tests

### Ante 1

```text
Ante 1
record current slot, Boss, Small/Big Tags, requirement
buy Hieroglyph
```

Expected:

```text
Ante = 0
lower requirement
same Boss
same Tags
same current slot
-1 hand
```

### Higher Ante

```text
Ante 5 -> Hieroglyph -> Ante 4
```

Expected:

```text
Ante 4 requirement
same encounter schedule
same tags
same current slot
```

Also test **Petroglyph** because it uses the same Ante-decrease mechanism.

Suggested branch:

```text
fix/hieroglyph-botg-ante
```

---

# N7 — Croupier / Dice sticker hard-crashes the game

**Status:** CONFIRMED BY RUNTIME + SOURCE  
**Priority:** CRITICAL

## Runtime crash

Observed error:

```text
Could not open file resources/sounds/dice.ogg. Does not exist.
```

The sound-manager thread terminates and crashes Balatro.

## Relevant code

Primary file:

```text
src/consumables/jobs.lua
```

Croupier/Dice sticker scoring logic contains:

```lua
local roll = pseudorandom('dice_job', 1, 6)
play_sound('dice', 1.0 + roll * 0.05)
```

Reality Warp does not provide/register a valid `dice` sound corresponding to that key.

Balatro therefore attempts to load:

```text
resources/sounds/dice.ogg
```

and fails.

## Recommended fix

For stabilization, use an already-existing valid Balatro/Steamodded sound rather than introducing a new asset unless the project specifically wants a custom dice sound.

Alternative:

- add `dice.ogg`;
- register it properly through Steamodded;
- verify packaging/path behavior.

## Regression tests

- Apply Croupier/Dice job to a playing card.
- Score it repeatedly.
- Verify all die outcomes work.
- Verify no sound-manager crash.
- Verify roll 5/6 retrigger behavior still works.
- Test with sound enabled.
- Test with sound muted.

Suggested branch:

```text
fix/croupier-missing-sound
```

Suggested commit:

```text
fix: use valid sound for Croupier rolls
```

---

# N8 — Duplicate Jokers can appear simultaneously in shop without Showman

**Status:** CONFIRMED BY RUNTIME + SOURCE

## Observed

Two copies of the same Joker appeared simultaneously in the shop.

The player did **not** own Showman.

The issue was observed after purchasing the voucher whose tooltip says:

> Common Jokers no longer appear in shop.

## Relevant code

Primary area:

```text
src/core/utils.lua
```

Reality Warp includes custom duplicate-prevention logic that checks whether a generated Joker is already **owned by the player**.

Conceptually:

```lua
while is_joker_owned_by_player(card) and attempts < 10 do
    ...
end
```

However, that does not necessarily detect another copy already present in:

```text
G.shop_jokers.cards
G.pack_cards.cards
```

Therefore:

```text
Joker already owned
→ detected

same Joker already in another current shop slot
→ may survive
```

## Voucher interaction

The Common-removal voucher replaces generated Common Jokers with higher-rarity candidates.

The replacement path can create the new Joker through the captured/original card-generation function, and duplicate validation does not fully account for other cards already offered in the same shop/pack.

Separate replaced Common rolls can therefore resolve to the same Uncommon/Rare Joker.

## Expected behavior

Without Showman:

- no duplicate Joker already owned;
- no duplicate Joker already in the current shop;
- no duplicate Joker already in the current relevant pack.

With Showman:

- duplicates remain allowed according to normal framework behavior.

## Recommended fix direction

Create one canonical duplicate predicate for Joker generation that checks:

1. player-owned Jokers;
2. existing Jokers in the target shop/pack area;
3. framework duplicate/Showman semantics.

Apply the same predicate to voucher-driven rarity replacement.

Avoid recursive card-generation loops.

## Regression tests

1. Normal shop, no Showman:
   - no two identical Jokers simultaneously.

2. Common-removal voucher active:
   - no Common Jokers;
   - replacements remain unique.

3. Taster/other rarity replacement path:
   - replacements remain unique.

4. Player already owns a Joker:
   - same Joker does not appear.

5. Buffoon Pack:
   - no duplicate choices without Showman.

6. Multiple rerolls:
   - every individual shop remains duplicate-free.

7. Showman owned:
   - duplicate shop Jokers may appear.

Suggested branch:

```text
fix/shop-joker-duplicates
```

Suggested commit:

```text
fix: prevent duplicate Joker offers without Showman
```

---

# N9 — Long runs progressively lose performance, but restart restores it

**Status:** CONFIRMED BY RUNTIME  
**Root-cause direction:** RUNTIME ACCUMULATION / LEAK LIKELY  
**Priority:** High

## Observed

Performance progressively degraded during a long Reality Warp / Battle of Gods run.

The Lovely log contained thousands of:

```text
LONG DT @ ... : 0.05–0.10
```

entries.

Approximate frame rates represented by those frame times:

```text
0.05 s/frame ≈ 20 FPS
0.10 s/frame ≈ 10 FPS
```

The long-frame reports became very dense later in the same Balatro process, indicating sustained degradation rather than isolated hitches.

## Critical new evidence — cold restart restores performance

The same late-run save became smooth immediately after fully quitting and restarting Balatro.

```text
same save
same deck
same Jokers
same Ante/progression
same persistent run state
        ↓
fully restart Balatro
        ↓
performance becomes smooth again
```

This substantially narrows the likely root cause.

The slowdown is therefore **not explained solely by persistent run complexity** such as:

- high Ante;
- deck size;
- number of Jokers;
- saved encounter state;
- large score magnitude by itself.

Those properties survive a restart, while the slowdown does not.

## Updated root-cause hypothesis

The strongest current hypothesis is **transient runtime-state accumulation during a single Balatro process**.

Primary suspects:

1. Event-manager queue/object accumulation.
2. Delayed Reality Warp events that are not released.
3. Callbacks/listeners/wrappers being registered repeatedly during play.
4. Retained closures referencing old encounter/card objects.
5. Familiar or possession temporary-state growth.
6. Status-text, animation, sound, or UI objects accumulating.
7. JokerDisplay runtime/cache accumulation.
8. Lua memory growth / insufficient garbage collection.
9. Amulet runtime caches or Amulet × Reality Warp interaction.
10. Other temporary tables that continuously grow and are not serialized.

## Lower-priority explanations after the restart test

These may still increase per-hand cost, but they no longer adequately explain the progressive degradation by themselves:

- deck size alone;
- high Ante alone;
- saved BOTG history alone;
- Joker inventory alone;
- huge numeric values alone;
- high-retrigger scoring alone.

A high-retrigger setup can still amplify another leak because leaked or duplicated work will execute many more times per hand.

## Environment

```text
Reality Warp main
tested checkpoint: f863d0c
Balatro 1.0.1o-FULL
Steamodded 26.829.0
Lovely 0.9.0
Amulet 3.6.2
JokerDisplay 1.10.9
Windows
retrigger_joker optional feature enabled
```

Cartomancer, Incantation, and MikasModCollection were blacklisted/skipped during the logged launch and therefore were not active runtime contributors.

## Compatibility note

The startup log contains several Lovely patch `no matches` warnings from Amulet and JokerDisplay.

This is **not sufficient evidence that Amulet causes N9**.

Some failed patterns may simply be stale or alternative compatibility patches whose intended behavior is already supplied by newer Balatro/Steamodded code.

Amulet should therefore remain a **compatibility/performance suspect**, not the confirmed root cause.

Do not report:

```text
Amulet causes the lag
```

Current wording should be:

> Cold restart restoring performance points to transient runtime-state accumulation. Amulet, JokerDisplay, Reality Warp, and interactions between them remain candidates until isolated.

## Required profiling

Instrument the run at regular checkpoints, ideally once per Ante and before/after a hand.

Record at minimum:

```text
Ante
Lua memory usage
pending event count
active event count if available
playing-card count
Joker count
consumable count
Familiar-related table sizes
possession-related table sizes
BOTG encounter/history table sizes
number of Joker/card calculation calls per hand
number of status-text/event creations per hand
```

Lua memory can be sampled with:

```lua
collectgarbage("count")
```

which returns Lua memory usage in KB.

A useful trace would look like:

```text
Ante 2:  memory X, events Y
Ante 5:  memory X2, events Y2
Ante 10: memory X3, events Y3
lag begins
```

Then, after restarting the same save:

```text
Ante 10 after restart:
memory/event counts drop substantially
performance restored
```

That would provide strong evidence of retained runtime state.

## High-value isolation tests

### Test A — reproduce degradation after restart

1. Start from the same save immediately after a cold restart.
2. Confirm performance is smooth.
3. Continue playing normally.
4. Record approximately when lag becomes noticeable again:
   - elapsed time;
   - Ante;
   - number of rounds/hands;
   - whether a specific mechanic was repeatedly used.
5. Capture another Lovely log.

If performance progressively degrades again in the same process, N9 is reproducible.

### Test B — JokerDisplay isolation

Using a backup/test setup:

```text
Reality Warp + Amulet + JokerDisplay
vs.
Reality Warp + Amulet, JokerDisplay disabled
```

Interpretation:

```text
lag degrades with JokerDisplay
but remains stable without it
→ JokerDisplay or JokerDisplay × Reality Warp interaction becomes primary suspect
```

### Test C — Amulet isolation

Only use a test run/save where disabling Amulet is safe.

Compare:

```text
Reality Warp + Amulet
vs.
Reality Warp without Amulet
```

Interpretation:

```text
lag only occurs with Amulet
→ Amulet or Amulet × Reality Warp interaction

lag occurs similarly without Amulet
→ Reality Warp/runtime accumulation becomes much more likely
```

Do not disable Amulet on the only copy of a save that already depends on very large numbers.

### Test D — garbage-collection experiment

When the game has become laggy, measure Lua memory before and after a forced collection in a diagnostic build:

```lua
local before = collectgarbage("count")
collectgarbage("collect")
local after = collectgarbage("count")
```

Interpret carefully:

```text
large memory drop + noticeable performance recovery
→ garbage pressure / collectible temporary allocations

little memory drop + lag remains
→ objects are still strongly referenced or bottleneck is not Lua heap size
```

This should be diagnostic only, not shipped as a periodic forced-GC workaround without proving the cause.

## Code paths to inspect

Prioritize hot paths and places that create delayed/runtime objects:

```text
Card:calculate_joker
SMODS.calculate_context
G.E_MANAGER:add_event
Reality Warp Familiar callbacks
Reality Warp possession callbacks
Battle of Gods encounter scheduling
delayed Blind effects
status_text / card_eval_status_text paths
sound/event creation
JokerDisplay calculation hooks
Amulet big-number/display hooks
```

Specifically search for:

- `G.E_MANAGER:add_event(...)` inside frequently-called scoring callbacks;
- events that retry by returning `false`;
- closures that capture `card`, `blind`, or encounter objects;
- global tables appended to but never cleared;
- wrappers installed from code that can execute more than once;
- `table.insert` into persistent runtime registries;
- duplicated listener/hook installation on load/reload;
- per-hand caches with no end-of-round cleanup.

## Current workaround

A full Balatro restart temporarily restores smooth performance.

Until the leak/accumulation is isolated, restarting the game periodically is a valid workaround for manual testing.

## Recommended implementation approach

Do **not** open a production `fix/...` branch based solely on the current hypotheses.

Start with a diagnostic/profiling branch such as:

```text
docs/profile-long-run-performance
```

or a local instrumentation branch.

Only create the final `fix/...` branch after profiling identifies a concrete growing resource, repeated registration, retained object, or expensive accumulating path.


---

# Additional gameplay observations from the same test session

These are not currently separate bugs.

## Hieroglyph does not return the player to Small Blind

**Disposition:** NOT A BUG

Lowering Ante does not imply rewinding the current Small/Big/Boss progression.

The actual Hieroglyph issues are documented under N6:

- incorrect score requirement after Ante reduction;
- unintended encounter/Boss regeneration.

## Existing skip Tags remain unchanged after Hieroglyph

**Disposition:** EXPECTED

Already-generated skip Tags should remain associated with the current progression state.

## The Manacle `$2` deduction

**Disposition:** LIKELY EXPLAINED BY BOTG COUNTERATTACK

Do not create a Manacle-specific fix unless controlled testing proves the global Divine Zap counterattack is not responsible.

---

# Recommended handoff to Sol High

After the current `/goal` round finishes:

1. Add all N3–N9 findings to `docs/BUG_BACKLOG.md`.
2. Reopen Issue #9 as runtime-confirmed.
3. Add runtime regression cases to `docs/REGRESSION_TESTS.md`.
4. Process the new findings in dependency/priority order.
5. Keep one issue per branch/PR unless a shared root cause makes separation unsafe.
6. Do not mark runtime-only behavior as verified without an actual Balatro test.
7. Preserve this manual-test checkpoint (`main = f863d0c`) in the notes for comparison after fixes.
