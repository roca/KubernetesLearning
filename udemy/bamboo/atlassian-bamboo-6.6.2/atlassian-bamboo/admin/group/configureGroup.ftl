[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.admin.group.ConfigureGroup" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.admin.group.ConfigureGroup" --]
[#import "/lib/menus.ftl" as menu]

<html>
<head>
    <title>[@s.text name="group.admin.edit"/]</title>
    <meta name="adminCrumb" content="groupConfig">
</head>
<body>

[#if currentGroup??]
    <div class="toolbar">
        <div class="aui-toolbar inline">
            <ul class="toolbar-group">
                [#if action.canDelete()]
                <li class="toolbar-item">
                    <a id="deleteGroupButton" class="toolbar-trigger mutative requireConfirmation dialog2Confirmation"
                       data-confirmation-title="${action.getText('group.admin.delete')}"
                       data-confirmation-content="${action.getText('group.admin.delete.confirm')}"
                       href="[@s.url namespace="/admin/group" action="deleteGroup" groupName=groupName /]">
                            [@s.text name="global.buttons.delete"/]
                    </a>
                </li>
                [/#if]
            </ul>
        </div>
    </div>
[/#if]

<ol class="aui-nav aui-nav-breadcrumbs group-admin-breadcrumbs">
    <li>
        <a href="${req.contextPath}/admin/group/viewGroups.action">[@s.text name='group.admin.manage.heading' /]</a>
    </li>
    <li>
        [@s.text name='group.admin.details'/]
    </li>
</ol>

<h1 class="group-admin-header">${groupName?html}</h1>

[#if currentGroup??]
    [@s.actionerror /]

    [@menu.displayWebPanelTabs location="admin.group/edit" params={"group": currentGroup, "readOnly": !action.canEdit()} /]
[#else]
    [@ui.messageBox type='error']
        [@s.text name='group.admin.edit.failed']
            [@s.param]${groupName!""}[/@s.param]
        [/@s.text]
    [/@ui.messageBox]
[/#if]

</body>
</html>
