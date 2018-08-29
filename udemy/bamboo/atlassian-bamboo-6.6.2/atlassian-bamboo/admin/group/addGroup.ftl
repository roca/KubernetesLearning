[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.admin.group.CreateGroupAction" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.admin.group.CreateGroupAction" --]
<html>
<head>
    <title>[@ww.text name='group.admin.add.group.title' /]</title>
    <meta name="decorator" content="focusTask"/>
</head>

<body>

[@ui.header pageKey="group.admin.add.group.title" headerElement='h2'/]

[#if action.canCreateGroups()]
    [@s.form
    action="saveGroup"
    method="post"
    cancelUri="/admin/group/viewGroups.action" submitLabelKey="global.buttons.update"]
        <div class="configSection">
             [@s.textfield labelKey='group.groupName' name='groupName' id='groupName' required=true /]
        </div>
    [/@s.form]

[#else]
    [@cp.noUserDirectoryPermissionsInfo/]
[/#if]

</body>
</html>
