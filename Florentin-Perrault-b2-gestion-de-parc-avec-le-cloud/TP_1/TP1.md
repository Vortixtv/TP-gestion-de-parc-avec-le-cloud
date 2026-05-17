# Part I : Docker basics

### 1. Install

```
vortix@fedora:~/Public$ docker --version
Docker version 29.3.0, build 1.fc43
vortix@fedora:~/Public$ 
```
```
vortix@fedora:~/Public$ sudo usermod -aG docker vortix
```
### 2. Vérifier l'install

### 3. Lancement de conteneurs

🌞 Utiliser la commande docker run

```
vortix@fedora:~$ docker run --name web -d -v /path/to/html:/usr/share/nginx/html -p 9999:80 nginx
0a6291d80e84391501c38034cf5ad26340cd08f9467e0831b6627be5f0616bf9
vortix@fedora:~$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                     NAMES
0a6291d80e84   nginx     "/docker-entrypoint.…"   4 seconds ago    Up 3 seconds    0.0.0.0:9999->80/tcp, [::]:9999->80/tcp   web
8a0e0c9633eb   debian    "sleep 99999"            24 minutes ago   Up 24 minutes                                             elegant_saha
vortix@fedora:~$ 
```
🌞 Rendre le service dispo sur internet

```
vortix@fedora:~$ sudo firewall-cmd --add-port=9999/tcp --permanent
[sudo] password for vortix: 
Warning: ALREADY_ENABLED: 9999:tcp
success
vortix@fedora:~$ sudo firewall-cmd --reload
success
vortix@fedora:~$ docker run --name web -d -v $HOME/monsiteweb:/usr/share/nginx/html:ro,z -p 9999:80 nginx
e6d7f16e9fecbbbe8e36e7a84563470c27375e4fb174e455824b98a3b05718c0
vortix@fedora:~$ curl http://localhost:9999
<h1>Salut, mon Nginx fonctionne !</h1>
vortix@fedora:~$ 
```
🌞 Custom un peu le lancement du conteneur

```
vortix@fedora:~$ docker run -v ^C 7777:80 nginx
vortix@fedora:~$ mkdir -p ~/mon_site
vortix@fedora:~$ nano ~/mon_site/index.html
vortix@fedora:~$ nano ~/mon_site/index.html
vortix@fedora:~$ mkdir -p ~/ma_config
vortix@fedora:~$ nano ~/ma_config/meow.conf
vortix@fedora:~$ cat ~/mon_site/index.html
<h1>Mon site sur le port 7777</h1>
vortix@fedora:~$ cat ~/ma_config/meow.conf
server {
  # on définit le port où NGINX écoute dans le conteneur
  listen 7777;
  
  # on définit le chemin vers la racine web
  # dans ce dossier doit se trouver un fichier index.html
  root /var/www/tp_docker; 
}
vortix@fedora:~$ docker rm -f meow
Error response from daemon: No such container: meow
vortix@fedora:~$ ^C
vortix@fedora:~$ docker run --name meow -d --memory 512m -p 7777:7777 -v /home/vortix/mon_site:/var/www/tp_docker:z -v /home/vortix/ma_config/meow.conf:/etc/nginx/conf.d/default.conf:z nginx
d48a2ac92efbd7ed8937f29a30d9395f367c9cafba198e51fed5d6213c27d7e2
vortix@fedora:~$ docker run --name meow -d --memory 512m -p 7777:7777 -v /home/vortix/mon_site:/var/www/tp_docker:z -v /home/vortix/ma_config/meow.conf:/etc/nginx/conf.d/default.conf:z nginx
docker: Error response from daemon: Conflict. The container name "/meow" is already in use by container "d48a2ac92efbd7ed8937f29a30d9395f367c9cafba198e51fed5d6213c27d7e2". You have to remove (or rename) that container to be able to reuse that name.

Run 'docker run --help' for more information
vortix@fedora:~$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS              PORTS                                                 NAMES
d48a2ac92efb   nginx     "/docker-entrypoint.…"   About a minute ago   Up About a minute   80/tcp, 0.0.0.0:7777->7777/tcp, [::]:7777->7777/tcp   meow
c08babe4a2ac   nginx     "/docker-entrypoint.…"   About an hour ago    Up About an hour    80/tcp                                                zealous_bassi
e6d7f16e9fec   nginx     "/docker-entrypoint.…"   2 hours ago          Up 2 hours          0.0.0.0:9999->80/tcp, [::]:9999->80/tcp               web
8a0e0c9633eb   debian    "sleep 99999"            3 hours ago          Up 3 hours                                                                elegant_saha
vortix@fedora:~$ curl http://localhost:7777
<h1>Mon site sur le port 7777</h1>
vortix@fedora:~$ 
```

