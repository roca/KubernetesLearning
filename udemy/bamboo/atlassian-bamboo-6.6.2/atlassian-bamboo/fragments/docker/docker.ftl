[#-- wrapper of Docker configuration fragment macros --]
[#macro dockerConfigurationFragment headerKey descriptionKey isolationTypeRadioLabelKey isolationTypeRadioName isolationOptions dockerHandlers headerElement='h3']
[#-- @ftlvariable name="dockerHandlers" type="java.util.List<com.atlassian.bamboo.build.docker.DockerConfigurationProviders.Config>" --]
    [#if featureManager.dockerPipelinesEnabled]
        [@ui.header pageKey=headerKey headerElement=headerElement /]
        <div class="description full-size">[@s.text name=descriptionKey /]</div>

        [@s.radio
            id=isolationTypeRadioName
            name=isolationTypeRadioName
            labelKey=isolationTypeRadioLabelKey
            toggle='true'
            listKey='key'
            listValue='value'
            required='true'
            list=isolationOptions /]

        [#list dockerHandlers as handler]
            [@ui.bambooSection dependsOn=isolationTypeRadioName showOn='${handler.isolationType}']
                ${handler.getEditHtml()}
            [/@ui.bambooSection]
        [/#list]
    [#else]
        [@s.hidden name=isolationTypeRadioName value='AGENT'/]
    [/#if]
[/#macro]
