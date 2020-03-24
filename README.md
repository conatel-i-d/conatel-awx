# Conatel - AWX

Serie de playbooks para levantar un servidor AWX.

## Requisitos

- Sistema Operativo: `Ubuntu 16.04+`
- Dependencias:
  - `postgresql-10`
  - `libpq-dev`
  - `python-psycopg2`
- Modulos de `pip`:
  - `psycopg2`
  - `boto` 
  - `boto3`
- Ansible: `2.9+`
- Opcionales:
  - `docker`
  - `make`

## Variables de entorno<a id="environment_variables"></a>

Se debe contar con las siguientes variables de entorno para poder configurar algunos servicios del proyecto. Las mismas se pueden cargar directamente sobre la sesión (utilizando el comando `export`), ó, creando un archivo `.env` en la raiz del proyecto. Las variables a configurar son las siguientes:

| Variable | Descripción |
| --- | --- |
| `ANSIBLE_SSH_PRIVATE_KEY_FILE`| Ruta a la llave privada a utilizar para conectarse con el sevidor. Se debe configurar si se desea utilizar la imagen de `docker` adjunta o `make` para correr los `playbooks`. |
| `AWS_ACCESS_KEY_ID` | Llave de acceso de un usuario de AWS con acceso al Bucket `awx-conatel`. |
| `AWS_SECRET_ACCESS_KEY` | Llave de acceso secreta de un usuario de AWS con acceso al Bucket `awx-conatel`. |

En el caso de que se desee utilizar `tower-cli` desde el contenedor, se puede configurar a través de las siguientes variables de entorno:

| Variable | Default | Descripción |
| --- | --- | --- |
| `TOWER_HOST` | `http://127.0.0.1:8052` | Dirección del host de AWX. |
| `TOWER_USERNAME` | `admin` | Usuario administrador del AWX. |
| `TOWER_USERNAME` | `password` | Contraseña del usuario administrador del AWX. |
| `TOWER_VERIFY_SSL` | `false` | Flag para indicar si se debe verificar el certificado del servidor. |

Ejemplo de un archivo `.env`.

```ini
ANSIBLE_SSH_PRIVATE_KEY_FILE=~/.ssh/id_rsa
AWS_ACCESS_KEY_ID=XXX
AWS_SECRET_ACCESS_KEY=XXX
# Optionals
TOWER_HOST=http://192.168.1.1:8052
TOWER_USERNAME=admin
TOWER_PASSWORD=password
TOWER_VERIFY_SSL=false
```

## Instrucciones

Se ofrecen cuatro métodos para interactuar con los `playbooks`:

