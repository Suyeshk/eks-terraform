pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'qa', 'prod'],
            description: 'Select environment'
        )
        choice(
            name: 'ACTION',
            choices: ['init', 'plan', 'apply', 'destroy'],
            description: 'Terraform action'
        )
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Check Jenkins AWS Account') {
    steps {
        sh 'aws sts get-caller-identity'
    }
}

        stage('Terraform Init') {
            when {
                expression { params.ACTION == 'init' }
            }
            steps {
                sh '''
                  terraform init \
                  -reconfigure \
                  -backend-config="key=${ENV}/terraform.tfstate"
                '''
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'plan' }
            }
            steps {
                sh '''
                  terraform init
                  terraform plan \
                    -var-file=config/${ENV}.tfvars
                '''
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                  terraform init
                  terraform apply \
                    -var-file=config/${ENV}.tfvars \
                    -auto-approve
                '''
            }
        }

        stage ('Terraform Destroy'){
                        when {
                expression { params.ACTION == 'destroy' }
                        }
            steps{
                sh '''
                            terraform init 
                            terraform destroy
                           -var-file=config/${ENV}.tfvars \
                            -auto-approve
                            '''
            
    }
}
