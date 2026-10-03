# Stabilization status and review queue

Snapshot: accepted `main` and `origin/main` are `f863d0c2c543c4befa481803a581847ca8fe7274` (PR 10). Local reviewed branches are separate candidates; none is represented as merged. Every new issue branch began at the accepted main available at creation. The goal remains incomplete: publishing/merging prerequisites is unavailable pending the existing explicit approval request.

AGENTS.md, ISSUE.md and BUG_AUDIT.md are tracked source documents (PR 1). POST_SOL_RUNTIME_FINDINGS.md is a preserved, untracked user-provided report reserved for the requested follow-on phase; it has not been committed, edited or production-audited. Its human runtime evidence is distinct from agent validation.

All 34 original labels are accounted for: 27 HUMAN_TEST_NEEDED, 3 STALE, 1 NOT_A_BUG, 3 genuinely BLOCKED. HUMAN_TEST_NEEDED describes completed source work/local review with exact game tests outstanding; unpublished candidates still require the separate publication/review/accepted-main gate. Accepted main accounts for 22 labels; nine additional labels have local source dispositions. This is a status checkpoint, not a claim of stabilization completion.

## Original findings

Branch/PR references identify the exact candidate or accepted fix; detailed commits are in the following ledgers. No Balatro runtime verification has been performed by an agent.

| ID | Finding | Disposition | Branch | PR / acceptance |
| --- | --- | --- | --- | --- |
| #1 | Battle of Gods / Colosseum can display one Blind while a different Blind or effect is actually active | HUMAN_TEST_NEEDED | `fix/botg-encounter-lifecycle` | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #2 | Ares / Violet Vessel sometimes behave like The Hook / Minotaur and discard two random cards | BLOCKED | — | Accepted prerequisite unavailable |
| #3 | Athena can display one required poker hand and enforce another | HUMAN_TEST_NEEDED | `fix/botg-encounter-lifecycle` | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #4 | The Net can display one target rank and destroy another | HUMAN_TEST_NEEDED | `fix/botg-encounter-lifecycle` | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #5 | Godly Hubris / Blind chip requirement can differ between preview and actual combat | HUMAN_TEST_NEEDED | `fix/blind-target-calculation` | [PR 9](https://github.com/benedictdavon/balatro-reality-warp/pull/9) |
| #6 | Chicot can visually disable custom bosses while their custom effects still execute | HUMAN_TEST_NEEDED | `fix/blind-effect-ownership` | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| #7 | Ouroboros does not reliably enforce “always draw 3 cards” after Play or Discard | HUMAN_TEST_NEEDED | `fix/round-action-draws` | APPROVE locally; unpublished |
| #8 | Helin's exponent effect can do nothing in big-number mode | BLOCKED | — | Accepted prerequisite unavailable |
| #9 | Colosseum starting Perishable Stencils can expire, then become active again | HUMAN_TEST_NEEDED | `fix/blind-effect-ownership` | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| #10 | Shortcut failed a valid one-gap Straight | STALE | — | Source disposition |
| #11 | Baby Mark appeared to trigger roughly ten times from one Red Seal Polychrome King | HUMAN_TEST_NEEDED | `docs/baby-mark-retrigger-validation` | APPROVE locally; unpublished |
| #12 | Consumable stacking compatibility / UI: no clean native stacking, and early visual-only patches buried cards | NOT_A_BUG | `docs/consumable-stacking-disposition` | APPROVE locally; unpublished |
| #13 | Dark Alchemy Tag tooltip/code probability deserves verification | BLOCKED | — | Accepted prerequisite unavailable |
| #14 | Lucky One probability logic has historically been broader than the tooltip suggests | HUMAN_TEST_NEEDED | `fix/lucky-one-rng` | APPROVE locally; unpublished |
| #15 | Battle-of-Gods boss usage counters can be polluted by blind rolls that are immediately overwritten | HUMAN_TEST_NEEDED | `fix/botg-encounter-lifecycle` | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #16 | Fused and regular boss categories overlap in the current selector | HUMAN_TEST_NEEDED | `fix/botg-encounter-lifecycle` | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #17 | Boss eligibility ignores or inconsistently applies `min`, `max`, and `in_pool()` | HUMAN_TEST_NEEDED | `fix/botg-encounter-lifecycle` | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #18 | Battle-of-Gods state has too many overlapping representations of “what Blind are we fighting?” | HUMAN_TEST_NEEDED | `fix/botg-encounter-lifecycle` | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #19 | Potential stale/delayed boss effects should be audited after Blind changes | HUMAN_TEST_NEEDED | `fix/blind-effect-ownership` | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| #20 | Consumable-stack quantity badge alignment was confusing | STALE | — | Source disposition |

