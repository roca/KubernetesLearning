[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.admin.group.ConfigureGroup" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.admin.group.ConfigureGroup" --]
<html>
<head>
    <title>[@s.text name='group.admin.manage.title' /]</title>
    <meta name="adminCrumb" content="groupConfig">
</head>

<body>
    <div class="toolbar">
        <div class="aui-toolbar inline">
            <ul class="toolbar-group">
                [#if action.canCreateGroups()]
                    <li class="toolbar-item">
                        <a href="${req.contextPath}/admin/group/addGroup.action" class="create-group-button toolbar-trigger">[@s.text name='group.admin.add' /]</a>
                    </li>
                [/#if]
            </ul>
        </div>
    </div>

    <h1>[@s.text name='group.admin.manage.heading' /]</h1>

    <div id="groups-list-container"></div>
    <script>
        require(['page/groups-list'], function(GroupsList) {
            new GroupsList({ el: '#groups-list-container' }).render();
        });
    </script>
</body>
</html>