# Part II : Images

Construisez votre propre Dockerfile

🌞 Construire votre propre image

mon Dockerfile :

```
# on définit un port sur lequel écouter
Listen 80

# on charge certains modules Apache strictement nécessaires à son bon fonctionnement
LoadModule mpm_event_module "/usr/lib/apache2/modules/mod_mpm_event.so"
LoadModule dir_module "/usr/lib/apache2/modules/mod_dir.so"
LoadModule authz_core_module "/usr/lib/apache2/modules/mod_authz_core.so"

# on indique le nom du fichier HTML à charger par défaut
DirectoryIndex index.html
# on indique le chemin où se trouve notre site
DocumentRoot "/var/www/html/"

# quelques paramètres pour les logs
ErrorLog "/var/log/apache2/error.log"
LogLevel warn
```
proof :

```
vortix@fedora:~/mon_image_apache$ docker build . -t mon_apache
[+] Building 0.4s (10/10) FINISHED                                         docker:default
 => [internal] load build definition from Dockerfile                                 0.0s
 => => transferring dockerfile: 269B                                                 0.0s
 => [internal] load metadata for docker.io/library/debian:latest                     0.0s
 => [internal] load .dockerignore                                                    0.0s
 => => transferring context: 2B                                                      0.0s
 => [internal] load build context                                                    0.0s
 => => transferring context: 788B                                                    0.0s
 => [1/5] FROM docker.io/library/debian:latest@sha256:55a15a112b42be10bfc8092fcc40b  0.0s
 => => resolve docker.io/library/debian:latest@sha256:55a15a112b42be10bfc8092fcc40b  0.0s
 => CACHED [2/5] RUN apt update -y                                                   0.0s
 => CACHED [3/5] RUN apt install -y apache2                                          0.0s
 => [4/5] COPY apache2.conf /etc/apache2/apache2.conf                                0.1s
 => [5/5] COPY index.html /var/www/html/                                             0.0s
 => exporting to image                                                               0.2s
 => => exporting layers                                                              0.1s
 => => exporting manifest sha256:0015aa90c59b61e3a4569d1af7bc6a083d5314198619c0d975  0.0s
 => => exporting config sha256:6c8c409e4042d0574bbaf7d3337d90b975f0fd044561e7aa0c58  0.0s
 => => exporting attestation manifest sha256:68a3b458c9e6f93cae7a7e29878232440bfe59  0.0s
 => => exporting manifest list sha256:05a67f2ec45f3c0b8cab403866efde18c788133e8cf35  0.0s
 => => naming to docker.io/library/mon_apache:latest                                 0.0s
 => => unpacking to docker.io/library/mon_apache:latest                              0.0s
vortix@fedora:~/mon_image_apache$ docker run -d -p 8888:80 mon_apache
236188cc98227651f27881bb2a3e7c15c4ac5b800eb00e350716e2134ae92342
vortix@fedora:~/mon_image_apache$ curl http://localhost:8888
<h1>serveur Apache personnalisé par Dockerfile !</h1>
```
# Part III : docker-compose


