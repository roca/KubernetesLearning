[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.error.ErrorAction" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.error.ErrorAction" --]
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<status>
    <status-code>403</status-code>
    <error-code>${(stack.findValue('exception.errorCode')!'')?xml}</error-code>
    <message>${i18n.getText("error.xsrf.message")}</message>
</status>
