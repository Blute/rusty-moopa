<cfscript>
function inspectScopes() {
    implicitInside = "implicit assignment";
    local.explicitLocalInside = "explicit local assignment";
    variables.explicitVariablesInside = "explicit variables assignment";

    return {
        localHasImplicit = structKeyExists(local, "implicitInside"),
        variablesHasImplicit = structKeyExists(variables, "implicitInside"),

        localHasExplicitLocal = structKeyExists(local, "explicitLocalInside"),
        variablesHasExplicitLocal = structKeyExists(variables, "explicitLocalInside"),

        localHasExplicitVariables = structKeyExists(local, "explicitVariablesInside"),
        variablesHasExplicitVariables = structKeyExists(variables, "explicitVariablesInside"),

        localKeys = structKeyList(local),
        variablesKeysInside = structKeyList(variables)
    };
}

result = inspectScopes();
result.variablesHasImplicitAfter = structKeyExists(variables, "implicitInside");
result.variablesHasExplicitLocalAfter = structKeyExists(variables, "explicitLocalInside");
result.variablesHasExplicitVariablesAfter = structKeyExists(variables, "explicitVariablesInside");
result.variablesKeysAfter = structKeyList(variables);

writeOutput(serializeJSON(result));
</cfscript>
