component {
    variables.created = false;

    function init() {
        variables.created = true;
        return this;
    }

    function ping() {
        return {created: variables.created, label: "cfc-init-ok"};
    }
}
