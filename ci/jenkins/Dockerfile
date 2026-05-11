# Jenkins LTS con cliente Docker (habla con el motor del host vía /var/run/docker.sock)
# y plugins preinstalados para Pipeline desde Git sin pasar por el asistente largo.
FROM jenkins/jenkins:lts-jdk17

USER jenkins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

COPY --chown=jenkins:jenkins init/00-disable-security.groovy /usr/share/jenkins/ref/init.groovy.d/00-disable-security.groovy
COPY --chown=jenkins:jenkins init/create-pluszone-job.groovy /usr/share/jenkins/ref/init.groovy.d/create-pluszone-job.groovy

# Cliente Docker oficial + plugin Compose v2 (`docker compose`).
# El paquete docker.io de Debian suele NO traer `docker compose` y rompe el stage del Jenkinsfile.
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && . /etc/os-release \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
