<cfif thisTag.executionMode EQ "start">
    <cfoutput><span class="compat-wrapper"></cfoutput>
<cfelse>
    <cfoutput>#thisTag.generatedContent#</span></cfoutput>
    <cfset thisTag.generatedContent = "">
</cfif>
