# POST runtime stabilization

Resumed by direct human instruction Begin post. Initial accepted main is c94227daa5b08dfe7e26497fe601b19e9ebb2b02. The original source pass and PRs 1–22 are recorded in STABILIZATION_STATUS.md; PR 23 merged that final report; original #9 is now reopened from the runtime report.

POST_SOL_RUNTIME_FINDINGS.md is the immutable user input, now tracked through this documentation branch. Reported test checkpoint f863d0c predates later accepted fixes, so every claim must be revalidated. No agent game execution is claimed.

Initial order: crash N7 → architectural Ante N6 → starter policy #9 → offer uniqueness N8 → adoption persistence N3 → Echo N4 → performance diagnostics N9 → isolated Manacle attribution N5. All issue branches start only after prerequisite merges and a refreshed main.

| ID | Finding | Current state | Dependency / next evidence |
| --- | --- | --- | --- |
| POST-N7 | Croupier calls an unavailable dice sound | READY | Initial POST tracking acceptance |
| POST-N6 | Hieroglyph changes difficulty Ante and regenerates encounter schedule | AUDITED | POST-N7; accepted encounter/target contracts |
| POST-#9 | Starter Perishables are continuously refreshed by Thanatos | AUDITED | POST-N6; human requires all-Perishable refresh; clarify Thanatos trigger |
| POST-N8 | Shop and pack duplicate Joker offers escape owner-only check | AUDITED | POST-N7; accepted Dark Alchemy creation scope |
| POST-N3 | BOTG-adopted Familiar lacks permanent unlock/discovery | AUDITED | POST-N7; native unlock/profile save contracts |
| POST-N4 | Pending Echo Tags consume only one tag | AUDITED | POST-N7; native Tag:yep removal/event semantics |
| POST-N9 | Long-run performance degrades and cold restart restores it | AUDITED | POST-N7/N6/#9/N8/N3/N4 accepted; isolate current stack and profile |
| POST-N5 | Manacle-associated two-dollar loss may be Divine Zap | AUDITED | POST-N6 ownership/progression checks; source-isolated counterattack validation |


Human policy received: refresh all perishable after thanatos. Thanatos is the name of the showdown cleansing mechanic, not a registered Blind. All-Perishable scope is authorized; every-showdown versus milestone trigger clarification is pending. Preserve explicit4-round starters and current Rental cleansing until resolved. Successful adoption should follow the report's preferred permanent unlock/discovery policy; preview/decline must not unlock.

N9 requires profiling before a production fix. A runtime-only final disposition must provide exact instrumentation/isolation procedures and distinguish reported old gameplay from current agent source checks. Do not blame a specific optional mod from patch warnings.

POST-A1 is newly discovered outside the posted audit: Croupier high-roll retrigger flag is read/cleared but never written. Keep it separate from the sound crash, trace native repetition ordering before implementing, and report it as a residual finding if not processed in this posted pass.

The original local N1/N2/N4/N5/N6 findings remain separate. No newly proposed source fix has been committed by this initial documentation PR.

## Initial source revalidation

Read-only Lua 5.1 checks reproduced POST-N6 on the current source: changing only numeric Ante and scheduling again advanced encounter sequence 6 to 9, replaced the defeated Small and upcoming Boss encounter IDs, and replenished a consumed Divine Ward. BOTG base requirements at Ante 0 and Ante 1 both returned 15,000. The future architectural patch must separate schedule progression from difficulty and cover Ward ownership as part of that same root cause.

A check executing installed native Perishable calculation and the current Thanatos defeat wrapper produced 4 → 3 → 2 → 1 → 0 with expiration. A regular Boss defeat left the Joker expired; a showdown refreshed both an expired starter-style Perishable and another Perishable to 5, removed Rental, and retained an independent debuff through a labeled recalculation adapter. This supports current-code expiration and all-Perishable cleansing; the historical game symptom and pending trigger policy are not closed by this check.

A check executing the current Echo wrapper with installed native Tag:yep reproduced two Echo Tags plus Negative yielding three Negative Tags and one remaining Echo. Tag construction/removal, lower add_tag storage and FIFO event draining were labeled adapters, so this establishes the wrapper defect without claiming real game event timing or rendering.

Native Familiar persistence uses unlock_card/discover_card and Game:save_progress to serialize registered-center unlock/discovery flags. Nursery additionally checks the profile's witch_discovered_familiars record. Adoption currently changes only the active Card's flags; the eventual fix must cover successful adoption/replacement, profile persistence and Nursery together while leaving previews, declined offers and cold-run restoration unable to unlock new rewards.

Public POST publication remains awaiting explicit human approval after automatic approval review rejected the push of this documentation branch. That rejection said the earlier publication authorization covered the named original branches and did not specifically authorize exporting the POST report. No POST branch has been pushed, no POST PR exists, and accepted main remains c94227daa5b08dfe7e26497fe601b19e9ebb2b02. Local review and source investigations continue; sequential dependent issue branches wait for the tracking PR's actual acceptance.
