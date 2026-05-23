<cfscript>
issues = [
    {id: "01", tier: "core", title: "Application mappings", blurb: "Path mapping expectations for /moopa, /apps, /shared, and /."},
    {id: "02", tier: "core", title: "Custom tag paths", blurb: "Custom tag resolution, caller write-back, and body content."},
    {id: "03", tier: "core", title: "URL rewriting", blurb: "Clean URL rewrite and route entrypoint compatibility."},
    {id: "04", tier: "core", title: "Lucee environment scope", blurb: "getEnvironmentVariable versus server.system.environment."},
    {id: "05", tier: "core", title: "Named datasource project", blurb: "PostgreSQL datasource URL and query connectivity."},
    {id: "06", tier: "core", title: "cfqueryparam attributeCollection", blurb: "Moopa db.save parameter style."},
    {id: "07", tier: "core", title: "Query return shapes", blurb: "returntype=array used by Moopa query helpers."},
    {id: "08", tier: "core", title: "PostgreSQL type conversion", blurb: "UUID, timestamptz, JSONB via safe JSON wrapper."},
    {id: "09", tier: "core", title: "Java interop", blurb: "JVM calls versus RustCFML shims or portable CFML replacements."},
    {id: "10", tier: "core", title: "cfthread behaviour", blurb: "Thread semantics used by logging and background workflows."},
    {id: "11", tier: "core", title: "Session storage", blurb: "Session persistence and cookie behaviour under RustCFML."},
    {id: "12", tier: "core", title: "Local scope mode", blurb: "Classic versus modern local scope behaviour."},
    {id: "13", tier: "watch", title: "Explicit cfqueryparam", blurb: "Baseline param binding Moopa relies on outside attributeCollection."},
    {id: "14", tier: "watch", title: "cfqueryparam list IN", blurb: "db.search exclude_ids and ids filters use list=true."},
    {id: "15", tier: "watch", title: "ILIKE label search", blurb: "Moopa table search uses ILIKE on generated label columns."},
    {id: "16", tier: "watch", title: "returntype struct columnkey", blurb: "Schema introspection in db.getTableIndexes and foreign keys."},
    {id: "17", tier: "watch", title: "JSON read roundtrip", blurb: "db.read returns JSON text that Moopa parses with deserializeJSON."},
    {id: "18", tier: "watch", title: "Typed columns via cast", blurb: "Safe read pattern casting UUID, timestamptz, and jsonb to text."},
    {id: "19", tier: "watch", title: "CFC init lifecycle", blurb: "createObject(component).init() pattern used across Moopa libs."},
    {id: "20", tier: "watch", title: "PBKDF2 password hashing", blurb: "auth_local_password uses generatePBKDFKey for login."},
    {id: "21", tier: "watch", title: "cfinclude resolution", blurb: "Application.cfc OnRequest and layouts include templates by path."}
];

titles = {};
issueTiers = {};
for (item in issues) {
    titles[item.id] = item.title;
    issueTiers[item.id] = item.tier;
}

function issueTitle(required string id) {
    return titles[arguments.id] ?: "Compatibility issue";
}
</cfscript>
