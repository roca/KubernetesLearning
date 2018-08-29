[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.BambooActionSupport" --]

[#function hasPlanPermission permission plan]
    [#return action.hasPlanPermission(permission, plan)]
[/#function]

[#function hasPlanQuarantinePermissions plan]
    [#return hasPlanPermission("ADMINISTRATION", plan) || hasPlanPermission("BUILD", plan)]
[/#function]

[#function canEditPlan plan]
    [#return hasPlanPermission("ADMINISTRATION", plan) || hasPlanPermission("WRITE", plan)]
[/#function]

[#function hasEntityPermission permission object]
    [#return action.hasEntityPermission(permission, object)]
[/#function]

[#function hasReadPermission object]
    [#return action.hasEntityPermission("READ", object)]
[/#function]

[#function hasEditPermission object]
    [#return action.hasEntityPermission("WRITE", object)]
[/#function]


[#function hasPlanPermissionForKey permission planKey]
    [#return action.hasPlanPermission(permission, planKey)]
[/#function]

[#function hasGlobalPermission permission]
     [#if ctx?has_content]
        [#return ctx.hasGlobalPermission(permission)]
     [#else]
        [#return action.hasGlobalPermission(permission)]
     [/#if]
[/#function]

[#function hasGlobalAdminPermission]
    [#if ctx?has_content]
        [#return ctx.hasGlobalAdminPermission()]
     [#else]
        [#return action.hasGlobalAdminPermission()]
    [/#if]
[/#function]

[#function hasRestrictedAdminPermission]
    [#if ctx?has_content]
        [#return ctx.hasRestrictedAdminPermission()]
    [#else]
        [#return action.hasRestrictedAdminPermission()]
    [/#if]
[/#function]

[#function hasAdminPermission]
    [#if ctx?has_content]
        [#return ctx.hasAdminPermission()]
    [#else]
        [#return action.hasAdminPermission()]
    [/#if]
[/#function]

[#function canRunParameterisedBuild plan]
    [#return ctx.canRunCustomBuild(plan)]
[/#function]

[#function getUserFullName user='']
    [#if user?has_content]
        [#if user.fullName?has_content]
            [#return user.fullName]
        [#else]
            [#if user.name?has_content]
                [#return user.name]
            [#else]
                [#return "Name Unknown"]
            [/#if]
        [/#if]
    [#else]
        [#return "Anonymous User"]
    [/#if]
[/#function]

[#function getAuthorFullName author='']
    [#if author?has_content]
        [#if author.fullName?has_content]
            [#return author.fullName]
        [#else]
            [#if author.name?has_content]
                [#return author.name]
            [#else]
                [#return "[unknown]"]
            [/#if]
        [/#if]
    [#else]
        [#return "[unknown]"]
    [/#if]
[/#function]

[#function sanitizeUri uri='']
    [#return ctx.sanitizeUrl(uri)]
[/#function]

[#function displayCreateRepositoryLink]
    [#if ctx?has_content]
        [#local repositoryDashboardEnabled = ctx.featureManager.repositoryDashboardEnabled /]
    [#else]
        [#local repositoryDashboardEnabled = action.featureManager.repositoryDashboardEnabled /]
    [/#if]
    [#return repositoryDashboardEnabled && hasGlobalPermission("CREATEREPOSITORY")/]
[/#function]

[#--
 According to the HTML standard, ID and NAME tokens must begin with a letter ([A-Za-z])
 and may be followed by any number of letters,
 digits ([0-9]), hyphens ("-"), underscores ("_"), colons (":"), and periods (".").

 This method replaces all invalid characters in the supplied id with an underscore. It does not enforce the
 "must begin with a letter" rule.

 There are two functions that do it, one in FreeMarker functions.ftl and one in BambooStringUtils. They MUST be
 kept in sync.
--]
[#function forceValidHtmlId htmlId]
    [#return htmlId?replace("[^-A-Za-z0-9_:.]", "_", "r")]
[/#function]

[#-- ================================================================================================= @ui.getTestCaseResultUrl --]
[#function getTestCaseResultUrl buildKey buildNumber testCaseId]
    [#return "/browse/${buildKey}-${buildNumber}/test/case/${testCaseId}"]
[/#function]
[#-- ================================================================================================= @ui.getViewTestCaseHistoryUrl --]
[#function getViewTestCaseHistoryUrl buildKey testCaseId]
    [#return "/browse/${buildKey}/test/case/${testCaseId}" ]
[/#function]

[#function getPlanEditLink build]
    [#if !isChain(build)]
        [#return "${req.contextPath}/build/admin/edit/editBuildConfiguration.action?buildKey=${build.key}"]
    [#else]
        [#return "${req.contextPath}/chain/admin/config/editChainConfiguration.action?buildKey=${build.key}"]
    [/#if]
[/#function]

[#function getPlanRunLink build]
    [#return "${req.contextPath}/build/admin/triggerManualBuild.action?buildKey=${build.key}"]
[/#function]

[#function getPlanStopLink build]
    [#return "${req.contextPath}/build/admin/ajax/stopPlan.action?planKey=${build.key}"]
[/#function]

[#function getPlanStatusIcon buildResult]
    [#if buildResult.buildState == 'Successful' && (buildResult.continuable)!false]
        [#return 'SuccessfulPartial' /]
    [/#if]
    [#if fn.isSpecsFailure(buildResult)]
        [#return 'SpecsFailure' /]
    [/#if]
    [#if fn.isSpecsSuccess(buildResult)]
        [#return 'SpecsSuccess' /]
    [/#if]
    [#if buildResult.finished]
        [#return buildResult.buildState /]
    [/#if]
    [#if (buildResult.notRunYet)!false]
        [#return 'NotRunYet' /]
    [/#if]
    [#return buildResult.lifeCycleState /]
[/#function]

[#function isSpecsFailure buildResult]
    [#return ctx.isBambooSpecsFailure(buildResult)]
[/#function]

[#function isSpecsSuccess buildResult]
    [#return ctx.isBambooSpecsSuccess(buildResult)]
[/#function]

[#function isChain plan]
    [#return plan?? && (plan.planType == 'CHAIN' || plan.planType == 'CHAIN_BRANCH')]
[/#function]

[#function getPlanI18nKeyPrefix plan]
    [#if plan.planType == 'CHAIN']
        [#return 'chain'/]
    [#elseif plan.planType == 'JOB']
        [#return 'job'/]
    [#elseif plan.planType == 'CHAIN_BRANCH']
        [#return 'branch'/]
    [/#if]
    [#return 'unexpected'/]
[/#function]

[#function isBranch plan]
    [#return plan?? && plan.planType == 'CHAIN_BRANCH']
[/#function]

[#function isJob plan]
    [#return plan?? && plan.planType == 'JOB']
[/#function]

[#function ognlLiteral value]
    [#return '%{"${value?j_string}"}'/]
[/#function]

[#function renderExtraAttributes extraAttributes]
    [#local output = '' /]
    [#list extraAttributes?keys as attr]
        [#local output = output + ' ${attr}="${extraAttributes[attr]}"' /]
    [/#list]
    [#return output /]
[/#function]

[#function resolveName text="" textKey=""]
    [#if text?has_content]
        [#return text]
    [/#if]
    [#if textKey?has_content]
        [#local output][@s.text name=textKey/][/#local]
        [#return output]
    [/#if]
    [#return ""]
[/#function]

[#-- JavaScript related functions --]
[#function jqueryObjectOrUndefined id='']
    [#if id?has_content]
        [#return "$('#"+id+"')"]
    [#else]
        [#return "undefined"]
    [/#if]
[/#function]

[#function stringOrUndefined value='']
    [#if value?has_content]
        [#return "'${value}'"]
    [#else]
        [#return "undefined"]
    [/#if]
[/#function]

[#function join collection on=', ']
    [#local output]
        [#list collection as item]
            [#t]${item}[#if item_has_next], [/#if]
        [/#list]
    [/#local]
    [#return output]
[/#function]

[#-- escape id for jQuery --]
[#function jqid id='']
    [#return id?replace(":","\\\\:")?replace(".","\\\\.")]
[/#function]

[#function arrayOrStringToString value]
    [#if value?is_sequence]
        [#return value?first?string/]
    [#else]
        [#return value?string/]
    [/#if]
[/#function]

[#function isConfigurationReadOnly plan]
    [#if plan.parent?has_content]
        [#return plan.parent.vcsBambooSpecsSource?has_content]
    [#else]
        [#return plan.vcsBambooSpecsSource?has_content]
    [/#if]
[/#function]

[#function isYamlSpecsConfiguration plan]
    [#if isConfigurationReadOnly(plan)]
        [#if plan.parent?has_content]
            [#return plan.parent.vcsBambooSpecsSource.yamlConfiguration]
        [#else]
            [#return plan.vcsBambooSpecsSource.yamlConfiguration]
        [/#if]
    [/#if]
[/#function]


[#function isMasterConfigurationReadOnly plan]
    [#if plan.master?has_content]
        [#return isConfigurationReadOnly(plan.master)]
    [#else]
        [#return isConfigurationReadOnly(plan)]
    [/#if]
[/#function]