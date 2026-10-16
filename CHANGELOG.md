# Historial de cambios

**Nota:** Todas las fechas están en zona horaria CST de Ciudad de México (UTC-6).

<!-- markdownlint-disable MD013 MD024 MD022 MD032 -->
## [2026-10-16] - Primeras *skills* adaptadas de incognia/rules

- docs: agregar `CONTRIBUTING.md` con cómo está organizado el repositorio (*skills*, CoT, *rulesets* y *scripts*), las reglas (rutas en `~/skills/`, nada personal en archivos versionados), cómo probar cada cambio y cómo enviarlo, y enlazarlo desde el `README.md`
- docs: reescribir el `README.md` con lo que incluye el repositorio, la instalación en `~/skills/`, cómo crear tu `~/skills/.env` y el flujo de `/changelogger` y `/commit`; agregar este historial de cambios
- chore: agregar el `.gitignore` (que bloquea `.env` y deja pasar `.env.example`) y poner a 4-20 Systems como titular del *copyright* en `LICENSE`
- feat: agregar los *scripts* `sync_global.sh` (instala las *skills* en `~/.agents/skills/` y `~/.claude/commands/` y copia `cot/`, `rulesets/` y `scripts/` a `~/skills/`, sin Warp ni Atlassian y con su propia lista de *skills* administradas), `commit_trailer.py` y `git-init-context.sh`, que ahora toma la identidad de `GIT_NAME`, `GIT_EMAIL` y `GIT_SSH_KEY` de `~/skills/.env` sin cargar el archivo completo; agregar la plantilla `.env.example`
- docs: agregar los *rulesets* `COMMITTING.md`, `GIT.md` (reescrito para que cada persona use su propia identidad desde `~/skills/.env`), `LINGUISTICS.md` y `RELEASING.md`, con licencia MIT
- feat: agregar los CoT `committing.md`, `changelog.md`, `git_init.md`, `release.md` y la plantilla `_template.md`; `committing.md` y `git_init.md` validan y configuran la identidad con `~/skills/.env` en lugar de contextos personales o laborales fijos
- feat: agregar las *skills* `commit`, `changelogger` y `mr`, copiadas de `incognia/rules` (`8a48bfd`) con todas sus rutas en `~/skills/`; `/commit` valida la identidad contra `~/skills/.env`
