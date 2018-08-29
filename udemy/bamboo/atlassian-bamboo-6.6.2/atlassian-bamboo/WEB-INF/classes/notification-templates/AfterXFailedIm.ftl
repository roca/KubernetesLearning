[#-- @ftlvariable name="numFailures" type="java.lang.Integer"--]
[#-- @ftlvariable name="baseUrl" type="java.lang.String" --]
[#-- @ftlvariable name="build" type="com.atlassian.bamboo.chains.Chain" --]
[#-- @ftlvariable name="buildSummary" type="com.atlassian.bamboo.chains.ChainResultsSummary" --]
[#-- @ftlvariable name="triggerReasonDescription" type="java.lang.String" --]
[#-- @ftlvariable name="firstFailedBuildSummary" type="com.atlassian.bamboo.chains.ChainResultsSummary" --]
[#-- @ftlvariable name="firstFailedTriggerReasonDescription" type="java.lang.String" --]
[#include "notificationCommons.ftl"]
[#include "notificationCommonsText.ftl" ]
[#if buildSummary.successful]
[@buildNotificationTitleText build buildSummary/][#if numFailures?has_content] passed after ${numFailures} [#if numFailures==1]failure[#else]failures[/#if][#else] was successful[/#if][@showRestartCount buildSummary/].[#lt]
[#else]
[@buildNotificationTitleText build buildSummary/][#if numFailures?has_content] has failed (${numFailures} [#if numFailures==1]time)[#else]times)[/#if][#else] has failed[/#if][@showRestartCount buildSummary/].[#lt]
[/#if]
 ---------------------------------
[#if triggerReasonDescription?has_content]
    ${triggerReasonDescription} [#lt]
[/#if]
[@showJobAndTestSummary buildSummary/]
[#if firstFailedBuildSummary?has_content]
This plan has been failing since ${firstFailedBuildSummary.planResultKey} (${firstFailedTriggerReasonDescription}, ${firstFailedBuildSummary.getRelativeBuildDate(buildSummary.buildCompletedDate)}).[#lt]
[/#if]
${baseUrl}/browse/${buildSummary.planResultKey}/
