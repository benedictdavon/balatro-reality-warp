# Original stabilization final report

Historical original-source snapshot. The human has since resumed POST; current phase state is in POST_STABILIZATION_STATUS.md and original #9 is reopened in BUG_BACKLOG.md. The original ledger and final dispositions below record the accepted original pass, not the newly reopened POST investigation.

Accepted source snapshot: main/origin/main 52f76d72e9a980275446fb9707640288c573f139 (PR22). PRs 1–22 are accepted and merged. This documentation-only report branch starts from that accepted source head; its eventual merge adds no source or test changes. Public publication and controlled merging after technical approval are authorized.

AGENTS.md, ISSUE.md and BUG_AUDIT.md are tracked. At this original checkpoint POST_SOL_RUNTIME_FINDINGS.md was preserved untouched and untracked, and POST was deferred. The resumed phase now tracks that unchanged input; see the historical-snapshot notice above.

The original stabilization pass is complete under AGENTS.md's autonomous completion rule: all 34 original labels have an explicit final disposition, with 30 HUMAN_TEST_NEEDED, 3 STALE and 1 NOT_A_BUG. There are no unaccounted original findings or merge blockers. Every source candidate has completed applicable agent checks, technical review and actual acceptance. HUMAN_TEST_NEEDED is a terminal source disposition, not a claim of verified gameplay. No Balatro execution or cold-runtime verification is claimed.

The accepted changes restore encounter identity/persistence, effect ownership/cleanup, target/scoring rules, Joker composition, draw boundaries and scoped probability behavior. Revalidation avoided speculative patches for Ares/Vessel, Helin, Baby Mark and the stale/non-bug reports. #12 records the absent optional stacking feature; this pass does not implement it. Full issue evidence remains in BUG_BACKLOG.md, and reproducible gameplay procedures remain in REGRESSION_TESTS.md.

## Original findings

