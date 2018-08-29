[#macro anyProjectSelector canChooseAnyBuildProject canChooseAnyDeploymentProject selectProjectKey='' selectProjectName='' selectDeploymentKey='' selectDeploymentName='']
    <div id="project-selector">
        <div class="group">
        [@s.label key="rss.specs.onboarding.creation.project.type" escapeHtml=false required=true]
            [@s.param name="value"]
                <div class="aui-group">
                    <div class="aui-item">
                        [@projectTypeSelector
                            typeId="buildProjectOption"
                            typeValue="BUILD"
                            isChecked=canChooseAnyBuildProject
                            labelName="rss.specs.onboarding.creation.project.type.build"
                        ]
                            [@buildProjectSelector canChooseAnyBuildProject selectProjectKey selectProjectName /]
                        [/@projectTypeSelector]
                        [@projectTypeSelector
                            typeId="deploymentProjectOption"
                            typeValue="DEPLOYMENT"
                            isChecked=!canChooseAnyBuildProject
                            labelName="rss.specs.onboarding.creation.project.type.deployment"
                        ]
                            [@deploymentProjectSelector canChooseAnyDeploymentProject selectDeploymentKey selectDeploymentName /]
                        [/@projectTypeSelector]
                        [#if (fieldErrors["projectTypeOption"])?has_content]
                            [#list fieldErrors["projectTypeOption"] as error]
                                <div class="error">${error?html}</div>
                            [/#list]
                        [/#if]
                    </div>
                </div>
            [/@s.param]
        [/@s.label]
        </div>
    </div>
[/#macro]

[#macro projectTypeSelector typeId typeValue isChecked labelName]
    <div class="radio">
        <input id="${typeId}"
                name="projectTypeOption"
                value="${typeValue}"
                class="radio handleOnSelectShowHide"
                type="radio"
            [#if isChecked]checked="checked"[/#if]
        >
        <label for="${typeId}">[@s.text name="${labelName}"/]</label>
        [@ui.bambooSection dependsOn="projectTypeOption" showOn="${typeValue}"]
            [#nested /]
        [/@ui.bambooSection]
    </div>
[/#macro]

[#macro buildProjectSelector canChooseAnyBuildProject selectProjectKey selectProjectName]
    [#if canChooseAnyBuildProject]
        [@projectSelector
            projectKeyId="selectProjectKey"
            projectNameId="selectProjectName"
            endpoint="/rest/api/latest/search/projects"
            placeholder="rss.specs.onboarding.creation.project.build.placeholder"
            permission="ADMINISTRATION"
            defaultProjectKey=selectProjectKey
            defaultProjectName=selectProjectName
        /]
    [#else]
        [@ui.messageBox type='info']
            [@s.text name="rss.specs.onboarding.creation.error.no.project.available.build"/]
        [/@ui.messageBox]
    [/#if]
[/#macro]

[#macro deploymentProjectSelector canChooseAnyDeploymentProject selectDeploymentKey selectDeploymentName]
    [#if canChooseAnyDeploymentProject]
        [@projectSelector
            projectKeyId="selectDeploymentKey"
            projectNameId="selectDeploymentName"
            endpoint="/rest/api/latest/search/deployments"
            placeholder="rss.specs.onboarding.creation.project.deployment.placeholder"
            permission="WRITE"
            defaultProjectKey=selectDeploymentKey
            defaultProjectName=selectDeploymentName
        /]
    [#else]
        [@ui.messageBox type='info']
            [@s.text name="rss.specs.onboarding.creation.error.no.project.available.deployment"/]
        [/@ui.messageBox]
    [/#if]
[/#macro]

[#macro projectSelector projectKeyId projectNameId endpoint placeholder permission defaultProjectKey defaultProjectName]
    [@s.hidden name="${projectNameId}" id="${projectNameId}"/]
    [@s.textfield name="${projectKeyId}" id="${projectKeyId}"/]
    <script>
        require(['jquery', "widget/project-selector"], function($, ProjectSelector) {
            ProjectSelector.create({
                                       el: '#${projectKeyId?js_string}',
                                       endpoint: AJS.contextPath() + '${endpoint?js_string}',
                                       placeholder: '[@s.text name="${placeholder}"/]',
                                       permission: '${permission?js_string}',
                                       defaultSelection: {
                                           id: '${defaultProjectKey?js_string}',
                                           text: '${defaultProjectName?js_string}',
                                       },
                                       onSelect: (e) => {
                                           const data = e.added;
                                           $('#${projectNameId?js_string}').val(data.text);
                                       },
                                   });
        });
    </script>
[/#macro]