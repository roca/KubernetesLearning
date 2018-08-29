[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.admin.user.ViewUserDetailsAdminAction" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.admin.user.ViewUserDetailsAdminAction" --]
[#import "/lib/menus.ftl" as menu]

<html>
<head>
    [@ui.header pageKey="user.admin.details" title=true /]
    <meta name="decorator" content="adminpage">
    <meta name="adminCrumb" content="userConfig">
</head>

<body>
[#if user??]
    <div class="toolbar">
        <div class="aui-toolbar inline">
            <ul class="toolbar-group">
                [#-- we always display the edit link, since even for read-only users we allow configuring IM addr. --]
                <li class="toolbar-item">
                    <a id="editUserButton" class="toolbar-trigger"
                       href="[@s.url namespace="/admin/user" action="editUser" username=username /]">
                        [@s.text name="global.buttons.edit"/]
                    </a>
                </li>
                [#if action.canDelete()]
                    <li class="toolbar-item">
                        <a id="deleteUserButton" class="toolbar-trigger mutative requireConfirmation dialog2Confirmation"
                           data-confirmation-title="${action.getText('user.admin.delete')}"
                           data-confirmation-content="${action.getText('user.admin.delete.confirm')}"
                           href="[@s.url namespace="/admin/user" action="deleteUser" username=username /]">
                            [@s.text name="global.buttons.delete"/]
                        </a>
                    </li>
                [/#if]
                [#if action.isCaptchaResetable()]
                    <li class="toolbar-item">
                        <a class="toolbar-trigger mutative resetCaptcha"
                           href="[@s.url namespace="/admin/user" action="resetCaptcha" username=username /]">
                            [@s.text name="user.captcha.reset"/]
                        </a>
                    </li>
                [/#if]
            </ul>
        </div>
    </div>
[/#if]

<ol class="aui-nav aui-nav-breadcrumbs user-admin-breadcrumbs" style="float: left">
    <li>
        <a href="${req.contextPath}/admin/user/viewUsers.action">[@s.text name='user.admin.manage.heading' /]</a>
    </li>
    <li>
        [@s.text name='user.admin.details'/]
    </li>
</ol>

<h1 class="user-admin-header">
    [#if user??]
        ${user.fullName!?html}
    [#else]
        ${username?html}
    [/#if]
</h1>

[#if user??]
[@s.actionerror /]

<div class="user-admin-details">

<div class="aui-group panel-details">
    <div class="aui-item user-avatar">
        [@ui.displayUserGravatar userName="${user.username}" size="150"/]
        <span class="gravatar-notice">
            [@s.text name="user.details.gravatar.info"]
                [@s.param]https://gravatar.com[/@s.param]
            [/@s.text]
        </span>
    </div>
    <div class="aui-item">
        [@s.form class="view-user-details-form"]
            [@s.label labelKey="user.username" escape=false]
                [@s.param name="value"]
                <div class="user-enabled">
                    <span class="user-name">
                        ${username}
                    </span>
                [#if enabled]
                    <span class="user-enabled-status aui-lozenge aui-lozenge-complete">ACTIVE</span>
                [#else]
                    <span class="user-enabled-status aui-lozenge">INACTIVE</span>
                [/#if]
                </div>
                [/@s.param]
            [/@s.label]
            [@s.label labelKey="user.fullName" name="fullName"/]
            [@s.label labelKey="user.email" name="email"/]
            [@s.label labelKey="user.jabber" name="jabberAddress"/]
            [@s.label labelKey="user.directory" name="userDirectory"/]
            [#if action.isCaptchaEnabled()]
                [@s.label labelKey="user.captcha.count" name="captchaCount"/]
            [/#if]
        [/@s.form]
    </div>
</div>


<div class="panel-secondary">
    [@menu.displayWebPanelTabs location="admin.user/details" params={"user": user, "readOnly": !action.canEdit()} /]
</div>

</div>

[#else]
    [@ui.messageBox type='error']
        [@s.text name='user.admin.edit.failed']
            [@s.param]${username!""}[/@s.param]
        [/@s.text]
    [/@ui.messageBox]
[/#if]


</body>
</html>