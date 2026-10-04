# POST runtime stabilization

Resumed by direct human instruction Begin post. Initial accepted main is c94227daa5b08dfe7e26497fe601b19e9ebb2b02. Original source pass and its23 merged PRs remain in STABILIZATION_STATUS.md; original #9 is now reopened from the runtime report.

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
