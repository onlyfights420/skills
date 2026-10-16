# Cómo contribuir

Estas *skills* las siguen agentes de IA al pie de la letra: un error en una regla se repite en cada *commit* de quien las use. Por eso cada cambio se prueba antes de integrarse.

Esta guía complementa las [reglas generales de 4-20 Systems](https://github.com/onlyfights420/.github/blob/main/CONTRIBUTING.md) y su [política de seguridad](https://github.com/onlyfights420/.github/blob/main/SECURITY.md); si algo choca, manda esta guía.

## Antes de empezar

- Instala el repositorio en `~/skills/` y crea tu `~/skills/.env` siguiendo el [README](./README.md#instalación).
- Usa tu propia cuenta de GitHub y tu propia llave SSH.
- Trabaja desde Linux o macOS.

## Cómo está organizado

| Capa | Dónde | Qué define |
|---|---|---|
| *Skill* | `.agents/skills/<nombre>/SKILL.md` | La interfaz: qué hace y qué pasos sigue el agente |
| CoT | `cot/<nombre>.md` | El razonamiento paso a paso que la *skill* manda leer completo |
| *Ruleset* | `rulesets/<NOMBRE>.md` | Las reglas de referencia que cita el CoT |
| *Script* | `scripts/` | La instalación y las ayudas que corren las *skills* |

Si cambias una regla, actualízala en las tres capas que la mencionan, para que no se contradigan.

## Reglas

1. **Las rutas apuntan a `~/skills/`**, nunca a `~/rules/`: el repositorio se instala ahí y las *skills* leen sus CoT y *rulesets* desde esa ruta.
2. **Nada personal en archivos versionados:** nombres, correos, llaves e identificadores de empresa van en `~/skills/.env` (plantilla en `.env.example`), nunca en una *skill*, un CoT o un *script*.
3. **Los *scripts* leen del `.env` solo las variables que necesitan**, sin cargar ni imprimir el archivo completo.
4. **Compatibles con el origen:** estas *skills* vienen de [`incognia/rules`](https://github.com/incognia/rules). Si un cambio mejora algo que también sirve allá, propónlo en los dos repositorios.

## Cómo probar un cambio

- *Scripts*: `bash -n scripts/<script>.sh` y, si tienes ShellCheck, `shellcheck scripts/<script>.sh`. Para `commit_trailer.py`: `python3 -m py_compile scripts/commit_trailer.py`.
- `git-init-context.sh`: pruébalo en una carpeta temporal con un `.env` de prueba (`SKILLS_ENV=/ruta/al/.env.de.prueba`), nunca contra tu `.env` real.
- *Skills* y CoT: corre la *skill* sobre un repositorio de prueba y revisa que el agente siga todos los pasos.
- `sync_global.sh`: primero en una máquina o un usuario de prueba, porque escribe en `~/.agents/skills/` y en `~/.claude/commands/`.

## Cómo enviar un cambio

1. Crea una rama desde `main` con un nombre claro: `feat/pr-skill`, `fix/commit-gate-new-changelog`.
2. Haz un cambio pequeño y con un solo propósito.
3. Pruébalo como se indica arriba.
4. Actualiza el [CHANGELOG](./CHANGELOG.md) con `/changelogger`.
5. Haz tus *commits* con `/commit` y abre el PR explicando qué cambia, por qué y cómo lo probaste.

### Mensajes de *commit*

[Commits Convencionales](https://www.conventionalcommits.org/es/v1.0.0/) en **inglés internacional (UK)**, con alcance por capa o por *skill*: `feat(commit): …`, `fix(cot): …`, `docs(rulesets): …`, `feat(scripts): …`. La línea `Co-Authored-By:` la resuelve `/commit` con `scripts/commit_trailer.py` antes de cada *commit*.

### CHANGELOG

En **español mexicano**, con fechas en CST de Ciudad de México (UTC-6): un bloque `## [AAAA-MM-DD] - Título breve` por día y una viñeta con tipo por cambio, sin reescribir entradas anteriores.

### Integración de PR

Con **rebase**, conservando el mensaje, el autor y el `Co-Authored-By` de cada *commit*. En GitHub: *Rebase and merge*; con la terminal: `gh pr merge <n> --rebase`. Nunca *Squash and merge* con un mensaje nuevo.
