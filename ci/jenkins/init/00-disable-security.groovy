// Solo para demo local en Docker: sin login ni asistente inicial.
// No usar en entornos expuestos a Internet.
import jenkins.model.Jenkins

Jenkins j = Jenkins.getInstance()
j.disableSecurity()
j.save()
