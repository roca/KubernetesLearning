[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.build.admin.create.CreateChain" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.build.admin.create.CreateChain" --]

[#import "/lib/chains.ftl" as chain]
${webResourceManager.requireResourcesForContext("bamboo.configuration")}

<html>
<head>
    <title>[@s.text name='plan.create.clone.title' /]</title>
    <meta name="decorator" content="atl.general"/>
    <meta name="topCrumb" content="create"/>
    <meta name="bodyClass" content="aui-page-focused aui-page-focused-xlarge"/>
</head>
<body>

<div class="toolbar aui-toolbar inline">[@help.url pageKey='plan.clone.howtheywork'][@s.text name='plan.clone.howtheywork.title'/][/@help.url]</div>
[@ui.header pageKey="plan.create.clone.title" headerElement="h2" cssClass="plan.create.clone.title" /]
<p>[@s.text name="plan.create.clone.description" /]</p>

[#assign canCreateProject = ctx.canCreateProject() /]
[#assign canUseExistingProject = uiConfigBean.existingProjectsForPlanCreation?has_content /]

[#if !canCreateProject && !canUseExistingProject]
    [@chain.noCreatePermissionsInfo/]
[#else]

    <form id="performClonePlan"
          name="performClonePlan"
          action="[@s.url action='performClonePlan'
          namespace='/build/admin/create'][/@s.url]"
          method="post"
          class="aui performClonePlan">
                    [@ui.bambooSection titleKey="chain.clone.list"]
                        [#if plansToClone?has_content]
                            [@s.select labelKey='chain.name' name='planKeyToClone' id='planKeyToClone'
                            list='plansToClone' listKey='key' listValue='buildName' groupBy='project.name']
                            [/@s.select]
                        [#else]
                            [@ui.messageBox type="warning"][@s.text name="chain.clone.list.empty" /][/@ui.messageBox]
                        [/#if]
                    [/@ui.bambooSection]

            <script>
                require('widget/simple-select2')('[name="planKeyToClone"]');
            </script>

            [@s.hidden name="chainEnabled" value="false"/]

            [@ui.bambooSection titleKey="project.details"]
                [#include "/fragments/project/selectCreateProject.ftl"]
                [#include "/fragments/chains/editChainKeyName.ftl"]
                [@s.hidden name="clonePlan" value="true"/]
            [/@ui.bambooSection]
            <div class="aui-toolbar2 buttons-container">
                <div class="aui-toolbar-2-inner">
                    <div class="aui-toolbar2-primary">
                        <div class="aui-buttons">
                            <button class="aui-button aui-button-primary" name="clonePlanButton"
                                    id="clonePlanButton">[@s.text name="plan.clone.button"/]</button>
                        </div>
                        <div class="aui-buttons save-and-continue">
                            <button class="aui-button"
                                    id="saveAndContinue">[@s.text name="global.buttons.save.and.continue"/]</button>
                        </div>
                        <div class="aui-buttons">
                            <a class="cancel-link " href="[@s.url action='start'/]">
                                [@s.text name="global.buttons.cancel"/]
                            </a>
                        </div>
                    </div>
                </div>
            </div>
    </form>


    <script type="text/javascript">
        AJS.$(function ($) {
            var $projectDropdown = $('#performClonePlan_existingProjectKey');
            var handlePlanSelection = function () {
                var selectedProjectKey = $(this).val().split('-')[0];
                $projectDropdown.val(selectedProjectKey);
            };
            var $planToClone = $('#performClonePlan_planKeyToClone').change(handlePlanSelection);
            if (${(!existingProjectKey?has_content)?string}) {
                handlePlanSelection.call($planToClone[0]);
            }
        });

        require(['jquery', 'widget/submit-button'], function ($, SubmitButton) {
            new SubmitButton({
                buttonSelector: '#clonePlanButton',
                formSelector: '#performClonePlan',
                callback: function () {
                    $('#chainEnabled').val(true);
                },
            });
            new SubmitButton({
                buttonSelector: '#saveAndContinue',
                formSelector: '#performClonePlan',
            });
        });
    </script>
[/#if]
</body>
</html>