[#-- Avoid double space if os_username is not set --]
{"status-code":"403","error-code":"${(stack.findValue('exception.errorCode')!'')?json_string}","message":"${i18n.getText("error.xsrf.message")}"}
