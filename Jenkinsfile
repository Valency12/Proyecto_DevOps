pipeline {
    agent any

    // Cada ~5 min Jenkins pregunta a GitHub si hay commits nuevos en main.
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
                script {
                    if (isUnix()) {
                        sh '''
                            echo "=== Origen Git (GitHub) ==="
                            git remote -v || true
                            git log -1 --oneline
                        '''
                    } else {
                        bat '''
                            @echo off
                            echo === Origen Git (GitHub) ===
                            git remote -v
                            git log -1 --oneline
                        '''
                    }
                }
            }
        }

        stage('Build (info proyecto)') {
            steps {
                echo 'Construyendo / validando contexto PlusZone...'
                script {
                    if (isUnix()) {
                        sh '''
                            echo "Contenido en raíz del repo:"
                            ls -la
                        '''
                    } else {
                        bat '''
                            @echo off
                            echo Contenido en raiz del repo:
                            dir
                        '''
                    }
                }
            }
        }

        stage('Docker (motor del host)') {
            steps {
                echo 'Comprobando cliente Docker contra el socket del host...'
                script {
                    if (isUnix()) {
                        sh 'docker version'
                    } else {
                        bat 'docker version'
                    }
                }
            }
        }

        stage('Build imágenes (Docker Compose)') {
            steps {
                echo 'Construyendo imágenes del proyecto desde el repo clonado (GitHub)...'
                script {
                    if (isUnix()) {
                        sh '''
                            docker compose version
                            docker compose -f docker-compose.yml build --parallel
                        '''
                    } else {
                        bat '''
                            docker compose version
                            docker compose -f docker-compose.yml build --parallel
                        '''
                    }
                }
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
