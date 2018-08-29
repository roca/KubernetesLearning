[#-- @ftlvariable name="action" type="com.atlassian.bamboo.webwork.StarterAction" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.webwork.StarterAction" --]

[#if specsRepositoryId?has_content && specsRepositoryId > 0 ]
    [#assign webhookSetupDocumentationUrl][@help.href pageKey="bamboo.specs.webhook.setup" /][/#assign]
    <script type="text/javascript">
        require(['feature/specs-onboarding-dialog'], function(SpecsOnboardingDialog) {
            new SpecsOnboardingDialog({
                                          repositoryId: ${specsRepositoryId},
                                          requiresWebhook: ${specsWebhookRequired?string},
                                          bambooBaseUrl: '${baseUrl?js_string}',
                                          bambooSpecsVersion: '${bambooSpecsVersion?js_string}',
                                          webhookSetupDocumentationUrl: '${webhookSetupDocumentationUrl?js_string}',
                                          onClose: function() {
                                              // remove query params to avoid displaying the dialog on page refresh
                                              window.history.replaceState(null, null, window.location.pathname);
                                          },
                                          [#if buildProjectKey??]
                                              buildProjectKey: '${buildProjectKey?js_string}',
                                          [/#if]
                                      }).show();
        });
    </script>
[/#if]