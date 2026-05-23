<cfscript>
payload = {
    rewriteOk: structKeyExists(url, "route"),
    route: url.route ?: "",
    probe: url.probe ?: "",
    scriptName: cgi.script_name ?: "",
    pathInfo: cgi.path_info ?: "",
    queryString: cgi.query_string ?: ""
};
</cfscript><cfcontent type="application/json; charset=utf-8"><cfoutput>#serializeJSON(payload)#</cfoutput>