| Método | Descripción |
| --- | --- |
| [`./run.sh`](#run) | Script que simplifica la ejecución de los `playbooks` del proyecto. El mismo garantiza la existencia de los archivos principales y permite correr múltiples `playbooks` con un único comando. Utiliza la imagen de `docker` incluida y `make` para simplificar la ejecución de los `playbooks`. <br />**OBS 1: Es la forma recomendada de utilizar este proyecto.**<br />**OBS 2: Se le deben dar permisos de ejecución al script `run.sh`.**|
| [`make`](#make) | Todos los `playbooks` incluidos cuentan con una tarea de `make` para facilitar su ejecución desde la consola. Utilizan la imagen de `docker` incluida para su ejecución. El comando `make` es otra forma de correr el script `./run.sh`. |
| [`docker`](#docker) | Se incluye una imagen de docker con todas las dependencias instaladas para ejecutar los `playbooks`. Esto evita tener que instalar las dependencias localmente en la maquina. |
| [`local`](#local) |  Los `playbooks` pueden ser ejecutados localmente en la maquina, siempre y cuando se cuente con todas las dependencias. El sistema solo esta probado con `ubuntu 16.04`. No se garantiza su funcionamiento bajo otros sistemas operativos.<br />**OBS: No se recomienda utilizar este método.** 

## Instrucciones para correr con Ansible localmente<a id="local"></a>

El primer paso es definir el archivo `hosts.yml` que se va a utilizar. Dentro del mismo, se debe configurar un grupo llamad `awx` con todas las configuraciones de acceso necesarias para acceder al servidor. Por ejemplo, si el servidor no contará con una llave privada para su conexión por `ssh` (**no recomendado**) se deberá configurar el usuario y el password que deberá utilizar Ansible para establecer la conexión.

```yml
all:
  children:
    awx:
      hosts:
        192.168.1.1:
          ansible_user: conatel
          ansible_password: conatel
```

En el caso de que si se utilice una llave SSH se debe configurar las variables `ansible_ssh_private_key_file` y `ansible_ssh_user`.

Luego, configurar un archivo llamado `vars.yml` donde se deben configurar como mínimo las siguientes variables:

| Variable | Tipo | Descripción |
| --- | --- | --- |
| `service` | `Boolean` | Indica si PostgreSQL y AWX debe correrse como servicio. |
| `awx_version` | `string` | Versión de AWX. Probado con `8.0.0` |
| `awx_database` | `string` | Nombre de la base de datos. `awx` por defecto. |
| `awx_database_username` | `string` | Usuario con permisos para acceder a la base de datos de AWX. `aws` por defecto. |
| `postgres_version` | `string` | Debe configurarse con el valor `10`. |
| `postgres_expose_port` | `boolean` | Configurarlo como `True` si se desea exponer el puerto de la base de datos. |
| `postgres_admin_username` | `string` | Usuario de administrador de la base de datos. |
| `postgres_admin_password` | `string` | Contraseña de administrador de la base de datos. |
| `project_dir` | `string` | Ubicación donde se instalarán los archivos del proyecto en el servidor. |
| `external_network` | `string` | Nombre de la red de Docker donde se conectarán la base de datos y los contenedores del AWX. |
| `secret_key` | `string` | Clave secreta para encriptar credenciales en AWX. |
| `sql_scripts` | `list[string]` | Lista de scripts SQL a ejecutar al momento de crear la base de datos. Como mínimo, debe incluir el script ubicado en `scripts/awx_db.sql`. |

Ejemplo de un archivo `vars.yml`.

```yml
awx_web_host: awxweb
awx_task_host: awx
postgres_version: '10'
postgres_expose_port: True
postgres_admin_username: postgres
postgres_admin_password: postgrespass
awx_version: '8.0.0'
project_dir: /home/root/awx_compose
state: present
external_network: awx_vpn
secret_key: conatel
sql_scripts:
  - ./scripts/awx_db.sql
```

**OBS: se incluye un `playbook` llamado `init.yml` que inicializa los archivos `vars.yml` y `hosts.yml`. Se recomienda su utilización.**

La lista de `playbooks` disponibles es la siguiente:

| Archivo | Descripción |
| --- | --- |
| `backup.yml` | Obtiene un respaldo de la base de datos y lo almacena en S3. |
| `destroy.yml` | Destruye el ambiente levantado en el servidor.<br/>**OBS: Es destructivo.** |
| `init.yml` | Inicializa el archivo de `hosts.yml` y `vars.yml` |
| `list-backups.yml` | Devuelve una lista de los respaldos de las bases de datos existentes. |
| `ping.yml` | Verifica la conectividad con el servidor. |
| `restore.yml` | Reestablece una versión anterior de la base de datos, almacenado en S3. |
| `up.yml` | Instala el servidor con todas sus dependencias y arranca todos los contenedores. |

## Instrucciones para correr sobre Docker<a id="docker"></a>

Dentro del proyecto, se incluye un `Dockerfile` capaz de construir una imagen con todas las dependencias necesarias para ejecutar el proyecto.

Antes de poder utilizar la imagen, es necesario construir la imagen:

```bash
docker build -t conatel_digital_hub/awx_vpn .
````

Luego podemos ejecutar los playbooks de la siguiente manera por ejemplo:

```bash
docker run \
		--rm \
		-it \
		-e ANSIBLE_CONFIG=/ansible/ansible.cfg \
		--env-file .env \
		-v `pwd`:/ansible \
		-v $(ANSIBLE_SSH_PRIVATE_KEY_FILE):/root/.ssh/ansible_ssh_private_key \
		conatel_digital_hub/awx_vpn \
		ansible-playbook <nombre_del_playbook>
```

Este comando de docker:

1. Se elimina automaticamente al finalizar su ejecución.
2. Configura el archivo `./ansible.cfg` como el archivo de configuración de Ansible dentro del contenedor.
3. Carga las variables de entorno definidas en el archivo `.env`.
4. Monta la carpeta del proyecto en la ubicación `/ansible`.
5. Configura la llave privada de SSH utilizada para conectarse al contenedor. La misma debe haberse previamente configurado en la variable de entorno `ANSIBLE_SSH_PRIVATE_KEY_FILE`.
6. Corre el `playbook` encontrado en la raíz del proyecto.

## Instrucciones para correr con `make`<a id="make"></a>

Todos los `playbooks` pueden ser ejecutados a través de `make`. Estas tareas utilizan `docker` por detras para ejecutar los `playbooks` por lo que es necesario realizar una leve configuración, previo a correr las tareas.

El contenedor monta de forma automatica el proyecto en la carpeta `/ansible`. Sin embargo, no tiene forma de conocer la llave privada utilizada para la conexión por SSH. Por lo tanto, debemos montarla al momento de correr el contenedor.

Las tareas del `Makefile` ya preveen esta eventualidad. Solamente hay que configurar un archivo `.env` indicando en una variable de entorno, donde se encuentra la llava privada a montar en el contenedor.

```ini
ANSIBLE_SSH_PRIVATE_KEY_FILE = ~/.ssh/id_rsa
```
**OBS: Este procedimiento no es necesario si el servidor no requiere de una llave privada para iniciar su conexión.**

Y luego configurar el archivo `hosts.yml` de la siguiente manera:

```yaml
all:
  children:
    awx:
      hosts:
        <ip_del_servidor>:
          ansible_ssh_private_key_file: /root/.ssh/ansible_ssh_private_key
          ansible_ssh_user: conatel
```

**OBS: La IP del servidor y el usuario de `ssh` debe ingresarse de acuerdo a los parámetros del server.**

Las tareas definidas son las siguientes:

| Tarea | Descripción | Ejemplo |
| --- | --- | --- |
| `attach` | Permite acceder a la consola del contenedor. | `make attach` |
| `backup` | Crea un backup de la base de datos y la almacena en S3 | `make backup` |
| `build` | Crea la imagen del contenedor. | `make build` |
| `default` | Corre un script para simplificar la ejecución de los `playbooks` | `make` |
| `destroy` | Destruye el ambiente creado en el servidor.<br/>** OBS: Es destructivo.** | `make destroy` |
| `init` | Inicializa los archivos `vars.yml` y `hosts.yml` | `make init` |
| `install-roles` | Instala los roles necesarios del proyecto. | `make install-roles` |
| `list-roles` | Imprime la lista de los roles instalados. | `make list-roles` |
| `ping` | Verifica la conectividad con el servidor. | `make ping` |
| `playbook` | Permite correr un playbook desde el contenedor. Es necesario configurar la variable `file` con el nombre del contenedor para que funcione. | `make playbook file=ping.yml` |
| `restore` | Reestablece un respaldo anterior de la base de datos en el sistema | `make restore` |
| `tower-cli` | Permite ejecutar comandos a través de `tower-cli`. **Debe prefijar las opciones con `--`.** |
| `up` | Levanta el servidor de AWX. | `make up` |

## Instrucciones para correr con `./run.sh`<a id="run"></a>

Este script simplifica la ejecución de los `playbooks` al presentar un menu sobre la `cli`, donde se pueden llamar a cada uno de ellos. Además, garantiza la existencia de los archivos `host.yml` y `vars.yml`, fundamentales para la correcta ejecución de los `playbooks`. También permite llamar directamente de la consola a los editores de texto preferidos por el usuario para la configuración de dichos archivos.

Para su ejecución, es necesario darle permisos de escritura al mismo:

```bash
chmod +x ./run.sh
```

Luego se puede ejecutar llamandolo directamente:

```bash
./run.sh
```

Despues de realizar algunas pruebas iniciales, nos presentará el siguiente menú:

```txt
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌎 AWX Conatel: ¿Que quieres hacer?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌵 Seleccione alguna de las siguientes opciones:

[1] Editar archivo de inventario
[2] Editar archivo de variables
[3] Levantar el servidor de AWX
[4] Respaldar el servidor de AWX
[5] Visualizar la lista de reespaldos existentes
[6] Restaurar una versión anterior del servidor

[P] Probar conectividad con el servidor
[Q] Salir

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶️  Eliga una opción | Presione [ENTER]: 
```

A partir de ahí, puede seguir las indicaciones para correr cada una de las tareas.

## Como utilizar `tower-cli` desde el contenedor

Dentro del contenedor del proyecto viene instalado `tower-cli`. Esta herramienta permite interactuar con los servidores de AWX desde la línea de comandos. Para su configuración, es necesario configurar las variables de entorno opcionales definidas en la sección [Variables de entorno](#environment_variables).

Se incluye una tarea de `make` para simplificar su uso a través de `docker`:

```bash
make tower-cli -- --version
```

**OBS: Identificar el uso de `--` (doble guion) antes de pasar opciones a `tower-cli`. Esto es para indicarle a `make` que no debe pasar esas opciones.**