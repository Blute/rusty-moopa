<cfscript>
function testUnscopedAssignment() {
    probeValue = "written inside function without var/local/variables";

    return {
        localHasProbeValue = structKeyExists(local, "probeValue"),
        variablesHasProbeValueInsideFunction = structKeyExists(variables, "probeValue"),
        localValue = local.probeValue ?: "",
        variablesValueInsideFunction = variables.probeValue ?: ""
    };
}

result = testUnscopedAssignment();
result.variablesHasProbeValueAfterFunction = structKeyExists(variables, "probeValue");
result.variablesValueAfterFunction = variables.probeValue ?: "";

writeOutput(serializeJSON(result));
</cfscript>
