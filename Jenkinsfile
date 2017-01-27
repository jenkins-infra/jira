#!groovy

def imageName = 'jenkinsciinfra/jira'

/* Only keep the 10 most recent builds. */
properties([[$class: 'BuildDiscarderProperty',
                strategy: [$class: 'LogRotator', numToKeepStr: '10']]])

node('docker') {
    checkout scm

    /* Using this hack right now to grab the appropriate abbreviated SHA1 of
     * our current build's commit. We must do this because right now I cannot
     * refer to `env.GIT_COMMIT` in Pipeline scripts
     */
    sh 'git rev-parse HEAD > GIT_COMMIT'
    shortCommit = readFile('GIT_COMMIT').take(6)
    def imageTag = "build${shortCommit}"


    stage 'Build'
    def whale = docker.build("${imageName}:${imageTag}", 'jira')

    stage 'Deploy'
    if (infra.isTrusted()) {
        whale.push()
    }
    else {
        echo 'Cannot publish containers from this instance'
    }
}
