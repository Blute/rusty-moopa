<cfscript>
issue = url.issue ?: "01";
runTest = structKeyExists(url, "run");
</cfscript>
<cfinclude template="lib.cfm" />
<cfset title = issueTitle(issue) />
<cfif runTest>
  <cfinclude template="run.cfm" />
</cfif>
<!doctype html>
<html>
<head>
  <title><cfoutput>#title#</cfoutput></title>
  <style>
    body{font-family:system-ui,sans-serif;max-width:980px;margin:3rem auto;padding:0 1rem;line-height:1.6;background:#faf7f0;color:#172033}
    a{color:#0f6849;font-weight:800}.actions{display:flex;gap:.5rem;flex-wrap:wrap;margin:1rem 0 1.5rem}
    a.button{display:inline-flex;border-radius:999px;padding:.45rem .7rem;text-decoration:none;font-weight:800;background:#e8f5ef;color:#0f6849;border:1px solid #bfe5d4}
    a.button.secondary{background:#f3eefc;color:#593089;border-color:#decdf6}
    .panel{background:#fffdfa;border:1px solid #ded7c9;border-radius:1.25rem;padding:1.1rem;margin:1rem 0;box-shadow:0 14px 34px rgba(20,30,50,.07)}
    .result-panel{margin-top:1.5rem}
    code,pre{background:#f1ece2;border-radius:.35rem}code{padding:.1rem .3rem}pre{overflow:auto;padding:1rem}.badge{display:inline-flex;border-radius:999px;padding:.35rem .65rem;background:#f3eefc;color:#593089;font-weight:900}
    .status{display:inline-flex;border-radius:999px;padding:.35rem .65rem;font-weight:900;text-transform:uppercase}.pass{background:#dff7eb;color:#0f6849}.partial,.manual,.untested{background:#fff0c8;color:#805400}.fail{background:#ffe1df;color:#9d2520}
    h2.section{margin-top:2rem}
  </style>
</head>
<body>
  <div class="actions">
    <a class="button secondary" href="index.cfm">← Compatibility tests</a>
    <a class="button" href="explain.cfm?issue=<cfoutput>#issue#</cfoutput>&run=1">Run test</a>
    <a class="button secondary" href="test.cfm?issue=<cfoutput>#issue#</cfoutput>">Open test page</a>
  </div>
  <cfoutput><h1>#title#</h1></cfoutput>

  <cfinclude template="examples.cfm" />

  <cfif issue EQ "01">
    <div class="panel"><span class="badge">Adapter</span><p>Moopa expects Lucee mappings for framework, app, shared, and webroot folders. RustCFML does support Application.cfc lifecycle and component mappings, but it will not read Lucee CFConfig. The compatibility task is to create a RustCFML bootstrap that declares the same paths explicitly.</p><pre>this.mappings = {
  "/moopa": "/var/www/code/moopa",
  "/apps": "/var/www/code/apps",
  "/shared": "/var/www/code/shared"
};</pre></div>
  </cfif>

  <cfif issue EQ "02">
    <div class="panel"><span class="badge">Adapter</span><p>Moopa route, layout, and control rendering depends heavily on custom tags. Moopa Starter scopes tags per app under <code>code/apps/{APP_NAME}/tags</code>, plus shared and framework tags. The Rusty fixture uses <code>Application.cfc</code> with <code>this.customTagPaths</code> and a <code>compatibility/customtags/</code> library that exercises <code>cf_</code> invocation, <code>cfmodule</code>, caller write-back, and body content via <code>thisTag</code>.</p></div>
  </cfif>

  <cfif issue EQ "03">
    <div class="panel"><span class="badge">Workaround</span><p>Moopa clean URLs normally enter the framework through nginx rewriting to <code>/_moopa.cfm?route=...</code>. This harness now includes a narrow RustCFML <code>urlrewrite.xml</code> smoke rule that forwards <code>/rewrite-test/moopa-route?probe=ok</code> to <code>/_moopa.cfm?route=/rewrite-test/moopa-route&amp;probe=ok</code>.</p><pre>&lt;rule last=&quot;true&quot;&gt;
  &lt;from&gt;^/rewrite-test/(.*)$&lt;/from&gt;
  &lt;to&gt;/_moopa.cfm?route=/rewrite-test/$1&lt;/to&gt;
&lt;/rule&gt;</pre><p><a href="/rewrite-test/moopa-route?probe=ok">Open the clean URL probe</a></p></div>
  </cfif>

  <cfif issue EQ "04">
    <div class="panel"><span class="badge">Adapter</span><p>Lucee exposes Docker environment variables through <code>server.system.environment</code>. RustCFML exposes them through <code>getEnvironmentVariable()</code>. Moopa should not scatter engine-specific environment reads; a small environment helper keeps this portable.</p><pre>application.lib.env.get("APP_NAME")
// Lucee: server.system.environment.APP_NAME
// RustCFML: getEnvironmentVariable("APP_NAME")</pre></div>
  </cfif>

  <cfif issue EQ "05">
    <div class="panel"><span class="badge">Blocker</span><p>Lucee resolves the named datasource <code>project</code> from CFConfig. RustCFML expects an actual datasource URL for database work. In this Rusty spike, <code>RUSTCFML_DSN_URL</code> points at the local PostgreSQL 17 container on <code>db:5432</code>, seeded with a minimal <code>moo_role</code> table for SQL compatibility tests.</p></div>
  </cfif>

  <cfif issue EQ "06">
    <div class="panel"><span class="badge">Watch</span><p>Moopa dynamic CRUD builds parameter structs and passes them with <code>cfqueryparam attributeCollection</code>. RustCFML v0.15.0 honours that pattern in the local smoke test, so this is now a protected baseline for save/update compatibility.</p></div>
  </cfif>

  <cfif issue EQ "07">
    <div class="panel"><span class="badge">Validate</span><p>Lucee query tags support convenient return shapes, especially keyed structs for metadata. Moopa schema tooling can work around this by returning normal queries or arrays and building keyed structs manually, but the compatibility boundary should be explicit.</p></div>
  </cfif>

  <cfif issue EQ "08">
    <div class="panel"><span class="badge">Watch</span><p>RustCFML v0.15.0 deserializes direct PostgreSQL UUID and timestamptz columns in the local smoke test. Keep both the direct read and the JSON-wrapper fallback covered so Moopa can rely on native typed reads while retaining an escape hatch for complex shapes.</p><pre>select id, created_at, name, label from moo_role limit 1</pre></div>
  </cfif>

  <cfif issue EQ "09">
    <div class="panel"><span class="badge">Adapter</span><p>RustCFML is not a JVM. Some Java shims exist, but Moopa should replace Java-dependent code with portable CFML or native RustCFML functions where possible. HMAC signing, regex, UUIDs, and date formatting should each get targeted tests.</p></div>
  </cfif>

  <cfif issue EQ "10">
    <div class="panel"><span class="badge">Validate</span><p>RustCFML advertises cfthread support, but Moopa should not assume identical Lucee concurrency semantics. For the spike, synchronous degradation is acceptable. Production-grade background work should likely move behind a queue or service boundary.</p></div>
  </cfif>

  <cfif issue EQ "11">
    <div class="panel"><span class="badge">Adapter</span><p>Lucee sessions are currently backed by Memcached config. RustCFML will not read that configuration. Single-process sessions can work for local tests, but production needs an explicit state strategy such as stateless auth or external session storage.</p></div>
  </cfif>

  <cfif issue EQ "12">
    <div class="panel"><span class="badge">Watch</span><p>Lucee modern local scope means unscoped variables inside functions are local. RustCFML v0.15.0 now passes the local smoke test for both classic and <code>localMode="modern"</code>: classic writes land in <code>variables</code>, while modern writes stay local.</p><pre>function run() localMode="modern" {
  implicitInside = "value";
  // Expected: local.implicitInside only
}</pre><p>Moopa should still prefer explicit <code>local.x</code> for temporary values and <code>variables.x</code> for component state to keep intent clear across engines.</p></div>
  </cfif>

  <cfif issue EQ "13">
    <div class="panel"><span class="badge">Watch</span><p>Moopa still uses many explicit <code>cfqueryparam</code> tags for filters, limits, and UUID predicates. Keep this passing even while <code>attributeCollection</code> remains broken, because read/search/delete paths depend on explicit binding.</p></div>
  </cfif>

  <cfif issue EQ "14">
    <div class="panel"><span class="badge">Watch</span><p><code>db.search()</code> and <code>db.delete()</code> pass id lists with <code>list="true"</code>. A regression here breaks exclude filters, bulk lookups, and relationship writes.</p></div>
  </cfif>

  <cfif issue EQ "15">
    <div class="panel"><span class="badge">Watch</span><p>Moopa admin search boxes rely on <code>label ILIKE</code> against generated label columns. Starter projects use this heavily in sysadmin route, role, and profile pickers.</p></div>
  </cfif>

  <cfif issue EQ "16">
    <div class="panel"><span class="badge">Watch</span><p>Schema sync in Moopa reads PostgreSQL metadata with <code>returntype="struct" columnkey="name"</code> for indexes and foreign keys. This is easy to miss because ordinary queries may still work.</p></div>
  </cfif>

  <cfif issue EQ "17">
    <div class="panel"><span class="badge">Watch</span><p><code>db.read()</code> can return JSON text that route handlers and controls parse with <code>deserializeJSON()</code>. Both the SQL wrapper and JSON parser need to stay stable for Moopa Starter pages to render records.</p></div>
  </cfif>

  <cfif issue EQ "18">
    <div class="panel"><span class="badge">Watch</span><p>Until RustCFML safely deserializes native PostgreSQL types, Moopa reads should cast UUID, timestamptz, and jsonb columns to text in SQL. This test keeps that workaround honest without crashing the worker on raw UUID/timestamp columns.</p></div>
  </cfif>

  <cfif issue EQ "19">
    <div class="panel"><span class="badge">Watch</span><p>Moopa Starter constructs libs and services with <code>createObject("component", ...).init()</code> during application bootstrap. A silent init regression breaks route dispatch before any page renders.</p></div>
  </cfif>

  <cfif issue EQ "20">
    <div class="panel"><span class="badge">Watch</span><p>Moopa Starter local login uses <code>generatePBKDFKey("PBKDF2WithHmacSHA256", ...)</code> in <code>auth_local_password.cfc</code>. Hub setup and dev login depend on this remaining available or having a portable fallback.</p></div>
  </cfif>

  <cfif issue EQ "21">
    <div class="panel"><span class="badge">Watch</span><p><code>moopa.application</code> includes arbitrary target pages and dispatches framework routes through <code>cfinclude</code>. Template resolution from the web root must keep working for both standalone pages and future <code>_moopa.cfm</code> integration.</p></div>
  </cfif>

  <cfif runTest>
    <h2 class="section">Test result</h2>
    <cfinclude template="result.cfm" />
  </cfif>
</body>
</html>
