# Jenkins LTS con cliente Docker (habla con el motor del host vía /var/run/docker.sock)
# y plugins preinstalados para Pipeline desde Git sin pasar por el asistente largo.
FROM jenkins/jenkins:lts-jdk17

USER jenkins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

COPY --chown=jenkins:jenkins init/00-disable-security.groovy /usr/share/jenkins/ref/init.groovy.d/00-disable-security.groovy
COPY --chown=jenkins:jenkins init/create-pluszone-job.groovy /usr/share/jenkins/ref/init.groovy.d/create-pluszone-job.groovy

USER root
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends docker.io \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
