# Regression tests

No Balatro runtime tests have been executed by the agents. Static checks and stubbed Lua harnesses must be recorded separately from real game validation.

## Common game protocol

Start with Reality Warp plus installed Steamodded/Lovely only; add Cartomancer, JokerDisplay, Incantation and number extensions individually. Record exact versions, config/new-run seed salt, seed, stake, deck, Ante, Blind key, Joker positions, Familiar levels and possessions. Use EYEFTHTG as a historical candidate, not a reproduced result.

For encounter tests observe slot, scheduled/displayed/button/selected/active canonical keys, semantic category, runtime slot flags, disabled state, encounter ID, parameters and target chips at equivalent lifecycle points. Include skip, paid/free reroll, three consecutive defeats, same-process reload, cold restart and a second run.

For permanent effects include enabled positive control, disabled at setup, disabled after enqueue, defeat, next encounter, prior legitimate debuffs and cold restart. Count actual transfers/removals and framework notifications, not animations alone.

## Preserved controls

- Black Hole + Blueprint: each copy applies sequential exponentiation with intermediate flooring; no artificial growth cap.
- Perfectionism: Negative replaces Polychrome under the single-edition model.
- Upgrade Roulette: scoring enhancements upgrade before scoring; Stone becomes Steel, Glass remains terminal, unscored cards remain unchanged.

## Historical Straight

10 diamonds, 9 hearts, 8 hearts, 7 clubs, 5 hearts is a Straight with active Shortcut; without or debuffed Shortcut it is not. Also test A K Q J 9, A 2 3 4 6, two consecutive missing ranks, separated one-rank gaps, duplicates, Four Fingers and Colorful Street combinations. R8 must additionally preserve explicit min_length/skip/wrap/custom rank topology.

## Canonical identity (#18, R11)

Static: tests/run.py compiles Lua 5.1 and tests/test_blind_identity.lua checks canonical matching, Big-slot semantic boss/showdown classification, no name inference and idempotent disabled-aware Pincer unlock preserving an independent debuff in a stub.

Manual: White stake, Colosseum, no possessions/familiars/optional mods; force Big-slot Ares then a showdown and verify get_type remains Big, Ante advances only after Boss, semantic counterattack runs, and dark coins are 3/5 respectively. Query get_type on a second nonactive Blind and verify its own type. Run Mountain: use one consumable and verify exactly the next hand fails. Run Doppelganger with one +Mult Joker: UI opening/background resets preserve target and its activation causes the final penalty. Run Pincer: Chicot disables from setup; without Chicot destroy one playing card through dissolve, Glass shatter and Spectral shatter in separate fights. Other Jokers unlock, but expired Perishables/other debuff sources remain debuffed. Disable Pincer and confirm destruction causes no new unlock/sound work. Repeat cold restart after the encounter persistence fix.

## Encounter scheduler and persistence (#1, #3, #4, #15–18, R1)

Agent checks: Lua 5.1 syntax; disjoint/min/max/in_pool/banned candidate stubs; repeated resets preserve IDs/RNG/counters; defeated/skipped slots stay unchanged; allowance grants once per Ante; separate same-key preview params; activation return forwarding; simulated saved-table reconstruction and stable Joker sort ID reconnection. This is not a real save codec/game run.

Policy: Ante 1 retains regular-boss Small/Big and eligible showdown Boss; subsequent Antes use Big Blind in Small, a uniformly selected available boss/fused/showdown category in Big, and eligible showdown Boss. Empty categories fall back only to eligible bosses/regular Blinds. Fused starts at its metadata min (12). After a win refresh remaining upcoming slots once; completed/skipped/current entries stay stable. Repeated render/reset calls never reroll them. Usage means committed previews (including subsequently skipped/rerolled ones), not only fought bosses.

Manual setup: EYEFTHTG, White stake, Colosseum, baseline required mods, no possessions/familiars; record seed salt. At Antes 1/2/8/12/24 verify all key stages, slot progression, once-per-commit usage counts, min/max/config/bans and empty-category fallback. Defeat Small then inspect frozen Small versus refreshed future slots; skip Big and repeatedly reopen selection; reroll Boss and verify only Boss changes. Repeat three wins, entry through post-game BOTG transition and saved selection reload.

Force Athena and Net separately in Big/Boss at eligible Ante 8; record preview, select, play displayed target and non-target, reopen UI. Force same key in two slots and verify independent parameters. Cold restart both before selection and during combat; targets remain exact. Hades nullify flag must persist mid-hand and start false in a later Hades encounter. Doppelganger target must reconnect to the actual reconstructed Joker, retain reflection and activation, then repick only when sold/removed. Start a second run without restarting the process; no old target/flag may carry over.

Old-save migration: historical target values were never serialized and cannot be recovered after a cold restart. Missing Athena/Net target data is explicitly marked legacy_target_unknown and defaults to Pair/Ace; no localization roll occurs. Record this limitation when migrating old saves; new saves preserve exact targets. Old direct Doppelganger references migrate through their saved sort_id.
