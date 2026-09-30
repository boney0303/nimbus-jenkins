@Library('saas') _

env.ChefOrg ='skyline'

node(label: 'test-kitchen') {
  stage('Setup') {
    deleteDir()
    checkout scm
    pipelineSetup(env.ChefOrg)
  }
}

cookbookPipeline {
  cookbook = 'nimbus-jenkins'
}