### 2. WikiJS
🌞 Installez un WikiJS en utilisant Docker
```
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: wiki
      POSTGRES_PASSWORD: wikijsrocks
      POSTGRES_USER: wikijs
    restart: unless-stopped
    volumes:
      - db-data:/var/lib/postgresql/data

  wiki:
    image: ghcr.io/requarks/wiki:2
    depends_on:
      - db
    environment:
      DB_TYPE: postgres
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: wikijs
      DB_PASS: wikijsrocks
      DB_NAME: wiki
    restart: unless-stopped
    ports:
      - "8886:3000"

volumes:
  db-data:
  ```
  ```
  sudo docker compose up -d
  ```
  ```
  sudo docker compose ps
  ```

### 3. Make your own meow

🌞 Vous devez :

construire une image qui

contient python3

contient l'application et ses dépendances
lance l'application au démarrage du conteneur


écrire un docker-compose.yml qui définit le lancement de deux conteneurs :

l'app python
le Redis dont il a besoin

Mon DockerFile :

```
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python3", "app.py"]
```

mon docker-compose.yml :

```
services:
  db:
    image: redis:latest
    restart: unless-stopped

  app:
    build: .
    depends_on:
      - db
    ports:
      - "8888:8888"
    restart: unless-stopped
```

# Part IV : Docker security

1. Le groupe docker

🌞 Prouvez que vous pouvez devenir root

```
vortix@fedora:~/mon_image$ docker run -it --rm -v /:/disque_host alpine cat /disque_host/etc/shadow
root:!:::::::
bin:!*:20294::::::
daemon:!*:20294::::::
adm:!*:20294::::::
lp:!*:20294::::::
sync:!*:20294::::::
shutdown:!*:20294::::::
halt:!*:20294::::::
mail:!*:20294::::::
operator:!*:20294::::::
games:!*:20294::::::
ftp:!*:20294::::::
nobody:!*:20294::::::
dbus:!*:20384::::::
tss:!*:20384::::::
systemd-oom:!*:20384::::::
polkitd:!*:20384::::::
systemd-coredump:!*:20384::::::
systemd-timesync:!*:20384::::::
chrony:!*:20384::::::
systemd-network:!*:20384::::::
systemd-resolve:!*:20384::::::
avahi:!*:20384::::::
unbound:!*:20384::::::
clevis:!*:20384::::::
usbmuxd:!*:20384::::::
gluster:!*:20384::::::
qemu:!*:20384::::::
apache:!*:20384::::::
openvpn:!*:20384::::::
nm-openvpn:!*:20384::::::
abrt:!*:20384::::::
wsdd:!*:20384::::::
nm-openconnect:!*:20384::::::
rtkit:!*:20384::::::
pipewire:!*:20384::::::
flatpak:!*:20384::::::
geoclue:!*:20384::::::
sssd:!*:20384::::::
colord:!*:20384::::::
gdm:!*:20384::::::
rpc:!*:20384::::::
dnsmasq:!*:20384::::::
rpcuser:!*:20384::::::
gnome-remote-desktop:!*:20384::::::
vboxadd:!*:20384::::::
sshd:!*:20384::::::
passim:!*:20384::::::
tcpdump:!*:20384::::::
vortix:
akmods:!*:20508::::::
test:
lightdm:!*:20517::::::
vortix@fedora:~/mon_image$ 
```
2. Scan de vuln


🌞 Utilisez Trivy

les commandes qui m'ont permis de faire mes 4 scans :
```
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ghcr.io/requarks/wiki:2
```
```
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image postgres:15-alpine
```
```
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image mon_image_apache
```
```
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image nginx 
```

🌞 Utilisez l'outil Docker Bench for Security
```
vortix@fedora:~$ git clone https://github.com/docker/docker-bench-security.git
fatal: destination path 'docker-bench-security' already exists and is not an empty directory.
vortix@fedora:~$ cd docker-bench-security
vortix@fedora:~/docker-bench-security$ sudo sh docker-bench-security.sh
[sudo] password for vortix: 
# --------------------------------------------------------------------------------------------
# Docker Bench for Security v1.6.0
#
# Docker, Inc. (c) 2015-2026
#
# Checks for dozens of common best-practices around deploying Docker containers in production.
# Based on the CIS Docker Benchmark 1.6.0.
# --------------------------------------------------------------------------------------------

Initializing 2026-03-23T12:27:54+01:00
```


