component {
    function run() localMode="modern" {
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
}