| ID | Finding | Disposition | Branch | PR / acceptance |
| --- | --- | --- | --- | --- |
| R1 | Encounter parameters are not persisted and shared definitions survive runs | HUMAN_TEST_NEEDED | `fix/botg-encounter-lifecycle` | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| R2 | Iron Maiden hand size is not restored on ordinary defeat; disable restoration can repeat | HUMAN_TEST_NEEDED | `fix/iron-maiden-restoration` | [PR 5](https://github.com/benedictdavon/balatro-reality-warp/pull/5) |
| R3 | Reset-only Blind refresh compounds or erases target scaling | HUMAN_TEST_NEEDED | `fix/blind-target-calculation` | [PR 9](https://github.com/benedictdavon/balatro-reality-warp/pull/9) |
| R4 | Blanket undebuff erases other systems' restrictions | HUMAN_TEST_NEEDED | `fix/blind-effect-ownership` | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| R5 | Apotheosis/Exalted interception replaces normal Joker calculation | HUMAN_TEST_NEEDED | `fix/joker-calculation-composition` | APPROVE locally; unpublished |
| R6 | Arrow rank lookup uses invalid vanilla card keys | HUMAN_TEST_NEEDED | `fix/arrow-rank-mapping` | APPROVE locally; unpublished |
| R7 | Direct boss dissolution bypasses destruction-notification bookkeeping | HUMAN_TEST_NEEDED | `fix/blind-destruction-notifications` | [PR 6](https://github.com/benedictdavon/balatro-reality-warp/pull/6) |
| R8 | get_straight wrapper discards modern API parameters | HUMAN_TEST_NEEDED | `fix/straight-api-forwarding` | APPROVE locally; unpublished |
| R9 | Chronos and Guillotine each run at two scoring stages; Void checks before queued score addition | HUMAN_TEST_NEEDED | `fix/blind-final-scoring` | [PR 10](https://github.com/benedictdavon/balatro-reality-warp/pull/10) |
| R10 | Possession draw/discard callbacks can issue repeated or duplicate transfers | HUMAN_TEST_NEEDED | `fix/round-action-draws` | APPROVE locally; unpublished |
| R11 | Canonical Blind keys are missing from several active-effect detectors | HUMAN_TEST_NEEDED | `fix/blind-identity-contracts` | [PR 2](https://github.com/benedictdavon/balatro-reality-warp/pull/2) |
| R12 | Free reroll refunds by assigning dollars before delayed payment settles | HUMAN_TEST_NEEDED | `fix/divine-ward-reroll` | APPROVE locally; unpublished |
| R13 | The Code punishes one consumable twice and bypasses Eternal filtering | HUMAN_TEST_NEEDED | `fix/code-consumable-punishment` | [PR 7](https://github.com/benedictdavon/balatro-reality-warp/pull/7) |
| R14 | Ante-history wrapper marks the current hand as previously played before evaluation | STALE | `docs/ante-history-disposition` | [PR 8](https://github.com/benedictdavon/balatro-reality-warp/pull/8) |

## Accepted branch and commit ledger

| PR | Branch | Labels | Reviewed branch head | Main merge commit |
| --- | --- | --- | --- | --- |
| [1](https://github.com/benedictdavon/balatro-reality-warp/pull/1) | `docs/bug-backlog` | Source documents/backlog | `74b267907718284bc30baa8ae779e2c3134b1619` | `013fdf33618e4c4fd882e0f5d17a585e0c874920` |
| [2](https://github.com/benedictdavon/balatro-reality-warp/pull/2) | `fix/blind-identity-contracts` | R11 | `a2f04ca90122ad87c3b1acbcd871b522cab262f0` | `1afc7e590fa84695938b1936cd0e7b90fa4ae93e` |
| [3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) | `fix/botg-encounter-lifecycle` | 1, 3, 4, 15, 16, 17, 18, R1 | `a8ff1d020e6f5df9c2cb12a468d90f917e27cfee` | `43a90f472b2f251d75dd73175eb9b7dd19722b21` |
| [4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) | `fix/blind-effect-ownership` | 6, 9, 19, R4 | `e3e3d49ef65836945eec43f8bbb70a4ed581daf9` | `8e4c2bfad92fc0572dcdb289608895d2f452e4ac` |
| [5](https://github.com/benedictdavon/balatro-reality-warp/pull/5) | `fix/iron-maiden-restoration` | R2 | `1d261e97ea18c1b7b7fba1c20fb804dbff9174af` | `ae9dd607cf13779804f319f3bbfed732d1d0d44e` |
| [6](https://github.com/benedictdavon/balatro-reality-warp/pull/6) | `fix/blind-destruction-notifications` | R7 | `0ed19edc31853dc6c19965adefccf3a8909b929b` | `ce82699d5c9d5ca75437d56e416129cb7d7001e2` |
| [7](https://github.com/benedictdavon/balatro-reality-warp/pull/7) | `fix/code-consumable-punishment` | R13 | `2faf7fc1193546b3b35d6c5849b09cbc292b5000` | `592b30092d611a7b78694c21fff7d1b68e86a715` |
| [8](https://github.com/benedictdavon/balatro-reality-warp/pull/8) | `docs/ante-history-disposition` | R14 | `df9a632fe28e9495d69e1d2cd6b00a7b715a86e2` | `e8212e55654a98e20f571513c5381ddba03f8dc7` |
| [9](https://github.com/benedictdavon/balatro-reality-warp/pull/9) | `fix/blind-target-calculation` | 5, R3 | `187e53991c6ff4e76713fdde7412924fd67e4930` | `50babb21ba2297437510ecf0ea5eb025fb5b2504` |
| [10](https://github.com/benedictdavon/balatro-reality-warp/pull/10) | `fix/blind-final-scoring` | R9 | `7577bfdd364cd12ca4b982ac70d6ab9740921328` | `f863d0c2c543c4befa481803a581847ca8fe7274` |

Implementation commits (where separate from the reviewed head):

- PR 5: `2155e8ccf5f5f6dd30cc4ad1df7d5739eaf10b79`.
- PR 6: `333c3fd0c27009a540369e449b22d437f3dbfef3`; correction `64e7576eeb9b103dfee2bd8936a5c7071fc80321`.
- PR 7: `8fc3d43fa92ace3818cf03ad7ca8bda805ed7d83`.
- PR 8: `e4c4fc18c650cab22967ee11f709f83ea6d486b6`.
- PR 9: `8b6b0b910fb6466aade2ae2df18b7254fb3fc2c3`.
- PR 10: `0b6204ed03f92c191fa3ef39bd6ca3efd8709ba4`.

## Local approved candidate ledger

All candidates below are unpublished: no PR number, push, merge or combined-main test is claimed. Rebase/merge accepted updates into each SAME branch, resolve documentation together, independently re-review combined wrapper ordering and run meaningful checks before publishing it. Do not create a dependent branch until its prerequisite is accepted on main. Record the eventual PR and merge here.

| Labels | Branch | Implementation / disposition commit | Reviewed candidate head | Review |
| --- | --- | --- | --- | --- |
| R6 | `fix/arrow-rank-mapping` | `31015cf76b9637e6ddcce757b1528ce07e81690e` | `31015cf76b9637e6ddcce757b1528ce07e81690e` | APPROVE locally |
| R5 | `fix/joker-calculation-composition` | `62a4cf10945c28580920720c90e51af931a4ef85` | `73cda54a024f490991d705be8f06d7aaad019a32` | APPROVE locally |
| 7, R10 | `fix/round-action-draws` | `99618014e3ce21a30b0c9b04f632c652343b082d` | `f60413a7cbf4ff49f683ff3bfedef0d19732a766` | APPROVE locally |
| R8 | `fix/straight-api-forwarding` | `19b60afda787c64d6da37de9ea43923d1893c8dc` | `9a2d8e484bd359086fcbaf4cf108e87f78362b0d` | APPROVE locally |
| R12 | `fix/divine-ward-reroll` | `2e57572528f044da1a002ca492cffd39d2840681` | `76bdcea1186425baf45dd36fb20339b4c8c8f7ca` | APPROVE locally |
| 11 | `docs/baby-mark-retrigger-validation` | `74e5961fc2407d6c14ed477e12af05308e0d6eed` | `9f6c9eec54cb52e8187165aeb14b8222beaf5824` | APPROVE locally |
| 14 | `fix/lucky-one-rng` | `c53fffc6a9fac38f2a2816b3e9359cd706e54bb3` | `12adc5516dbb60c4d0073dc9942262acad07c550` | APPROVE locally |
| 12 | `docs/consumable-stacking-disposition` | `c6c78485bb752df26e8347c313465875b93b0548` | `c6c78485bb752df26e8347c313465875b93b0548` | APPROVE locally |

R5 correction: `eadc076a1f61c2db1085bc95a10afe888c83e3c2`. Draw corrections: `0b386690550d3126916492fb42e4dc91d62dcf43` and `7c1cd917fbbc80c74e7f3197bbefd0e31ac86995`. Lucky corrections: `305ad622a5bcf03dab0498be6e8a4f88abad76b2` and `288e6ba4720326f4189aaad41ed061d4d98f88eb`; copied probability tests `39a503d6c5701427709ba2cb342c752fd5485a6e`. These retain their original hashes when integrating accepted prerequisites.

Documentation-only #12 source disposition was delegated to Luna Max and independently approved by Sol High at `c6c78485bb752df26e8347c313465875b93b0548`; root subsequently consolidated coordination metadata and regression procedures on the same documentation branch. Its final coordination head will be recorded in the continuation report; the source disposition commit above is immutable.

## Genuine unavailable dependency and continuation

Automatic approval review rejected the Arrow branch publication escalation twice. The second decision explicitly required human approval for the exact public payload/destination and prohibited alternate routes. The existing unanswered question covers Arrow at `31015cf76b9637e6ddcce757b1528ce07e81690e` (boss_blinds.lua, focused test, three stabilization documents) to the public fork [benedictdavon/balatro-reality-warp](https://github.com/benedictdavon/balatro-reality-warp), plus optional authorization of the remaining reviewed source/tests/stabilization documents. No alternate publication route or retry has been attempted after that decision. Repository technical push/admin permissions do not replace this missing approval.

| Blocked label | Required accepted prerequisite | Next concrete work after approval/merge |
| --- | --- | --- |
| #2 | #7/R10 `fix/round-action-draws` | Isolate Ares/Violet discard symptom with possessions/Familiars absent, then owner-specific controls; do not guess another suppression patch. |
| #8 | R5 `fix/joker-calculation-composition` | Formal Helin validation on restored original calculation. Actual installed Amulet supports e_mult; the audit unsupported-key theory is contradicted by source-extracted tests. |
| #13 | #14 `fix/lucky-one-rng` | Establish Dark Alchemy exact odds/sample/options contract after unowned RNG hook removal; fix the overlapping paths on a fresh branch. |

#13 read-only revalidation found two 3% paths overlapping with native edition polling; default combined negative probability was approximately 0.060846 versus baseline 0.003, not documented 10x. This arithmetic is source analysis, not a Monte Carlo/game test. Edition API options/no_neg and first-shop tag timing need a bounded fix after the prerequisite. #8 source-extracted actual numeric/Omega effect tests produce 12→144→20,736→429,981,696; formal mode/Blueprint/cold gameplay still depends on accepted R5. Difficulty and absent game execution are not used to justify these three workflow blocks.

After approval: publish/attach/review/merge Arrow first; refresh accepted main. Integrate and publish each independent queued branch separately, preserving prior commits and revalidating merged chains. Process the three newly dependency-ready labels on their own fresh branches. Revalidate every remaining finding after architectural merges. Only then begin the separately requested POST report workflow. Optional consumable quantity implementation remains a separate feature, not a silently included bug fix.

## Validation and limits

Accepted changes have eight focused Lua harnesses for identity, encounters, effect/resource ownership, destruction, Code, targets and final scoring. Each pending branch has its own applicable native-source/stub harness and complete-diff review; Lucky adds a ninth on its branch. The manual Mark branch supplies validation without an unsupported production patch. All repository Lua 5.1 compilation, shipping TOML/payload compilation, relevant installed exact original-or-applied boundary checks and diff checks passed for their respective candidates. Lucky additionally executes actual installed Amulet Omega probability ratios under LuaJIT and fully applied/mixed/duplicate reset fixtures in memory. R12 executes native UI/fee sources with explicitly modeled queued payments. No local test imports pending independent production changes.

These are branch-specific validations, not combined-main or Balatro claims. Labeled adapters model UI/effect sinks, queued boundaries and serialization reconstruction where the game is unavailable. Cold game restart, actual optional-mod interplay, winning-hand scheduling and long-run performance remain manual. Known stock test-runner original-only matcher limitation N3 is repaired on the local R5 branch; independent original/applied checkers were used elsewhere. Generated installed dumps, saves and untracked POST source were not modified.

## New findings outside the original audit

| Local ID | Evidence / disposition | Follow-up |
| --- | --- | --- |
| N1 | Familiar outer draw wrapper ignores numeric refill argument; separately tracked source risk. | Own future bounded branch; do not conflate with fixed action ownership. |
| N2 | Potion Mirror first-return-only aggregation loses nested/XMult effects and mutates the first result; outside R5 bounded ownership. | Separate composition fix after accepted prerequisites. |
| N3 | Stock test driver assumes original-only Lovely dump patterns. FIXED locally in R5 checker. | Publish with that reviewed branch; no accepted-main claim. |
| N4 | Familiar outer draw wrapper drops the lower game-over return, even without a Familiar; possible later SELECTING_HAND overwrite. | Separate return-preservation fix; revalidate dependencies before implementation. |
| N5 | Existing Colorful flush/isSuit helpers can count removed/out-of-area owners; R8 changes straight forwarding only. | Separate live-owner fix after R8 accepted. |
| N6 | Hypnotist blindly clears all playing-card debuffs after native Blind disable, potentially erasing independent sources. | Separate owned cleanup after R4; typed chance integration does not fix this ownership defect. |

Local N1–N6 IDs are distinct from POST-N3–POST-N9 source labels. POST has not yet been adjudicated. Intentional controls A (Black Hole sequential exponentiation), B (Perfectionism Negative replacement), and C (Upgrade Roulette pre-scoring progression) remain NOT_A_BUG. #10 is STALE because the offending fallback is absent; R8 separately fixes active API forwarding. #20 is STALE because the quantity badge is absent. R14 is STALE because the premature global wrapper is absent and native queued history timing is appropriate. #12 is NOT_A_BUG as a missing optional feature; it does not claim a working stack model or historical-patch compatibility.

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
| #2 (blocked) | After R10 accepted, Ares/Violet alone with no possessions/Familiars, then Hook/Water separately; Minotaur disabled and stale transition controls. | No unexplained random discard in isolated Ares/Violet; source of any actual discard traced to owning effect before further patch. |
| #8 (blocked) | After R5 accepted, Helin power 2 at Mult 12, Blueprint copies 0/1/2, normal numbers then installed Amulet, all applicable modes and cold restart. | 144 / 20,736 / 429,981,696 from sequential exponentiation; supported e_mult dispatch retained. Large magnitude alone is expected. |
| #13 (blocked) | After #14 accepted, Dark Alchemy only, negative-eligible shop/pack Jokers with default/custom options, no_neg controls and tag activation before first shop card. Capture baseline/tag thresholds and one sample per poll. | Formal odds contract established and implemented on accepted prerequisites; current overlapping 3% paths are not treated as verified 10x. |
| #12 / #20 controls | Optional native baseline: repeated Negative Tarot/Planet/Spectral cards, ordinary separate use/sell/copy, save/cold restart and hover/drag/controller navigation. No stacking mod. | Current fork uses separate Card objects. Historical quantity/hitbox patches and badge are absent; no implemented stacking feature is claimed. |
| A/B/C controls | Black Hole sequential Blueprint exponent; Perfectionism edition replacement; Upgrade Roulette pre-scoring/Stone/Glass progression. | Existing intentional behavior remains unchanged. |

Recommended sequence: native baseline and intentional controls → identity/progression/persistence → target previews → disabled/queued ownership and resources → removal/Code → final scoring → rank/straight → Joker composition → draws/possessions → Lucky ownership/end-round/cold save → focused Mark/reroll → the three dependency-blocked cases after their accepted prerequisites → full long Colosseum run with cold checkpoints and separate optional mod integrations. POST runtime findings are a later user-requested phase, not evidence that these agent tests executed the game.
