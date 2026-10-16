---
domain: workflow
task: inicializar repo con Git y SSH (sin HTTPS) siguiendo GIT.md
dificultad: baja
longitud_objetivo: corta
validacion: repo inicializado, identidad correcta, SSH forzado, remoto en SSH y primer push exitoso
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Evitar HTTPS y alias SSH; usar SSH con la llave adecuada por repositorio (`core.sshCommand`).
- Configurar la identidad (`user.name`, `user.email`) de la persona que trabaja en el repositorio. Sale de su `~/skills/.env` personal (no versionado; plantilla en `.env.example`): `GIT_NAME`, `GIT_EMAIL`, `GIT_SSH_KEY` y `GIT_ORG`.
- Dejar la rama predeterminada como `main` (o la indicada) y el remoto `origin` en formato SSH.
- El *script* `~/skills/scripts/git-init-context.sh` hace todo esto: `[llave] [url_remota] [rama]`, todos opcionales.
- Referencia principal: «~/skills/rulesets/GIT.md» (sección «Configuración inicial y SSH»).

Pasos (opción recomendada: *script* no interactivo):

0) Acción: confirmar que existe `~/skills/.env` con `GIT_NAME`, `GIT_EMAIL` y `GIT_SSH_KEY`.
   Comando: `grep -E '^GIT_(NAME|EMAIL|SSH_KEY|ORG)=' ~/skills/.env` (solo esas llaves; nunca imprimir el archivo completo).
   Resultado: si falta, copiar `~/skills/.env.example` a `~/skills/.env`, con modo 600, y pedirle a la persona sus datos. Nunca inventarlos.
1) Acción: ubicarse en la raíz del repositorio, o en la carpeta vacía que se va a inicializar.
   Resultado: el *script* ejecuta `git init` si la carpeta todavía no es un repositorio, y se niega a correr desde una subcarpeta.
2) Acción: ejecutar el *script*.
   Resultado:
   - Con la llave de `GIT_SSH_KEY`: `bash ~/skills/scripts/git-init-context.sh "" git@github.com:onlyfights420/REPO.git main`
   - Con otra llave: `bash ~/skills/scripts/git-init-context.sh <llave> git@github.com:onlyfights420/REPO.git main`
   - Rama predeterminada: `main`; la URL remota es opcional y debe ser SSH (`git@…` o `ssh://…`).
3) Acción: revisar el bloque `=== CONFIGURATION ===` que imprime el *script*.
   Resultado: identidad, `core.sshCommand`, remoto y rama correctos. Si avisa que la llave no existe, revisar `ls ~/.ssh/` y repetir con la llave correcta.
4) Acción: primer *commit* no interactivo, siguiendo el flujo normal.
   Resultado: crear `CHANGELOG.md` con `/changelogger` y después aplicar `/commit` (o «~/skills/cot/committing.md»), que construye `/tmp/commit-msg.txt` y hace `git commit -F /tmp/commit-msg.txt`.
5) Acción: primer *push* con *upstream*.
   Resultado: `git push -u origin main` (o la rama elegida).

Pasos (alternativa manual, si no usas el *script*):

1) `git init`
2) Configurar identidad y SSH con los valores de `~/skills/.env`:
   - `git config user.name  "<GIT_NAME>"`
   - `git config user.email "<GIT_EMAIL>"`
   - `git config core.sshCommand "ssh -i ~/.ssh/<GIT_SSH_KEY> -o IdentitiesOnly=yes"`
3) Configurar el remoto en SSH y verificar con `git remote -v`: `git remote add origin git@github.com:<GIT_ORG>/REPO.git`
4) Definir la rama predeterminada: `git symbolic-ref HEAD refs/heads/main` si aún no hay *commits*, o `git branch -M main` si ya los hay.
5) *Commit* y primer *push* como en los pasos 4 y 5 de la opción recomendada.

Conclusión:

- Tras la configuración inicial, el flujo diario usa *push* simple: `git push`.
- Cada persona usa su propia identidad y su propia llave; nunca la de otra persona ni la de administración.
- Referencias: «~/skills/rulesets/GIT.md» ([../rulesets/GIT.md](../rulesets/GIT.md)) y «~/skills/rulesets/COMMITTING.md» ([../rulesets/COMMITTING.md](../rulesets/COMMITTING.md)).
