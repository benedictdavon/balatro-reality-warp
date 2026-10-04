# Stabilization status and review queue

Snapshot: accepted main/origin/main 0474ed39013d53bd96f3af08fb956832a644afe1 (PR19). PRs1–19 are accepted. This separate N7 correction starts from that accepted main. Public publication and controlled merging after technical approval are authorized.

AGENTS.md, ISSUE.md and BUG_AUDIT.md are tracked. POST_SOL_RUNTIME_FINDINGS.md remains untouched and untracked; POST work is deferred.

All 34 original labels are inventoried: 28 HUMAN_TEST_NEEDED, 3 STALE, 1 NOT_A_BUG and 2 READY. Original stabilization remains incomplete: accept the N7 correction (original #5 regression), then fresh #8 and #13 branches. No Balatro execution or cold-runtime verification is claimed.

## Original findings

| ID | Finding | Disposition | Branch | PR / acceptance |
| --- | --- | --- | --- | --- |
| #1 | Battle of Gods / Colosseum can display one Blind while a different Blind or effect is actually active | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #2 | Ares / Violet Vessel sometimes behave like The Hook / Minotaur and discard two random cards | HUMAN_TEST_NEEDED | docs/ares-vessel-discard-validation | [PR 19](https://github.com/benedictdavon/balatro-reality-warp/pull/19) (accepted) |
| #3 | Athena can display one required poker hand and enforce another | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #4 | The Net can display one target rank and destroy another | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #5 | Godly Hubris / Blind chip requirement can differ between preview and actual combat | HUMAN_TEST_NEEDED | fix/blind-target-calculation | [PR 9](https://github.com/benedictdavon/balatro-reality-warp/pull/9); [N7 PR20](https://github.com/benedictdavon/balatro-reality-warp/pull/20), review pending |
| #6 | Chicot can visually disable custom bosses while their custom effects still execute | HUMAN_TEST_NEEDED | fix/blind-effect-ownership | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| #7 | Ouroboros does not reliably enforce “always draw 3 cards” after Play or Discard | HUMAN_TEST_NEEDED | fix/round-action-draws | [PR 13](https://github.com/benedictdavon/balatro-reality-warp/pull/13) |
| #8 | Helin's exponent effect can do nothing in big-number mode | READY | — | Prerequisites accepted; fresh focused branch queued |
| #9 | Colosseum starting Perishable Stencils can expire, then become active again | HUMAN_TEST_NEEDED | fix/blind-effect-ownership | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| #10 | Shortcut failed a valid one-gap Straight | STALE | — | Source disposition |
| #11 | Baby Mark appeared to trigger roughly ten times from one Red Seal Polychrome King | HUMAN_TEST_NEEDED | docs/baby-mark-retrigger-validation | [PR 16](https://github.com/benedictdavon/balatro-reality-warp/pull/16) |
| #12 | Consumable stacking compatibility / UI: no clean native stacking, and early visual-only patches buried cards | NOT_A_BUG | docs/consumable-stacking-disposition | [PR 18](https://github.com/benedictdavon/balatro-reality-warp/pull/18) |
| #13 | Dark Alchemy Tag tooltip/code probability deserves verification | READY | — | Prerequisites accepted; fresh focused branch queued |
| #14 | Lucky One probability logic has historically been broader than the tooltip suggests | HUMAN_TEST_NEEDED | fix/lucky-one-rng | [PR 17](https://github.com/benedictdavon/balatro-reality-warp/pull/17) |
| #15 | Battle-of-Gods boss usage counters can be polluted by blind rolls that are immediately overwritten | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #16 | Fused and regular boss categories overlap in the current selector | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #17 | Boss eligibility ignores or inconsistently applies `min`, `max`, and `in_pool()` | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #18 | Battle-of-Gods state has too many overlapping representations of “what Blind are we fighting?” | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #19 | Potential stale/delayed boss effects should be audited after Blind changes | HUMAN_TEST_NEEDED | fix/blind-effect-ownership | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| #20 | Consumable-stack quantity badge alignment was confusing | STALE | docs/consumable-stacking-disposition | [PR 18](https://github.com/benedictdavon/balatro-reality-warp/pull/18) |

| ID | Finding | Disposition | Branch | PR / acceptance |
| --- | --- | --- | --- | --- |
| R1 | Encounter parameters are not persisted and shared definitions survive runs | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| R2 | Iron Maiden hand size is not restored on ordinary defeat; disable restoration can repeat | HUMAN_TEST_NEEDED | fix/iron-maiden-restoration | [PR 5](https://github.com/benedictdavon/balatro-reality-warp/pull/5) |
| R3 | Reset-only Blind refresh compounds or erases target scaling | HUMAN_TEST_NEEDED | fix/blind-target-calculation | [PR 9](https://github.com/benedictdavon/balatro-reality-warp/pull/9) |
| R4 | Blanket undebuff erases other systems' restrictions | HUMAN_TEST_NEEDED | fix/blind-effect-ownership | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| R5 | Apotheosis/Exalted interception replaces normal Joker calculation | HUMAN_TEST_NEEDED | fix/joker-calculation-composition | [PR 12](https://github.com/benedictdavon/balatro-reality-warp/pull/12) |
| R6 | Arrow rank lookup uses invalid vanilla card keys | HUMAN_TEST_NEEDED | fix/arrow-rank-mapping | [PR 11](https://github.com/benedictdavon/balatro-reality-warp/pull/11) |
| R7 | Direct boss dissolution bypasses destruction-notification bookkeeping | HUMAN_TEST_NEEDED | fix/blind-destruction-notifications | [PR 6](https://github.com/benedictdavon/balatro-reality-warp/pull/6) |
| R8 | get_straight wrapper discards modern API parameters | HUMAN_TEST_NEEDED | fix/straight-api-forwarding | [PR 14](https://github.com/benedictdavon/balatro-reality-warp/pull/14) |
| R9 | Chronos and Guillotine each run at two scoring stages; Void checks before queued score addition | HUMAN_TEST_NEEDED | fix/blind-final-scoring | [PR 10](https://github.com/benedictdavon/balatro-reality-warp/pull/10) |
| R10 | Possession draw/discard callbacks can issue repeated or duplicate transfers | HUMAN_TEST_NEEDED | fix/round-action-draws | [PR 13](https://github.com/benedictdavon/balatro-reality-warp/pull/13) |
| R11 | Canonical Blind keys are missing from several active-effect detectors | HUMAN_TEST_NEEDED | fix/blind-identity-contracts | [PR 2](https://github.com/benedictdavon/balatro-reality-warp/pull/2) |
| R12 | Free reroll refunds by assigning dollars before delayed payment settles | HUMAN_TEST_NEEDED | fix/divine-ward-reroll | [PR 15](https://github.com/benedictdavon/balatro-reality-warp/pull/15) |
| R13 | The Code punishes one consumable twice and bypasses Eternal filtering | HUMAN_TEST_NEEDED | fix/code-consumable-punishment | [PR 7](https://github.com/benedictdavon/balatro-reality-warp/pull/7) |
| R14 | Ante-history wrapper marks the current hand as previously played before evaluation | STALE | docs/ante-history-disposition | [PR 8](https://github.com/benedictdavon/balatro-reality-warp/pull/8) |

## Accepted branch and commit ledger

| PR | Branch | Labels | Implementation / disposition | Reviewed branch head | Main merge commit |
| --- | --- | --- | --- | --- | --- |
| [PR 1](https://github.com/benedictdavon/balatro-reality-warp/pull/1) | docs/bug-backlog | Source documents/backlog | 74b267907718284bc30baa8ae779e2c3134b1619 | 74b267907718284bc30baa8ae779e2c3134b1619 | 013fdf33618e4c4fd882e0f5d17a585e0c874920 |
| [PR 2](https://github.com/benedictdavon/balatro-reality-warp/pull/2) | fix/blind-identity-contracts | R11 | a2f04ca90122ad87c3b1acbcd871b522cab262f0 | a2f04ca90122ad87c3b1acbcd871b522cab262f0 | 1afc7e590fa84695938b1936cd0e7b90fa4ae93e |
| [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) | fix/botg-encounter-lifecycle | 1, 3, 4, 15, 16, 17, 18, R1 | a8ff1d020e6f5df9c2cb12a468d90f917e27cfee | a8ff1d020e6f5df9c2cb12a468d90f917e27cfee | 43a90f472b2f251d75dd73175eb9b7dd19722b21 |
| [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) | fix/blind-effect-ownership | 6, 9, 19, R4 | e3e3d49ef65836945eec43f8bbb70a4ed581daf9 | e3e3d49ef65836945eec43f8bbb70a4ed581daf9 | 8e4c2bfad92fc0572dcdb289608895d2f452e4ac |
| [PR 5](https://github.com/benedictdavon/balatro-reality-warp/pull/5) | fix/iron-maiden-restoration | R2 | 2155e8ccf5f5f6dd30cc4ad1df7d5739eaf10b79 | 1d261e97ea18c1b7b7fba1c20fb804dbff9174af | ae9dd607cf13779804f319f3bbfed732d1d0d44e |
| [PR 6](https://github.com/benedictdavon/balatro-reality-warp/pull/6) | fix/blind-destruction-notifications | R7 | 333c3fd0c27009a540369e449b22d437f3dbfef3 | 0ed19edc31853dc6c19965adefccf3a8909b929b | ce82699d5c9d5ca75437d56e416129cb7d7001e2 |
| [PR 7](https://github.com/benedictdavon/balatro-reality-warp/pull/7) | fix/code-consumable-punishment | R13 | 8fc3d43fa92ace3818cf03ad7ca8bda805ed7d83 | 2faf7fc1193546b3b35d6c5849b09cbc292b5000 | 592b30092d611a7b78694c21fff7d1b68e86a715 |
| [PR 8](https://github.com/benedictdavon/balatro-reality-warp/pull/8) | docs/ante-history-disposition | R14 | e4c4fc18c650cab22967ee11f709f83ea6d486b6 | df9a632fe28e9495d69e1d2cd6b00a7b715a86e2 | e8212e55654a98e20f571513c5381ddba03f8dc7 |
| [PR 9](https://github.com/benedictdavon/balatro-reality-warp/pull/9) | fix/blind-target-calculation | 5, R3 | 8b6b0b910fb6466aade2ae2df18b7254fb3fc2c3 | 187e53991c6ff4e76713fdde7412924fd67e4930 | 50babb21ba2297437510ecf0ea5eb025fb5b2504 |
| [PR 10](https://github.com/benedictdavon/balatro-reality-warp/pull/10) | fix/blind-final-scoring | R9 | 0b6204ed03f92c191fa3ef39bd6ca3efd8709ba4 | 7577bfdd364cd12ca4b982ac70d6ab9740921328 | f863d0c2c543c4befa481803a581847ca8fe7274 |
| [PR 11](https://github.com/benedictdavon/balatro-reality-warp/pull/11) | fix/arrow-rank-mapping | R6 | 31015cf76b9637e6ddcce757b1528ce07e81690e | 58221c943f8f0407422b0eb5f65308a761ee12a4 | add5727837c396fff2b5af12283fc3f25904d242 |
| [PR 12](https://github.com/benedictdavon/balatro-reality-warp/pull/12) | fix/joker-calculation-composition | R5, N3 | 62a4cf10945c28580920720c90e51af931a4ef85 | 26cfb11ef11bd3c249add2b5508574b00c93f102 | 004387097ca286256363fb42e442d7f138049c99 |
| [PR 13](https://github.com/benedictdavon/balatro-reality-warp/pull/13) | fix/round-action-draws | 7, R10 | 99618014e3ce21a30b0c9b04f632c652343b082d | d1c110f558b7bb116f820bbbb70ee3ab7bac5d9b | 98ffbbc999263f334e4d0b9e600c746f8e4df339 |
| [PR 14](https://github.com/benedictdavon/balatro-reality-warp/pull/14) | fix/straight-api-forwarding | R8 | 19b60afda787c64d6da37de9ea43923d1893c8dc | 964e576f1c71c14b66ba32021d747006af124295 | 31886a8dca4b22b47c5f05e1e9795b18c63d5286 |
| [PR 15](https://github.com/benedictdavon/balatro-reality-warp/pull/15) | fix/divine-ward-reroll | R12 | 2e57572528f044da1a002ca492cffd39d2840681 | 15ca782c1ccac2684b19214e4584b56631e7bcc5 | be91b9b3cc1a72836b5b00b68c30d24265cae1e8 |
| [PR 16](https://github.com/benedictdavon/balatro-reality-warp/pull/16) | docs/baby-mark-retrigger-validation | 11 | 74e5961fc2407d6c14ed477e12af05308e0d6eed | 530060dc63361335ae8af19f8d688d9b90d07b5e | c7879d9ad4c170a565c0a3d438a4bdf05a852982 |
| [PR 17](https://github.com/benedictdavon/balatro-reality-warp/pull/17) | fix/lucky-one-rng | 14 | c53fffc6a9fac38f2a2816b3e9359cd706e54bb3 | a8319d6f1b9ed06751b60822c0115d794a0b9a8e | 36c4283213cf841e0e7cc32088cc9a0cd482e4be |
| [PR 18](https://github.com/benedictdavon/balatro-reality-warp/pull/18) | docs/consumable-stacking-disposition | 12, 20 | c6c78485bb752df26e8347c313465875b93b0548 | 6987331795c0b0cc659fe01adc8708440ae816c1 | d0f83b461d0777ffb52bb2a1af727f0906f7c967 |
| [PR19](https://github.com/benedictdavon/balatro-reality-warp/pull/19) | docs/ares-vessel-discard-validation | 2 | ca0f92ace6828911e1286e441a41c41e0c434b07 | b28bcc4c3eaf802ffd9aa3f58e8fb619d88fb905 | 0474ed39013d53bd96f3af08fb956832a644afe1 |

Correction and integration commits remain in the linked accepted PR histories. PR19 was accepted and merged. N7 PR20 is open at implementation 0c1e38fc3a32d1818efcebad4cb295e5b7799add; no merge is assumed.

## Validation and limits

This candidate on accepted main has 16 passing focused Lua harnesses, Lua 5.1 source compilation, shipping TOML/payload compilation and original-or-fully-applied native boundary validation. Lucky additionally passes actual installed Amulet Omega probability-ratio checks under LuaJIT and in-memory original/full/mixed/duplicate reset fixtures. Mark exercises actual native scoring and copy callbacks with labeled UI/event/card adapters. Real games, cold restart, optional-mod interplay and scheduling remain human tests. The N7 branch corrects one canonical key and the native target fixture, and updates four Markdown files; it verifies source inventory, every original row, accepted Git ancestry, immutable provenance and the complete diff. No installed dump or save is modified.

## New findings outside the original audit

| Local ID | Evidence / disposition | Follow-up |
| --- | --- | --- |
| N1 | Familiar outer draw wrapper ignores numeric refill arguments. | Separate future bounded branch. |
| N2 | Potion Mirror loses nested/XMult effects and mutates the first result. | Separate composition fix. |
| N3 | FIXED on accepted PR 12: native dump checker accepts original or fully applied boundaries and rejects partial/duplicate/mixed forms. | No runtime claim; accepted checker validation complete. |
| N4 | Familiar outer draw wrapper drops native early return and extra arguments, even without a Familiar. | Separate return-preservation fix after revalidation. |
| N5 | Colorful flush/isSuit can count removed or out-of-area owners. | Separate live-owner fix. |
| N6 | Hypnotist clears independently owned playing-card debuffs after native disable. | Separate owned-cleanup fix. |
| N7 | Actual Violet Vessel key is bl_final_vessel; unified helper uses nonexistent bl_vessel. | Canonical source correction and actual native fixture complete; publication/review pending; HUMAN_TEST_NEEDED. |

These local N identifiers are distinct from the deferred POST report. A Black Hole sequential exponentiation, B Perfectionism Negative replacement and C Upgrade Roulette pre-scoring progression remain NOT_A_BUG. #10 and R14 are STALE because the implicated wrappers are absent; R8 independently fixes current API forwarding. #20 is STALE because its quantity badge is absent. #12 records an optional feature gap, without claiming a working stack model.

## Human Balatro test queue

No agent has executed Balatro. Source-extracted framework tests and modeled save reconstruction are not game execution or a cold restart. Use seed EYEFTHTG and record salt, exact versions, stake, deck, Ante, Blind and inventory; create the listed setup with debug tools if the seeded shop does not offer it. Start with required Steamodded/Lovely only; separately repeat the named Amulet/JokerDisplay integrations. Use White stake, Red Deck then Colosseum, Ante 1 and 12 unless specified below. Record actual results, not only visible status messages.

| Labels | Setup and procedure | Expected result |
| --- | --- | --- |
| #1/#15/#16/#17/#18/R1/R11 | Colosseum, Ante 1/8/12; observe all three slots through reroll, selection, defeat and next Ante. Log schedule/display/selected/active canonical key, category, slot flags, ID, target and bosses_used. Save before selection and during encounter; quit game and cold restart. Exercise min/max/in_pool exclusions. | Same committed identity throughout; native progression slots preserved, pools disjoint, usage incremented once on commit, targets/parameters survive restart. |
| #3/#4 | Athena and Net, with target and non-target poker hands/ranks, including Ace/custom ranks. Open previews repeatedly; reload then cold restart before playing. | Preview never rerolls state; Athena enforces displayed hand, Net destroys only saved target rank. Marked legacy migrations use documented defaults. |
| #6/#9/#19/R4 | Chicot at setup and after queued penalties, Athena/Phone/Minotaur/Thanatos and independently SMODS-debuffed cards. Win then transition before queued events; save/cold restart. Colosseum Perishable starters through expiry and Thanatos showdown. | Disabled penalties stop; cleanup still executes and preserves other owners; delayed mutations cannot affect another encounter. Thanatos refresh follows documented showdown behavior. |
| R2 | Iron Maiden normal defeat, disable twice, defeat after disable, then cold reload while active. Separately Obelisk/Leviathan used versus remaining resources. | Hand size restored exactly once; disable refunds only unapplied resource penalties. Legacy unknown ledgers are recorded for human adjudication. |
| R7/R13 | Ares/Net/Hades destruction with Eternal and ordinary cards and removal-sensitive listeners; Code use Tarot/Planet/Spectral/Potion/Job with 0/1/multiple eligible Jokers and Eternal control. | One framework removal notification per destroyed card; Code executes original use/listeners once, removes at most one eligible non-Eternal Joker and scales target once. |
| #5/R3 | Hubris, stake scaling, Rod/Nectar/Wall, Colosseum showdown and modified current target. Preview/setup/reset repeatedly; add/remove relevant Jokers between reset calls; Amulet large values separately. | One pure initial target; preview matches current serialized chips; resets neither compound nor erase scaling; starting modifiers consumed once. |
| R9 | Chronos, Guillotine, Void; enabled/disabled controls, Plasma deck and deck-final effects; forced successful and failed Guillotine rolls. | Rules apply once at final scoring; Chronos threshold and Void projected non-win use final hand total. Guillotine samples once and zeroes only its successful outcome. |
| R6 | Arrow with 2/3/10/J/Q/K/A and custom rank with/without predecessor; Blueprint/retrigger/disabled controls. | Framework previous-rank mapping used once per actual play; disabled/duplicate contexts do not downgrade again. |
| R5 | Apotheosis/Exalted/Glitch modes; original chips/Mult/XMult/extra/multiple returns, removed/debuffed and Blueprint-incompatible controls, Mirror and removal sentinel. | Original calculation runs once and composes with bonuses; nested effects, all returns, eligibility and removal semantics preserved. |
| #7/R10 | Ouroboros and native Serpent; play/discard/water-only draw with hand limits 0/-1/2/normal, deck 0/1/2/3/more, nonstandard card limits and partial queued draw cold-save. One/two Water/Hook possessions and retrigger/Blueprint controls. | Three physical top cards where available for owned refill; no duplicate transfer, overdraw or stale encounter mutation; Water once per action and Hook only actually held discard selection. |
| R8 / #10 control | Shortcut alone, Shortcut+Four Fingers, Colorful and canonical aliases; AKQJ9 and A2346, custom string ranks, explicit length/skip/wrap/future arguments. | Native straight contracts forwarded; genuine one-gap straights accepted without false gaps; #10 historical fallback regression remains absent. |
| R12 | Divine Ward $0/$5/$20, native and UI reroll, Boss Tag, normal $10 path, Retcon/Director restrictions, cold save between charge use and reroll. | One Ward token skips fee entirely, UI price updates to $10 immediately, Boss Tag does not consume Ward, restrictions and normal price remain native. |
| #11 | Baby Mark level 1 then 5, one face King, no other retrigger source; plain, Red Seal, Polychrome, both, then Baby Bell positive control. Log actual scoring passes/callbacks separately from messages, native deck then Colosseum; save/cold restart and separate Amulet/JokerDisplay. | Mark gains once per actual played face-card evaluation; it does not request repetitions. Polychrome adds edition scoring, not another scoring pass. Red Seal alone gives the native extra pass. |
| #14 | One/two Lucky Ones plus Blueprint/Mirror; 5/10 Clubs with/without Red Seal; 1/2 stored charges. Space/Bloodstone/Lucky/Wheel/BabyWheel and harmful Ares/Hades/Guillotine; fixed Bell/Acorn/Destilacion/BOTG/Echo/Miner; shop/cosmetic/UI/Falta/Doppel/no_resolve controls. Win/loss/saved loss with main and held end-round chance; cold-save legacy/current counters. | Only real modifiable owned rolls spend one physical charge, native sample still runs once. Fixed chances retain odds/charges; each real success grows each captured eligible Lucky once. Duplicate copied receivers do not grow, distinct copied probability rolls do. Held outcomes run before final reset. |
| #2 (ready) | R10 is accepted: Ares/Violet alone with no possessions/Familiars, then Hook/Water separately; Minotaur disabled and stale transition controls. | No unexplained random discard in isolated Ares/Violet; source of any actual discard traced to owning effect before further patch. |
| #8 (ready) | R5 is accepted: Helin power 2 at Mult 12, Blueprint copies 0/1/2, normal numbers then installed Amulet, all applicable modes and cold restart. | 144 / 20,736 / 429,981,696 from sequential exponentiation; supported e_mult dispatch retained. Large magnitude alone is expected. |
| #13 (ready) | #14 is accepted: Dark Alchemy only, negative-eligible shop/pack Jokers with default/custom options, no_neg controls and tag activation before first shop card. Capture baseline/tag thresholds and one sample per poll. | Formal odds contract established and implemented on accepted prerequisites; current overlapping 3% paths are not treated as verified 10x. |
| #12 / #20 controls | Optional native baseline: repeated Negative Tarot/Planet/Spectral cards, ordinary separate use/sell/copy, save/cold restart and hover/drag/controller navigation. No stacking mod. | Current fork uses separate Card objects. Historical quantity/hitbox patches and badge are absent; no implemented stacking feature is claimed. |
| A/B/C controls | Black Hole sequential Blueprint exponent; Perfectionism edition replacement; Upgrade Roulette pre-scoring/Stone/Glass progression. | Existing intentional behavior remains unchanged. |

Recommended sequence: native baseline and intentional controls → identity/progression/persistence → target previews → disabled/queued ownership and resources → removal/Code → final scoring → rank/straight → Joker composition → draws/possessions → Lucky ownership/end-round/cold save → focused Mark/reroll → the three newly ready focused cases → full long Colosseum run with cold checkpoints and separate optional mod integrations. POST runtime findings are a later user-requested phase, not evidence that these agent tests executed the game.
