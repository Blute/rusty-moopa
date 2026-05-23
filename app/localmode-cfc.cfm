<cfscript>
probe = createObject("component", "LocalModeProbe");
result = probe.run();
structAppend(result, probe.after(), true);
writeOutput(serializeJSON(result));
</cfscript>
