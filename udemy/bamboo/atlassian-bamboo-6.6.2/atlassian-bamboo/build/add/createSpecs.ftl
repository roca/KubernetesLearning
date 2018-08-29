[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.build.admin.create.CreateSpecs" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.build.admin.create.CreateSpecs" --]
[#import "/build/common/repositoryCommon.ftl" as rc]
[#import "/fragments/project/selectBuildDeploymentProject.ftl" as projectPicker]

<html>
<head>
    [@ui.header pageKey='rss.specs.onboarding.creation.title' title=true /]
    <meta name="decorator" content="focusTask">
</head>
<body>
    <div class="toolbar aui-toolbar inline">[@help.url pageKey='bamboo.specs.help'][@ww.text name='bamboo.specs.help.title'/][/@help.url]</div>
    <div id="createSpecsWizard">
        [@ui.header pageKey="rss.specs.onboarding.creation.title" headerElement="h2"/]
        <div id="createSpecsWizardHeader" class="description">
            <p>[@s.text name="rss.specs.onboarding.creation.description"/]</p>
        </div>

        [#if actionErrors?has_content]
            [#list actionErrors as error]
                [@ui.messageBox type="error"]${error}[/@ui.messageBox]
            [/#list]
        [#else]
            [#assign canChooseAnyBuildProject = action.canChooseAnyBuildProject()/]
            [#assign canChooseAnyDeploymentProject = action.canChooseAnyDeploymentProject()/]
            [#assign hasCreateRepoPermission=fn.hasGlobalPermission("CREATEREPOSITORY")/]
            [#assign linkedRepositories = vcsUIConfigBean.getLinkedRepositoriesForSpecsCreate() /]

            [#if !(canChooseAnyBuildProject || canChooseAnyDeploymentProject) || !(hasCreateRepoPermission || linkedRepositories?has_content)]
                [@ui.messageBox type="warning"]
                    [#if !(canChooseAnyBuildProject || canChooseAnyDeploymentProject)]
                        [@s.text name="rss.specs.onboarding.creation.error.no.project.available.both"/][#nt]
                    [/#if ]
                    [#if !(hasCreateRepoPermission || linkedRepositories?has_content)]
                        [@s.text name="rss.specs.onboarding.creation.error.no.repos.available"/][#nt]
                    [/#if ]
                [/@ui.messageBox]
                [@ui.displayButtonContainer secondary=true]
                    <a class="cancel-link" href="[@s.url action="start"/]">
                        [@s.text name="global.buttons.cancel"/]
                    </a>
                [/@ui.displayButtonContainer]
            [#else ]
                [@s.form
                    action="createSpecs"
                    namespace="/build/admin/create"
                    method="post" enctype="multipart/form-data"
                    cancelUri="start.action" submitLabelKey="global.buttons.create"
                ]
                    [@ui.bambooSection titleKey="rss.specs.onboarding.creation.project.title"]
                        <div class="description full-size">
                            <p>[@s.text name="rss.specs.onboarding.creation.project.description"/]</p>
                        </div>
                        [@projectPicker.anyProjectSelector
                            canChooseAnyBuildProject=canChooseAnyBuildProject
                            canChooseAnyDeploymentProject=canChooseAnyDeploymentProject
                            selectProjectKey=selectProjectKey!
                            selectProjectName=selectProjectName!
                            selectDeploymentKey=selectDeploymentKey!
                            selectDeploymentName=selectDeploymentName!
                        /]
                    [/@ui.bambooSection]

                    [@ui.bambooSection id="source-repository" titleKey="rss.specs.onboarding.creation.repository.title"]
                        <div class="description full-size">
                            <p>[@s.text name="rss.specs.onboarding.creation.repository.description"/]</p>
                        </div>
                        [#assign repositoryTypeOption = "LINKED" /]
                        [@rc.repositorySelector
                            vcsTypeSelectors=action.getVcsTypeSelectors()
                            linkedRepositories=linkedRepositories
                            repositoryTypeOption=repositoryTypeOption
                            selectedRepository=selectedRepository
                            hasCreateRepoPermission=hasCreateRepoPermission
                            isNoneRepositoryAllowed=false
                        /]
                    [/@ui.bambooSection]
                [/@s.form]
            [/#if]
        [/#if]
    </div>
</body>
</html>