| ID | Finding | Disposition | Branch | PR / acceptance |
| --- | --- | --- | --- | --- |
| #1 | Battle of Gods / Colosseum can display one Blind while a different Blind or effect is actually active | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #2 | Ares / Violet Vessel sometimes behave like The Hook / Minotaur and discard two random cards | HUMAN_TEST_NEEDED | docs/ares-vessel-discard-validation | [PR 19](https://github.com/benedictdavon/balatro-reality-warp/pull/19) (accepted) |
| #3 | Athena can display one required poker hand and enforce another | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #4 | The Net can display one target rank and destroy another | HUMAN_TEST_NEEDED | fix/botg-encounter-lifecycle | [PR 3](https://github.com/benedictdavon/balatro-reality-warp/pull/3) |
| #5 | Godly Hubris / Blind chip requirement can differ between preview and actual combat | HUMAN_TEST_NEEDED | fix/blind-target-calculation | [PR 9](https://github.com/benedictdavon/balatro-reality-warp/pull/9); [N7 PR20](https://github.com/benedictdavon/balatro-reality-warp/pull/20) (accepted) |
| #6 | Chicot can visually disable custom bosses while their custom effects still execute | HUMAN_TEST_NEEDED | fix/blind-effect-ownership | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| #7 | Ouroboros does not reliably enforce “always draw 3 cards” after Play or Discard | HUMAN_TEST_NEEDED | fix/round-action-draws | [PR 13](https://github.com/benedictdavon/balatro-reality-warp/pull/13) |
| #8 | Helin's exponent effect can do nothing in big-number mode | HUMAN_TEST_NEEDED | docs/helin-exponent-validation | [PR21](https://github.com/benedictdavon/balatro-reality-warp/pull/21) (accepted) |
| #9 | Colosseum starting Perishable Stencils can expire, then become active again | HUMAN_TEST_NEEDED | fix/blind-effect-ownership | [PR 4](https://github.com/benedictdavon/balatro-reality-warp/pull/4) |
| #10 | Shortcut failed a valid one-gap Straight | STALE | — | Source disposition |
| #11 | Baby Mark appeared to trigger roughly ten times from one Red Seal Polychrome King | HUMAN_TEST_NEEDED | docs/baby-mark-retrigger-validation | [PR 16](https://github.com/benedictdavon/balatro-reality-warp/pull/16) |
| #12 | Consumable stacking compatibility / UI: no clean native stacking, and early visual-only patches buried cards | NOT_A_BUG | docs/consumable-stacking-disposition | [PR 18](https://github.com/benedictdavon/balatro-reality-warp/pull/18) |
| #13 | Dark Alchemy Tag tooltip/code probability deserves verification | HUMAN_TEST_NEEDED | fix/dark-alchemy-edition-weight | [PR22](https://github.com/benedictdavon/balatro-reality-warp/pull/22) (accepted) |
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
| [PR20](https://github.com/benedictdavon/balatro-reality-warp/pull/20) | fix/vessel-target-key | N7 / #5 | 0c1e38fc3a32d1818efcebad4cb295e5b7799add | 57d541ec20c6f85d9d05c42e03816a9652f304d7 | adf2df084fee06bbdb6036f61ae6d8e7905f2402 |
| [PR21](https://github.com/benedictdavon/balatro-reality-warp/pull/21) | docs/helin-exponent-validation | 8 | ec9470cbf18e9eb9d91ca9fd862a68b9653e3fc1 | fd7c4db95ae1af1e175ba436e127da6614e34cfa | 475b549498f2bc693524f428c7cd3b6a7ca72729 |
| [PR22](https://github.com/benedictdavon/balatro-reality-warp/pull/22) | fix/dark-alchemy-edition-weight | 13 | a3b34017c84f9c50d4be13d5a6ace3c36a8ed8bb | 82b06c2aab9014b42a2475629671d7642624dc09 | 52f76d72e9a980275446fb9707640288c573f139 |

Correction and integration commits remain in the linked accepted PR histories. All 22 ledger entries have actual source, reviewed-head and merge commits in accepted main. PR22 source a3b34017c84f9c50d4be13d5a6ace3c36a8ed8bb was independently reviewed APPROVE by Luna; Sol High reviewed the complete published diff at final head 82b06c2aab9014b42a2475629671d7642624dc09 and recorded technical APPROVE before the expected-head merge. GitHub forbids the shared author account from self-approving, so technical approval is pinned in a COMMENT review; controlled merge authorization comes directly from the human.

Additional correction/integration provenance:

- PR 6: correction 64e7576eeb9b103dfee2bd8936a5c7071fc80321.
- PR 12: corrections eadc076a1f61c2db1085bc95a10afe888c83e3c2; corrections 6856781df919d338e9fdb8b393a80e80ecd0358a; integration 2b0d9d399a80aad7020e22030f146c1794e8204b.
- PR 13: corrections 0b386690550d3126916492fb42e4dc91d62dcf43; corrections 7c1cd917fbbc80c74e7f3197bbefd0e31ac86995; integration ddd97d7ae592a47fc6e29b100a31023c4297ed5c.
- PR 14: integration 528ec0d34b0bb8c249efb5e27cf12bddcba143ab.
- PR 15: integration 844a30ca2f338fa09d5666985ba1ef7a43ab8780; earlier documentation/review records d271c4504c31f79af7cde0fc8291c0787ecb357c and 76bdcea1186425baf45dd36fb20339b4c8c8f7ca.
- PR 16: correction e1f23a4bc62e3024c9dcaa4258afc4b6667d88bf; integration 8593e599082fbd7893270c60472313871a2a3e51.
- PR 17: corrections 305ad622a5bcf03dab0498be6e8a4f88abad76b2; corrections 39a503d6c5701427709ba2cb342c752fd5485a6e; corrections 288e6ba4720326f4189aaad41ed061d4d98f88eb; integration f0cc1ed64b38a823ad2c25785bc582541e20216e; test integration 65aef4ef908d64955f6155b8b37385c866f4c954.
- PR 18: corrections c3ca8f8b2a16144ddb7f04dbf33e982431a1839a; corrections aa90b85ce32d56faa34703fac4ab067777f77424; integration c3219964853efa360eac17cf2a09ab07521c460c.
- PR 22: correction eda648bd8ed646f75db3cac970eb722a6b4595ff.

## Validation and limits

The final accepted source has 18 passing focused Lua harnesses, Lua 5.1 source compilation, shipping TOML/payload compilation and original-or-fully-applied native boundary validation. Lucky additionally passes actual installed Amulet Omega probability-ratio checks under LuaJIT and in-memory original/full/mixed/duplicate reset fixtures. Mark exercises actual native scoring and copy callbacks with labeled UI/event/card adapters. Real games, cold restart, optional-mod interplay and scheduling remain human tests. Helin additionally passes actual installed Omega exponent/Amulet dispatch under LuaJIT. Dark Alchemy executes actual native creation and both poll backends with labeled adapters and 10,000 deterministic midpoint controls. PR22 adds one ownership module/fixture, removes duplicate additive paths and updates its tooltip/docs. The final documentation pass verifies source inventory, every original row, accepted Git ancestry, immutable provenance and the complete documentation diff. No installed dump or save is modified.

## New findings outside the original audit

| Local ID | Evidence / disposition | Follow-up |
| --- | --- | --- |
| N1 | Familiar outer draw wrapper ignores numeric refill arguments. | Separate future bounded branch. |
| N2 | Potion Mirror loses nested/XMult effects and mutates the first result. | Separate composition fix. |
| N3 | FIXED on accepted PR 12: native dump checker accepts original or fully applied boundaries and rejects partial/duplicate/mixed forms. | No runtime claim; accepted checker validation complete. |
| N4 | Familiar outer draw wrapper drops native early return and extra arguments, even without a Familiar. | Separate return-preservation fix after revalidation. |
| N5 | Colorful flush/isSuit can count removed or out-of-area owners. | Separate live-owner fix. |
| N6 | Hypnotist clears independently owned playing-card debuffs after native disable. | Separate owned-cleanup fix. |
| N7 | Actual Violet Vessel key is bl_final_vessel; PR9 originally used nonexistent bl_vessel. | Accepted PR20 canonical correction/native fixture; HUMAN_TEST_NEEDED. |

These local N identifiers are distinct from the deferred POST report. A Black Hole sequential exponentiation, B Perfectionism Negative replacement and C Upgrade Roulette pre-scoring progression remain NOT_A_BUG. #10 is STALE because the historical hand is accepted by the current fallback; R14 is STALE because the alleged bare-global hook is dormant on the installed namespaced route. R8 independently fixes current API forwarding. #20 is STALE because its quantity badge is absent. #12 records an optional feature gap, without claiming a working stack model.

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
| #11 | Baby Mark level 1 then 5, one face King, no other retrigger source; plain, Red Seal, Polychrome, both, then Baby Bell positive control. Log actual scoring passes/callbacks separately from messages, native deck then Colosseum; save/cold restart and separate Amulet/JokerDisplay. | Mark applies once per actual played face-card evaluation; it does not request repetitions. Polychrome adds edition scoring, not another scoring pass. Red Seal alone gives the native extra pass. |
| #14 | One/two Lucky Ones plus Blueprint/Mirror; 5/10 Clubs with/without Red Seal; 1/2 stored charges. Space/Bloodstone/Lucky/Wheel/BabyWheel and harmful Ares/Hades/Guillotine; fixed Bell/Acorn/Destilacion/BOTG/Echo/Miner; shop/cosmetic/UI/Falta/Doppel/no_resolve controls. Win/loss/saved loss with main and held end-round chance; cold-save legacy/current counters. | Only real modifiable owned rolls spend one physical charge, native sample still runs once. Fixed chances retain odds/charges; each real success grows each captured eligible Lucky once. Duplicate copied receivers do not grow, distinct copied probability rolls do. Held outcomes run before final reset. |
| #2 | R10 is accepted: Ares/Violet alone with no possessions/Familiars, then Hook/Water separately; Minotaur disabled and stale transition controls. | No unexplained random discard in isolated Ares/Violet; source of any actual discard traced to owning effect before further patch. |
| #8 | R5 is accepted: Helin power 2 at Mult 12, Blueprint copies 0/1/2, normal numbers then installed Amulet, all applicable modes and cold restart. | 144 / 20,736 / 429,981,696 from sequential exponentiation; supported e_mult dispatch retained. Large magnitude alone is expected. |
| #13 | #14 is accepted: Dark Alchemy only, negative-eligible shop/pack Jokers with default/custom options, no_neg controls and tag activation before first shop card. Capture baseline/tag thresholds and one sample per poll. | One initial owned shop/pack Joker edition poll multiplies modified Negative weight by 10; default native 0.3% becomes 3%, other editions and one native sample are retained. Aura/no_negative/guaranteed/explicit weighted pools remain native. Tag activation precedes first stock; expiry and existing fees are preserved. Custom/rate/capped pools follow native weighting, not a universal absolute probability promise. |
| #12 / #20 controls | Optional native baseline: repeated Negative Tarot/Planet/Spectral cards, ordinary separate use/sell/copy, save/cold restart and hover/drag/controller navigation. No stacking mod. | Current fork uses separate Card objects. Historical quantity/hitbox patches and badge are absent; no implemented stacking feature is claimed. |
| A/B/C controls | Black Hole sequential Blueprint exponent; Perfectionism edition replacement; Upgrade Roulette pre-scoring/Stone/Glass progression. | Existing intentional behavior remains unchanged. |

Recommended sequence: native baseline and intentional controls → identity/progression/persistence → target previews → disabled/queued ownership and resources → removal/Code → final scoring → rank/straight → Joker composition → draws/possessions → Lucky ownership/end-round/cold save → focused Mark/reroll → accepted Ares/Vessel, Helin and Dark Alchemy source dispositions → full long Colosseum run with cold checkpoints and separate optional mod integrations. POST runtime findings are a later user-requested phase, not evidence that these agent tests executed the game.


## Residual risks and scope

Gameplay event order, real UI behavior, the actual save codec/cold restart, optional-mod wrapper ordering and historical inventories remain unverified. Headless adapters and deterministic probability thresholds establish source contracts, not whole-game behavior or statistical gameplay results. In particular, #2/#8/#11 require the documented isolated inventory and callback measurements before attributing a historical symptom to a new defect.

The newly discovered N1/N2/N4/N5/N6 findings remain outside the original audit, documented for separate revalidation and bounded branches. N3 is fixed; N7 was required for original #5 and is accepted, pending its game test. Familiar draws/return forwarding and active Potion Mirror secondary effects limit claims about the full outer wrapper chain. Hypnotist independent debuff cleanup and Colorful pending-removal ownership remain separate risks. Existing outer create wrappers also retain their preexisting eight-argument/one-Card-return contract; PR22 preserves native current calls and its own full forwarding contract.

A/B/C intentional behaviors remain NOT_A_BUG. No consumable quantity model or badge is shipped. This original report did not start POST audit or implementation; the subsequent Begin post instruction resumes that separate phase, as noted above. There are no unavailable external dependencies blocking the completed original source pass.
