component {
    function run() {
        implicitInside = "implicit assignment in cfc method";
        local.explicitLocalInside = "explicit local assignment in cfc method";
        variables.explicitVariablesInside = "explicit variables assignment in cfc method";

        return {
            localHasImplicit = structKeyExists(local, "implicitInside"),
            variablesHasImplicitInside = structKeyExists(variables, "implicitInside"),
            localHasExplicitLocal = structKeyExists(local, "explicitLocalInside"),
            variablesHasExplicitLocalInside = structKeyExists(variables, "explicitLocalInside"),
            localHasExplicitVariables = structKeyExists(local, "explicitVariablesInside"),
            variablesHasExplicitVariablesInside = structKeyExists(variables, "explicitVariablesInside")
        };
    }

    function after() {
        return {
            variablesHasImplicitAfter = structKeyExists(variables, "implicitInside"),
            variablesHasExplicitLocalAfter = structKeyExists(variables, "explicitLocalInside"),
            variablesHasExplicitVariablesAfter = structKeyExists(variables, "explicitVariablesInside")
        };
    }
}
