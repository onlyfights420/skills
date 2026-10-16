# skills

*Skills* de Claude Code para colaborar en los proyectos de `onlyfights420`: `/changelogger`, `/commit` y, más adelante, un `/pr` para GitHub (crear, aprobar e integrar con *rebase*) que conserva intactos los *commits* de cada autor. Están adaptadas de [`incognia/rules`](https://github.com/incognia/rules).

## Qué incluye

| Carpeta | Qué hay |
|---|---|
| `.agents/skills/` | Las *skills*: `commit`, `changelogger` y `mr` (merge requests de GitLab; base para el futuro `/pr`) |
| `cot/` | Las cadenas de razonamiento que siguen las *skills*: `committing.md`, `changelog.md`, `git_init.md` y `release.md` |
| `rulesets/` | Las reglas de referencia: `COMMITTING.md`, `GIT.md`, `LINGUISTICS.md` y `RELEASING.md` |
| `scripts/` | `sync_global.sh` (instalación), `commit_trailer.py` (atribución del agente en cada *commit*) y `git-init-context.sh` (identidad y SSH por repositorio) |

## Instalación

Se instala en **`~/skills/`**, que corresponde uno a uno con este repositorio (igual que `incognia/rules` vive en `~/rules/`). Funciona en Linux y macOS.

```bash
git clone git@github.com:onlyfights420/skills.git ~/skills
~/skills/scripts/sync_global.sh
```

El *script* copia las *skills* a `~/.agents/skills/` y crea los comandos de Claude Code en `~/.claude/commands/` (`/commit`, `/changelogger`, `/mr`). Para actualizar, basta con `git -C ~/skills pull` y volver a correrlo.

### Tu identidad

Cada persona usa su propia identidad y su propia llave SSH, que viven en `~/skills/.env` (no se sube al repositorio):

```bash
cp ~/skills/.env.example ~/skills/.env
chmod 600 ~/skills/.env
```

Llena `GIT_NAME`, `GIT_EMAIL` y `GIT_SSH_KEY` con los datos de tu cuenta de GitHub. Con eso, `git-init-context.sh` configura cada repositorio y `/commit` comprueba que el *commit* salga a tu nombre. El detalle está en [`rulesets/GIT.md`](./rulesets/GIT.md).

## Cómo se usan

1. Haz tu cambio.
2. `/changelogger`: agrega la entrada del día al `CHANGELOG.md`.
3. `/commit`: valida tu identidad y el CHANGELOG, y hace *commits* atómicos en inglés internacional (UK) con la línea `Co-Authored-By:` del agente que te ayudó.

Los PR se integran con *rebase*, conservando el mensaje, el autor y el `Co-Authored-By` de cada *commit*.

## Contribuir

Lee [CONTRIBUTING.md](./CONTRIBUTING.md): cómo está organizado el repositorio, las reglas, cómo probar un cambio y cómo enviarlo.

## Licencia

Licencia MIT; ver [LICENSE](./LICENSE).

---

*Copyright © 2026 4-20 Systems. Adaptado de `incognia/rules`, de Rodrigo Álvarez (@incognia).*
