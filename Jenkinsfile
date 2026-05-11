pipeline {
    agent any

    // Cada ~5 min Jenkins pregunta a GitHub si hay commits nuevos en main.
    // Para la presentación también vale "Build Now" justo después del push.
    triggers {
        pollSCM('H/5 * * * *')
    }

    options {
        timestamps()
    }

    stages {
        stage('Checkout (GitHub)') {
            steps {
                checkout scm
                sh '''
                    echo "=== Origen Git (GitHub) ==="
                    git remote -v || true
                    git log -1 --oneline
                '''
            }
        }

        stage('Build (info proyecto)') {
            steps {
                echo 'Construyendo / validando contexto PlusZone...'
                sh '''
                    echo "Contenido en raíz del repo:"
                    ls -la
                '''
            }
        }

        stage('Docker (motor del host)') {
            steps {
                echo 'Comprobando cliente Docker contra el socket del host...'
                sh 'docker version'
            }
        }

        stage('Build imágenes (Docker Compose)') {
            steps {
                echo 'Construyendo imágenes del proyecto desde el repo clonado (GitHub)...'
                sh 'docker compose -f docker-compose.yml build --parallel'
            }
        }

        stage('Test') {
            steps {
                echo 'Aquí irían pruebas automatizadas (pytest, npm test, etc.)'
            }
        }

        stage('Aprobación manual (OK en Jenkins)') {
            steps {
                script {
                    input(
                        message: 'Revisa la consola del build. ¿Apruebas continuar al paso de despliegue demo?',
                        ok: 'Aprobar'
                    )
                }
            }
        }

        stage('Deploy (demo)') {
            steps {
                echo 'Demo: paso tras aprobación — aquí iría despliegue real (compose, K8s, etc.)'
            }
        }
    }
}
