<div class="panel result-panel">
  <cfoutput>
    <span class="status #status#">#status#</span>
    <p>#summary#</p>
  </cfoutput>
  <cfif len(detail)>
    <cfoutput><p>#detail#</p></cfoutput>
  </cfif>
</div>
<cfif len(jsonResult)>
  <h2>Raw result</h2>
  <pre><cfoutput>#encodeForHTML(jsonResult)#</cfoutput></pre>
</cfif>
