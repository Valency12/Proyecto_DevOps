import hudson.plugins.git.BranchSpec
import hudson.plugins.git.GitSCM
import hudson.plugins.git.UserRemoteConfig
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import org.jenkinsci.plugins.workflow.job.WorkflowJob

import java.util.Collections

final String jobName = "PlusZone-CI"
final String repoUrl = "https://github.com/Valency12/Proyecto_DevOps.git"

try {
    Jenkins j = Jenkins.getInstance()
    if (j.getItem(jobName) != null) {
        return
    }

    List<UserRemoteConfig> remotes = [
        new UserRemoteConfig(repoUrl, null, null, null)
    ]
    List<BranchSpec> branches = [new BranchSpec("*/main")]
    GitSCM scm = new GitSCM(
        remotes,
        branches,
        false,
        Collections.emptyList(),
        null,
        "",
        Collections.emptyList()
    )

    WorkflowJob job = j.createProject(WorkflowJob.class, jobName)
    job.setDefinition(new CpsScmFlowDefinition("Jenkinsfile", scm))
    job.save()
} catch (Throwable t) {
    println("[PlusZone-CI init] No se pudo crear el job automaticamente: ${t.message}")
    t.printStackTrace()
}
