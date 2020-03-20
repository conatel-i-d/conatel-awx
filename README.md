# Conatel - AWX

Serie de playbooks para levantar un servidor AWX.

## Instrucciones

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

## Instrucciones para correr sobre Docker

Dentro del proyecto, se incluye un `Dockerfile` capaz de construir una imagen con todas las dependencias necesarias para ejecutar el proyecto. Para simplificar su uso, se incluye un archivo de `Makefile` con los comandos ya preparados.

### Configuración de Makefile para utilizar SSH

**OBS: Este procedimiento no es necesario si el servidor no requiere de una llave privada para iniciar su conexión.**

El contenedor monta de forma automatica el proyecto en la carpeta `/ansible`. Sin embargo, no tiene forma de conocer la llave privada utilizada para la conexión por SSH. Por lo tanto, debemos montarla al momento de correr el contenedor.

Las tareas del `Makefile` ya preveen esta eventualidad. Solamente hay que configurar un archivo `.env` indicando en una variable de entorno, donde se encuentra la llava privada a montar en el contenedor.

```ini
ANSIBLE_SSH_PRIVATE_KEY_FILE = ~/.ssh/id_rsa
```

Y luego configurar el archivo `hosts.yml` de la siguiente manera:

```yaml
all:
  children:
    awx:
      hosts:
        192.168.1.1:
          ansible_ssh_private_key_file: /root/.ssh/ansible_ssh_private_key
          ansible_ssh_user: conatel
```

**OBS: La IP del servidor y el usuario de `ssh` debe ingresarse de acuerdo a los parámetros del server.**

Las tareas definidas son las siguientes:

| --- | --- | --- |
| Tarea | Descripción | Ejemplo |
| --- | --- | --- |
| `ping` | Verifica la conectividad con el servidor. | `make ping` |
| `build` | Crea la imagen del contenedor. | `make build` |
| `run` | Permite acceder a la consola del contenedor. | `make run` |
| `playbook` | Permite correr un playbook desde el contenedor. Es necesario configurar la variable `file` con el nombre del contenedor para que funcione. | `make playbook file=ping.yml` |
