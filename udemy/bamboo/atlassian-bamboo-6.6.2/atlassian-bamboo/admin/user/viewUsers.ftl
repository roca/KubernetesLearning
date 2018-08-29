[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.admin.user.ConfigureUser" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.admin.user.ConfigureUser" --]
<html>
<head>
    <title>[@s.text name='user.admin.manage.title' /]</title>
    <meta name="decorator" content="adminpage">
    <meta name="adminCrumb" content="userConfig">
</head>

<body>
    <div class="toolbar">
        <div class="aui-toolbar inline">
            <ul class="toolbar-group">
                [#if action.canCreateUsers()]
                    <li class="toolbar-item">
                        <a href="${req.contextPath}/admin/user/addUser.action" class="create-user-button toolbar-trigger">[@s.text name='user.admin.add' /]</a>
                    </li>
                [/#if]
            </ul>
        </div>
    </div>

    <h1>[@s.text name='user.admin.manage.heading' /]</h1>

    <div id="users-list-container"></div>
    <script>
        require(['page/users-list'], function(UsersList) {
            new UsersList({ el: '#users-list-container' }).render();
        });
    </script>
</body>
</html>
