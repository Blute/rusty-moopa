<cfif issue EQ "01">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Moopa bootstraps framework, app, shared, and web-root paths through Lucee mappings. The test checks whether RustCFML can support the same shape explicitly.</p>
    <pre><code>component {
  this.mappings = {
    "/moopa": "/var/www/code/moopa",
    "/apps": "/var/www/code/apps",
    "/shared": "/var/www/code/shared",
    "/": getDirectoryFromPath(getCurrentTemplatePath())
  };

  public void function onRequest(required string targetPage) {
    include arguments.targetPage;
  }
}</code></pre>
  </div>
</cfif>

<cfif issue EQ "02">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Layouts, controls, routes, and form widgets are composed with custom tags. The test exercises tag lookup, body content, and caller-scope mutation.</p>
    <pre><code>&lt;cf_layout_default title="Users"&gt;
  &lt;cf_control name="profile/list" records="#profiles#"&gt;
&lt;/cf_layout_default&gt;

&lt;cf_field_text name="email" value="#record.email#"&gt;
&lt;cfset caller.formErrors = local.errors&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "03">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Moopa clean URLs are rewritten into a single route entrypoint. The test confirms RustCFML can forward a clean URL into <code>_moopa.cfm</code> with the intended route and query values.</p>
    <pre><code># nginx-style intent
rewrite ^/(.*)$ /_moopa.cfm?route=/$1&amp;$args last;

# RustCFML urlrewrite.xml smoke rule
&lt;rule last="true"&gt;
  &lt;from&gt;^/rewrite-test/(.*)$&lt;/from&gt;
  &lt;to&gt;/_moopa.cfm?route=/rewrite-test/$1&lt;/to&gt;
&lt;/rule&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "04">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Lucee projects often read Docker and CFConfig values through <code>server.system.environment</code>. RustCFML needs a portable adapter.</p>
    <pre><code>// Lucee-era code
host = server.system.environment.PROJECT_DSN_HOST;

// Portable helper target
function env(required string name, string fallback = "") {
  return getEnvironmentVariable(arguments.name) ?: arguments.fallback;
}</code></pre>
  </div>
</cfif>

<cfif issue EQ "05">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Moopa uses a named datasource from Lucee configuration. The RustCFML test checks the equivalent explicit PostgreSQL URL path.</p>
    <pre><code>&lt;cfquery name="roles" datasource="project"&gt;
  select id, name, label
  from moo_role
  order by name
&lt;/cfquery&gt;

&lt;cfquery name="roles" datasource="#getEnvironmentVariable('RUSTCFML_DSN_URL')#"&gt;
  select id::text, name, label
  from moo_role
&lt;/cfquery&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "06">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>The dynamic CRUD layer builds query parameter structs at runtime, then passes them into <code>cfqueryparam</code>. This is a blocker if RustCFML only reads explicit attributes.</p>
    <pre><code>&lt;cfset param = {
  value: form.email,
  cfsqltype: "cf_sql_varchar",
  null: !len(form.email)
}&gt;

&lt;cfquery datasource="project"&gt;
  update moo_profile
  set email = &lt;cfqueryparam attributeCollection="#param#"&gt;
  where id = &lt;cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar"&gt;
&lt;/cfquery&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "07">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Moopa helpers expect Lucee query return shapes, especially arrays for records and keyed structs for metadata.</p>
    <pre><code>&lt;cfquery name="records" datasource="project" returntype="array"&gt;
  select id, label from moo_role
&lt;/cfquery&gt;

&lt;cfquery name="indexes" datasource="project" returntype="struct" columnkey="indexname"&gt;
  select indexname, indexdef from pg_indexes
&lt;/cfquery&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "08">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Starter tables use UUIDs, timestamps, JSONB, booleans, and numeric types. The test protects a safe read path until native driver conversion is dependable.</p>
    <pre><code># risky until RustCFML type conversion is fixed
select * from moo_role;

# safe compatibility read
select row_to_json(r)::text as payload
from (
  select id::text, created_at::text, name, metadata::text
  from moo_role
) r;</code></pre>
  </div>
</cfif>

<cfif issue EQ "09">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Some Moopa utilities may lean on Java classes for UUIDs, crypto, dates, regex, files, or encoding. RustCFML is not a JVM, so each usage needs either a shim or a CFML replacement.</p>
    <pre><code>&lt;cfscript&gt;
uuid = createObject("java", "java.util.UUID").randomUUID().toString();
mac = createObject("java", "javax.crypto.Mac").getInstance("HmacSHA256");
messageDigest = createObject("java", "java.security.MessageDigest").getInstance("SHA-256");
&lt;/cfscript&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "10">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Moopa can use background work for logs, notifications, or deferred route side effects. The smoke test checks whether the basic tag exists, not whether production concurrency is equivalent.</p>
    <pre><code>&lt;cfthread name="auditLog" action="run" userId="#session.user.id#"&gt;
  insertAuditLog(attributes.userId, now());
