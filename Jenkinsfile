pipeline {
  agent any
  environment {
    TF_VERSION = '1.6.0'
    AWS_REGION = 'us-east-1'
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Terraform Init') {
      steps {
        sh 'terraform -chdir=terraform/environments/prod init'
      }
    }
    stage('Terraform Validate') {
      steps {
        sh 'terraform -chdir=terraform/environments/prod validate'
      }
    }
    stage('Checkov Scan') {
      steps {
        sh '''
          if command -v checkov >/dev/null 2>&1; then
            checkov -d terraform/environments/prod --framework terraform --soft-fail
          else
            docker run --rm -v "$PWD:/tf" bridgecrew/checkov:latest \
              -d /tf/terraform/environments/prod --framework terraform --soft-fail
          fi
        '''
      }
    }
    stage('Terraform Plan') {
      steps {
        sh 'terraform -chdir=terraform/environments/prod plan -out=tfplan'
      }
    }
    stage('Terraform Apply') {
      when { branch 'main' }
      steps {
        input 'Approve production deployment?'
        sh 'terraform -chdir=terraform/environments/prod apply -auto-approve tfplan'
      }
    }
  }
  post {
    always { cleanWs() }
  }
}
