[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.admin.user.ConfigureUser" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.admin.user.ConfigureUser" --]
[#assign pageTitleKey = ((mode!'') == 'edit')?string('user.admin.edit.title', 'user.admin.add.title') /]

<html>
<head>
    <title>[@s.text name=pageTitleKey/]</title>
    <meta name="decorator" content="focusTask"/>
</head>
<body>

<h2>[@s.text name=pageTitleKey /]</h2>

[#-- need to inject the context manually because we're not using admin panel decorator --]
${webResourceManager.requireResourcesForContext("atl.admin")}

[#if mode == "edit" && (!username?? || !currentUser??)]
    [@ui.messageBox type='error' cssClass='user-not-found']
        [@s.text name='user.admin.edit.failed']
            [@s.param]${username!""}[/@s.param]
        [/@s.text]
    [/@ui.messageBox]

    <div class="aui-toolbar inline back-button">
        <ul class="toolbar-group">
            <li class="toolbar-item">
                <a href="${req.contextPath}/admin/administer.action" class="toolbar-trigger">
                [@s.text name='user.admin.back.to.admin.panel' /]
                </a>
            </li>
        </ul>
    </div>
[#else]
    [#if mode == "add" && !action.canCreateUsers()]
        [@cp.noUserDirectoryPermissionsInfo/]

    [#else]
        [#if mode == "edit" ]
            [#assign readOnly = bambooUserManager.isReadOnly(currentUser) /]
            [#assign targetAction = "updateUser"]

            [#assign cancelUri = "/admin/user/viewUser.action?username=${username}" /]
        [#else]
            [#assign readOnly = false /]
            [#assign targetAction = "createUser"]
            [#assign cancelUri = "/admin/user/viewUsers.action" /]
        [/#if]

        [@s.form action=targetAction
        submitLabelKey="global.buttons.update"
        cancelUri=cancelUri]

            [#if mode == "edit" && readOnly]
                [@ui.messageBox type='info' cssClass='user-read-only-info']
                    [@s.text name='user.admin.edit.read.only.permissions'/]
                [/@ui.messageBox]

                [@s.label labelKey="user.username" name="username" /]
                [@s.hidden name="username"/]
                [@s.checkbox name="enabled" labelKey="user.active.user" disabled=true/]
                [@s.label labelKey="user.fullName" name="fullName" /]
                [@s.label labelKey="user.email" name="email" /]
                [@s.hidden name="fullName" /]
                [@s.hidden name="email" /]
                [@s.textfield labelKey="user.jabber" name="jabberAddress" /]
            [/#if]

            [#if mode == "add" || (mode == "edit" && !readOnly)]
                [#if mode == "add"]
                    [@s.textfield labelKey="user.username" name="username" required=true /]
                [#else]
                    [@s.label labelKey="user.username" name="username" /]
                    [@s.hidden name="username"/]
                    [@s.checkbox name="enabled" labelKey="user.active.user" /]
                [/#if]
                [@s.textfield labelKey="user.fullName" name="fullName" required=true /]
                [@s.textfield labelKey="user.email" name="email" required=true /]


                [#if mode=="add"]
                    [@s.password labelKey="user.password" name="password" required=true/]
                    [@s.password labelKey="user.password.confirm" name="confirmPassword" required=true/]
                [#elseif passwordEditable]
                    [@s.checkbox name="changePassword" labelKey="user.profile.change.password" toggle=true/]

                    [@ui.bambooSection dependsOn="changePassword" showOn=true]
                        [@s.password labelKey="user.password" name="password" required=true/]
                        [@s.password labelKey="user.password.confirm" name="confirmPassword" required=true/]
                    [/@ui.bambooSection]
                [#else]
                    [@s.hidden name="changePassword" value="false" /]
                [/#if]
                [@s.textfield labelKey="user.jabber" name="jabberAddress" /]
            [/#if]
        [/@s.form]
    [/#if]
[/#if]

</body>
</html>