&lt;/cfthread&gt;

&lt;cfthread action="join" name="auditLog" timeout="1000"&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "11">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Moopa authentication and admin flows expect session state. Lucee production config may use external storage, while this test only proves local process storage.</p>
    <pre><code>&lt;cfset session.user = {
  id: profile.id,
  email: profile.email,
  roles: roleNames
}&gt;

&lt;cfif structKeyExists(session, "user")&gt;
  &lt;cfset request.currentUser = session.user&gt;
&lt;/cfif&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "12">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Lucee modern local scope keeps unscoped variables inside functions local. RustCFML currently behaves closer to classic mode in CFC methods, so implicit locals can leak into component state.</p>
    <pre><code>public struct function read(required string id) {
  sql = "select * from moo_profile where id = ?";
  params = [arguments.id];
  return variables.db.query(sql, params);
}

// Safer RustCFML-compatible form
public struct function read(required string id) {
  local.sql = "select * from moo_profile where id = ?";
  local.params = [arguments.id];
  return variables.db.query(local.sql, local.params);
}</code></pre>
  </div>
</cfif>

<cfif issue EQ "13">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Even if <code>attributeCollection</code> needs an adapter, explicit parameter binding must keep working for filters, deletes, and lookups.</p>
    <pre><code>&lt;cfquery name="profile" datasource="project"&gt;
  select id, email
  from moo_profile
  where id = &lt;cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar"&gt;
&lt;/cfquery&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "14">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Search and relationship operations pass lists into SQL <code>IN</code> clauses. This test keeps <code>list="true"</code> binding visible.</p>
    <pre><code>&lt;cfquery name="records" datasource="project"&gt;
  select id, label
  from moo_role
  where id in (
    &lt;cfqueryparam value="#arguments.ids#" cfsqltype="cf_sql_varchar" list="true"&gt;
  )
&lt;/cfquery&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "15">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Admin pickers and list pages search generated label columns with PostgreSQL <code>ILIKE</code>.</p>
    <pre><code>&lt;cfquery name="matches" datasource="project"&gt;
  select id, label
  from moo_profile
  where label ilike &lt;cfqueryparam value="%#arguments.search#%" cfsqltype="cf_sql_varchar"&gt;
  order by label
&lt;/cfquery&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "16">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Schema sync wants metadata keyed by name so it can diff existing indexes and foreign keys quickly.</p>
    <pre><code>&lt;cfquery name="indexes" datasource="project" returntype="struct" columnkey="indexname"&gt;
  select indexname, indexdef
  from pg_indexes
  where schemaname = 'public'
    and tablename = &lt;cfqueryparam value="#tableName#" cfsqltype="cf_sql_varchar"&gt;
&lt;/cfquery&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "17">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>A safe RustCFML read path can return JSON text from PostgreSQL and parse it in CFML, preserving record-shaped data without native UUID or timestamp conversion.</p>
    <pre><code>&lt;cfquery name="q" datasource="project"&gt;
  select row_to_json(r)::text as payload
  from (
    select id::text, label, created_at::text
    from moo_role
    limit 1
  ) r
&lt;/cfquery&gt;

&lt;cfset record = deserializeJSON(q.payload)&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "18">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Until type conversion is fixed upstream, the database layer can cast risky columns to text and leave parsing to Moopa.</p>
    <pre><code>select
  id::text as id,
  created_at::text as created_at,
  updated_at::text as updated_at,
  metadata::text as metadata,
  name
from moo_role;</code></pre>
  </div>
</cfif>

<cfif issue EQ "19">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Moopa initializes libraries and services during application startup with CFC constructors.</p>
    <pre><code>&lt;cfscript&gt;
application.lib.db = createObject("component", "moopa.lib.db").init(
  datasource = "project",
  schema = "public"
);
application.lib.auth = createObject("component", "apps.admin.lib.auth").init(application.lib.db);
&lt;/cfscript&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "20">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Starter local login hashes passwords with PBKDF2. The test checks the function needed by that auth path.</p>
    <pre><code>&lt;cfscript&gt;
salt = generateSecretKey("AES", 128);
hash = generatePBKDFKey(
  "PBKDF2WithHmacSHA256",
  form.password,
  salt,
  120000,
  256
);
&lt;/cfscript&gt;</code></pre>
  </div>
</cfif>

<cfif issue EQ "21">
  <div class="panel">
    <span class="badge">Moopa pattern</span>
    <p>Moopa dispatches route targets and layouts with dynamic includes. RustCFML handles relative includes, but leading-slash root includes need an adapter.</p>
    <pre><code>&lt;cfinclude template="/apps/#application.appName#/routes/#route.file#"&gt;
&lt;cfinclude template="/shared/layouts/default.cfm"&gt;

// Safer adapter shape
&lt;cfinclude template="#application.paths.apps#/#application.appName#/routes/#route.file#"&gt;</code></pre>
  </div>
</cfif>
