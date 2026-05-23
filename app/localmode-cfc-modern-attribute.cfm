<cfscript>
probe = createObject("component", "LocalModeModernProbe");
result = probe.run();
structAppend(result, probe.after(), true);
writeOutput(serializeJSON(result));
</cfscript>
