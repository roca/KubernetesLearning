[#-- @ftlvariable name="action" type="com.atlassian.bamboo.deployments.environments.actions.ConfigureEnvironmentTasks" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.deployments.environments.actions.ConfigureEnvironmentTasks" --]

[@ww.text var="tasksConfigFormTitle" name="tasks.config.form.title"]
    [@ww.param]${taskName!?html}[/@ww.param]
[/@ww.text]

[@ww.form   action=submitAction
            namespace="/deploy/config"
            submitLabelKey="global.buttons.update"
            cancelUri="/deploy/config/configureEnvironmentTasks.action?environmentId=${environmentId}"
            cssClass="top-label"]

    <div class="task-heading">
        <h2>${tasksConfigFormTitle}</h2>
    </div>
    [#if taskHelpLink??]
    <div class="task-help">
        [#if taskHelpLink.usingPrefix == true]
            [@help.url pageKey="${taskHelpLink.key}"][@ww.text name="${taskHelpLink.key}.title"/][/@help.url]
        [#else]
            <a id='taskHelpLink' href='[@ww.text name="${taskHelpLink.linkKey}"/]'>[@ww.text name="${taskHelpLink.titleKey}"/]</a>
        [/#if]
    </div>
    [/#if]

    [@ww.textfield name="userDescription" labelKey="tasks.userDescription" descriptionClass="assistive" cssClass="long-field"/]
    [@ww.checkbox name="taskDisabled" labelKey="tasks.disable" fieldClass="disable-checkbox" /]

    [#if conditions?has_content]
        [@s.checkbox name="conditionalTask" labelKey="tasks.conditional" toggle=true fieldClass="disable-checkbox" /]
        [@ui.bambooSection dependsOn='conditionalTask' showOn=true]
            [@s.select labelKey='tasks.conditions' list=conditions name='selectedCondition' toggle=true
            listKey='first' listValue='second' /]
            [#list conditions as condition]
                [@ui.bambooSection dependsOn='selectedCondition' showOn=condition.first]
                ${action.conditionHtml(condition.first)}
                [/@ui.bambooSection]
            [/#list]
        [/@ui.bambooSection]
    [/#if]

    ${editHtml!}

    [@ww.hidden name="createTaskKey"/]
    [@ww.hidden name="taskId"/]
    [@ww.hidden name="environmentId"/]
[/@ww.form]