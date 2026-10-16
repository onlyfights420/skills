# Configuración inicial de Git para nuevos repositorios

Este documento describe la configuración necesaria al clonar o inicializar un repositorio: la identidad de quien trabaja en él y la llave SSH con la que se conecta.

## 1. Tu identidad vive en `~/skills/.env`

Cada persona tiene su propia identidad y su propia llave SSH. No se escriben en ningún archivo versionado: viven en `~/skills/.env`, que no se sube al repositorio (plantilla en `.env.example`).

```bash
cp ~/skills/.env.example ~/skills/.env
chmod 600 ~/skills/.env
```

Y llena tus datos:

| Variable | Qué es | Ejemplo |
|---|---|---|
| `GIT_NAME` | Tu nombre, como aparece en tu cuenta de GitHub | `Ana López` |
| `GIT_EMAIL` | El correo de tu cuenta de GitHub | `ana@example.com` |
| `GIT_SSH_KEY` | El nombre de tu llave en `~/.ssh/` (o su ruta completa) | `ana_github` |
| `GIT_ORG` | El dueño predeterminado de los repositorios nuevos | `onlyfights420` |

Nunca uses la identidad ni la llave de otra persona, ni la llave de administración del proyecto.

## 2. Configuración inicial y SSH

Para que en el uso diario baste con un simple `git push` sin alias SSH y sin HTTPS, configura el repositorio al crearlo o clonarlo con el *script* incluido.

### 2.1. Uso del *script*

```bash
# Desde la raíz del repositorio (o desde la carpeta vacía que vas a inicializar)
bash ~/skills/scripts/git-init-context.sh [llave] [url_remota] [rama]

# Ejemplo, con la llave de GIT_SSH_KEY
bash ~/skills/scripts/git-init-context.sh "" git@github.com:onlyfights420/REPO.git main
```

En el repositorio actual:

- Ejecuta `git init` si la carpeta todavía no es un repositorio.
- Configura `user.name` y `user.email` con `GIT_NAME` y `GIT_EMAIL`.
- Configura `core.sshCommand` con la llave indicada (predeterminada: `GIT_SSH_KEY`).
- Define la rama predeterminada (`main` si no indicas otra).
- Configura `origin` si pasas una URL SSH (`git@…` o `ssh://…`); rechaza las URL HTTPS.

Lee del `.env` solo esas variables y nunca imprime el archivo. Al finalizar, podrás usar `git push` directamente.

### 2.2. Pasos manuales (si no usas el *script*)

```bash
git config user.name  "<GIT_NAME>"
git config user.email "<GIT_EMAIL>"
git config core.sshCommand "ssh -i ~/.ssh/<GIT_SSH_KEY> -o IdentitiesOnly=yes"

git remote add origin git@github.com:<GIT_ORG>/REPO.git

# Rama predeterminada: sin commits todavía usa symbolic-ref; con commits, branch -M
git symbolic-ref HEAD refs/heads/main
```

### 2.3. Probar conexión SSH

```bash
ssh -i ~/.ssh/<GIT_SSH_KEY> -o IdentitiesOnly=yes -T git@github.com || true
```

GitHub debe contestar con tu usuario: `Hi <usuario>! You've successfully authenticated`.

## 3. Clonar o inicializar repositorios

### Clonar repositorio existente (SSH siempre)

```bash
git clone git@github.com:onlyfights420/REPO.git
cd REPO
bash ~/skills/scripts/git-init-context.sh
```

### Inicializar nuevo repositorio

```bash
# Crear la carpeta y configurarla (el script ejecuta git init)
mkdir REPO && cd REPO
bash ~/skills/scripts/git-init-context.sh "" git@github.com:onlyfights420/REPO.git main

# Verificar la configuración remota
git remote -v
```

## 4. Primer *commit* y *push*

El primer *commit* sigue el flujo normal de [COMMITTING.md](./COMMITTING.md): crea `CHANGELOG.md` con `/changelogger` y después ejecuta `/commit`, que hace el *commit* desde `/tmp/commit-msg.txt`.

```bash
# Primer push con upstream
git push -u origin main
```

---

**Próximo paso:** una vez configurado el repositorio, consulta **[COMMITTING.md](./COMMITTING.md)** para el flujo de trabajo diario de *commits* y *push*.

---

*Elaborado por Rodrigo Álvarez (@incognia)*
