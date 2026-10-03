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
