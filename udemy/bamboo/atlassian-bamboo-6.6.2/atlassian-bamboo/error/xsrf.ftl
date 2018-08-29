[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.error.ErrorAction" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.error.ErrorAction" --]
<html>
<head>
    <title>[@s.text name='error.xsrf.title' /]</title>
</head>
<body>
    [#assign errorCode = stack.findValue('exception.errorCode')!'' /]
    <h1>[@s.text name='error.xsrf.heading' /]</h1>
    <p>[@s.text name='error.xsrf.message' /]</p>
    [#if errorCode?has_content]
        <p>[@s.text name='error.xsrf.error.code'][@s.param]${errorCode?html}[/@s.param][/@s.text]</p>
    [/#if]
    <h4>[@s.text name='error.xsrf.nav.title' /]</h4>
    <ul>
        <li><a href="${req.contextPath}/">[@s.text name='error.xsrf.nav.home' /]</a></li>
    </ul>
</body>
</html>
