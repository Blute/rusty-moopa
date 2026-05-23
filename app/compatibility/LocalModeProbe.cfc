component {
    function run() {
        implicitInside = "implicit assignment in cfc method";
        return {
            localHasImplicit = structKeyExists(local, "implicitInside"),
            variablesHasImplicitInside = structKeyExists(variables, "implicitInside")
        };
    }

    function after() {
        return {
            variablesHasImplicitAfter = structKeyExists(variables, "implicitInside")
        };
    }

    function runModern() localMode="modern" {
        modernImplicitInside = "implicit assignment in localMode modern method";
        return {
            localHasModernImplicit = structKeyExists(local, "modernImplicitInside"),
            variablesHasModernImplicitInside = structKeyExists(variables, "modernImplicitInside")
        };
    }

    function afterModern() {
        return {
            variablesHasModernImplicitAfter = structKeyExists(variables, "modernImplicitInside")
        };
    }
}
