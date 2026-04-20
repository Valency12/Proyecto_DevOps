pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Descarga el código del repositorio
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Construyendo la aplicación PlusZone...'
                // Aquí podrías poner comandos como:
                // sh 'docker build -t pluszone-app .'
            }
        }

        stage('Test') {
            steps {
                echo 'Ejecutando pruebas...'
                // sh 'python -m pytest' (por ejemplo)
            }
        }

        stage('Deploy') {
            steps {
                echo 'Desplegando PlusZone...'
                // Aquí irían tus comandos de despliegue
            }
        }
    }
}