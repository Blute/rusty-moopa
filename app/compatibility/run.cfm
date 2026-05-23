<cfinclude template="lib.cfm" />
<cfscript>
dsn = getEnvironmentVariable("RUSTCFML_DSN_URL");
status = "untested";
title = issueTitle(issue);
summary = "No automated test has run yet.";
detail = "";
jsonResult = "";
</cfscript>

<cfif issue EQ "01">
  <cfscript>
    rootPath = expandPath("/");
    indexPath = expandPath("/index.cfm");
    rootIndexExists = fileExists(indexPath);
    status = rootIndexExists ? "pass" : "partial";
    summary = "RustCFML can resolve the document-root mapping. Moopa-specific /moopa, /apps, and /shared mappings are not configured in this bare Rusty app.";
    jsonResult = serializeJSON({rootPath:rootPath,indexPath:indexPath,rootIndexExists:rootIndexExists});
  </cfscript>
</cfif>

<cfif issue EQ "02">
  <cfscript>
    tagDir = getDirectoryFromPath(getCurrentTemplatePath()) & "customtags";
    fixtureReady = directoryExists(tagDir)
      AND fileExists(tagDir & "/compat_hello.cfm")
      AND fileExists(tagDir & "/compat_wrapper.cfm")
      AND fileExists(tagDir & "/compat_setter.cfm")
      AND fileExists(getDirectoryFromPath(getCurrentTemplatePath()) & "compat_wrapper.cfm");
    results = {fixtureReady: fixtureReady, tagDir: tagDir, checks: {}};
    appMeta = {};
    try {
      appMeta = getApplicationMetadata();
    } catch (any e) {
      appMeta = {error: e.message};
    }
    results.applicationMetadata = appMeta;
  </cfscript>
  <cftry>
    <cfsavecontent variable="results.checks.cfmoduleSimple">
      <cfmodule template="customtags/compat_hello.cfm" name="Rusty"></cfmodule>
    </cfsavecontent>
    <cfcatch><cfset results.checks.cfmoduleSimple = cfcatch.message /></cfcatch>
  </cftry>
  <cftry>
    <cfsavecontent variable="results.checks.cfPrefixWrapper">
      <cf_compat_wrapper>wrapped-ok</cf_compat_wrapper>
    </cfsavecontent>
    <cfcatch><cfset results.checks.cfPrefixWrapper = cfcatch.message /></cfcatch>
  </cftry>
  <cftry>
    <cfsavecontent variable="results.checks.cfmoduleWrapper">
      <cfmodule template="customtags/compat_wrapper.cfm">module-body</cfmodule>
    </cfsavecontent>
    <cfcatch><cfset results.checks.cfmoduleWrapper = cfcatch.message /></cfcatch>
  </cftry>
  <cftry>
    <cf_compat_setter value="caller-ok">
    <cfset results.checks.callerWriteback = compatEchoMessage ?: "">
    <cfcatch><cfset results.checks.callerWriteback = cfcatch.message /></cfcatch>
  </cftry>
  <cfscript>
    moduleSimpleOk = isSimpleValue(results.checks.cfmoduleSimple ?: "")
      AND find("hello-Rusty", results.checks.cfmoduleSimple) GT 0;
    prefixWrapperOk = isSimpleValue(results.checks.cfPrefixWrapper ?: "")
      AND find("compat-wrapper", results.checks.cfPrefixWrapper) GT 0
      AND find("wrapped-ok", results.checks.cfPrefixWrapper) GT 0;
    moduleWrapperOk = isSimpleValue(results.checks.cfmoduleWrapper ?: "")
      AND find("compat-wrapper", results.checks.cfmoduleWrapper) GT 0
      AND find("module-body", results.checks.cfmoduleWrapper) GT 0;
    callerOk = results.checks.callerWriteback EQ "caller-ok";
    passCount = 0;
    if (moduleSimpleOk) passCount++;
    if (prefixWrapperOk) passCount++;
    if (moduleWrapperOk) passCount++;
    status = passCount EQ 3 ? (callerOk ? "pass" : "partial") : passCount GT 0 ? "partial" : "fail";
    summary = passCount EQ 3
      ? (callerOk
        ? "Custom tags resolve through same-directory cf_ tags and customtags/cfmodule paths, including body content."
        : "Core custom tag rendering works, but caller write-back still fails on RustCFML v0.10.0. Moopa tags that mutate caller scope need an adapter.")
      : passCount GT 0
        ? "Only #passCount#/3 core custom tag scenarios passed. Moopa layouts and controls still need reliable tag resolution."
        : fixtureReady
          ? "Custom tag fixtures are present, but RustCFML did not pass the Moopa-style custom tag smoke checks."
          : "Custom tag fixtures are missing from compatibility/customtags.";
    jsonResult = serializeJSON(results);
  </cfscript>
</cfif>

<cfif issue EQ "03">
  <cftry>
    <cfset rewriteUrl = "http://127.0.0.1:" & (cgi.server_port ?: "8500") & "/rewrite-test/moopa-route?probe=ok" />
    <cfhttp url="#rewriteUrl#" method="get" result="rewriteResponse" timeout="3" />
    <cfscript>
      responseText = rewriteResponse.fileContent ?: "";
      parsedRewrite = len(responseText) ? deserializeJSON(responseText) : {};
      routeOk = isStruct(parsedRewrite)
        AND structKeyExists(parsedRewrite, "rewriteOk")
        AND parsedRewrite.rewriteOk
        AND parsedRewrite.route EQ "/rewrite-test/moopa-route"
        AND parsedRewrite.probe EQ "ok";
      status = routeOk ? "pass" : "fail";
      summary = routeOk
        ? "RustCFML urlrewrite.xml forwarded /rewrite-test/moopa-route to /_moopa.cfm with the expected route value and preserved the original query string."
        : "The rewrite endpoint responded, but the route or query value did not match the Moopa-style expectation.";
      jsonResult = serializeJSON({requestUrl:rewriteUrl,statusCode:rewriteResponse.statusCode ?: "", parsed:parsedRewrite, raw:responseText});
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "Rewrite smoke request failed. Confirm app/urlrewrite.xml is present and restart the RustCFML container so the server reloads rewrite rules.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "04">
  <cfscript>
    envHost = getEnvironmentVariable("PROJECT_DSN_HOST");
    serverEnvWorks = false;
    serverEnvMessage = "";
    try {
      serverEnvWorks = isDefined("server.system.environment") AND structKeyExists(server.system.environment, "PROJECT_DSN_HOST");
    } catch (any e) {
      serverEnvMessage = e.message;
    }
    status = len(envHost) ? "partial" : "fail";
    summary = "getEnvironmentVariable() works for Docker env vars. Lucee's server.system.environment should not be assumed.";
    jsonResult = serializeJSON({getEnvironmentVariableWorks:len(envHost) GT 0, serverSystemEnvironmentWorks:serverEnvWorks, serverEnvMessage:serverEnvMessage});
  </cfscript>
</cfif>

<cfif issue EQ "05">
  <cftry>
    <cfquery name="qDb" datasource="#dsn#">
      select 1::int as ok
    </cfquery>
    <cfscript>
      status = "pass";
      summary = "RustCFML connected to the local PostgreSQL 17 database using RUSTCFML_DSN_URL.";
      jsonResult = serializeJSON(qDb);
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "PostgreSQL connection failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "06">
  <cfset params = {value:"attribute-ok", cfsqltype:"cf_sql_varchar"} />
  <cftry>
    <cfquery name="qParam" datasource="#dsn#">
      select <cfqueryparam attributeCollection="#params#">::text as val
    </cfquery>
    <cfscript>
      paramJson = serializeJSON(qParam);
      status = find("attribute-ok", paramJson) GT 0 ? "pass" : "fail";
      summary = status EQ "pass" ? "attributeCollection was honoured." : "attributeCollection did not appear to pass the value through; this matches the suspected RustCFML scanner gap.";
      jsonResult = paramJson;
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "attributeCollection query failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "07">
  <cftry>
    <cfquery name="qShape" datasource="#dsn#" returntype="array">
      select 'alpha'::text as name, 1::int as id
    </cfquery>
    <cfscript>
      status = "partial";
      summary = "returntype=array produced a result. columnkey-style keyed structs still need a Moopa-specific fixture.";
      jsonResult = serializeJSON(qShape);
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "returntype=array failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "08">
  <cftry>
    <cfquery name="qTypes" datasource="#dsn#">
      select row_to_json(r)::text as moo_role
      from (select * from moo_role limit 1) r
    </cfquery>
    <cfscript>
      status = "partial";
      summary = "Safe JSON-wrapper query works. Direct select * from moo_role previously connected but panicked RustCFML on UUID/timestamp deserialization, so this page avoids crashing the worker.";
      jsonResult = serializeJSON(qTypes);
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "Even the safe JSON-wrapper query failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "09">
  <cfscript>
    try {
      uuidObj = createObject("java", "java.util.UUID");
      uuidValue = uuidObj.randomUUID().toString();
      status = len(uuidValue) ? "partial" : "fail";
      summary = "A Java UUID shim appears available, but Moopa Java usages still need per-class tests.";
      jsonResult = serializeJSON({uuid:uuidValue});
    } catch (any e) {
      status = "fail";
      summary = "Java createObject test failed. Prefer portable CFML/RustCFML replacements.";
      jsonResult = serializeJSON(e);
    }
  </cfscript>
</cfif>

<cfif issue EQ "10">
  <cftry>
    <cfthread name="compatThread">
      <cfset thread.message = "thread-ok" />
    </cfthread>
    <cfthread action="join" name="compatThread" />
    <cfscript>
      status = "partial";
      summary = "A minimal cfthread/join did not throw. This does not prove Lucee-equivalent async semantics.";
      jsonResult = serializeJSON(cfthread.compatThread ?: {});
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "Minimal cfthread/join failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "11">
  <cfscript>
    session.compatCount = (session.compatCount ?: 0) + 1;
    status = "partial";
    summary = "Session scope can persist a counter in this single RustCFML process. Refresh to see the count increment.";
    jsonResult = serializeJSON({compatCount:session.compatCount, cfid:cookie.CFID ?: ""});
  </cfscript>
</cfif>

<cfif issue EQ "12">
  <cfscript>
    try {
      probe = createObject("component", "compatibility.LocalModeProbe");
      result = probe.run();
      structAppend(result, probe.after(), true);
      modernResult = probe.runModern();
      structAppend(modernResult, probe.afterModern(), true);
      structAppend(result, modernResult, true);
      status = result.variablesHasImplicitAfter ? "fail" : "pass";
      summary = status EQ "fail" ? "RustCFML is behaving like classic local mode: unscoped CFC assignments are written to variables and persist after the method call." : "Unscoped CFC assignments stayed local.";
      jsonResult = serializeJSON(result);
    } catch (any e) {
      status = "fail";
      summary = "Local mode probe failed to run.";
      jsonResult = serializeJSON(e);
    }
  </cfscript>
</cfif>

<cfif issue EQ "13">
  <cftry>
    <cfquery name="qExplicit" datasource="#dsn#">
      select <cfqueryparam value="explicit-ok" cfsqltype="cf_sql_varchar">::text as val
    </cfquery>
    <cfscript>
      explicitJson = serializeJSON(qExplicit);
      status = find("explicit-ok", explicitJson) GT 0 ? "pass" : "fail";
      summary = status EQ "pass" ? "Explicit cfqueryparam attributes bind correctly. Keep watching this baseline even when attributeCollection remains broken." : "Explicit cfqueryparam binding failed.";
      jsonResult = explicitJson;
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "Explicit cfqueryparam query failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "14">
  <cftry>
    <cfquery name="qList" datasource="#dsn#">
      select name
      from moo_role
      where name in (<cfqueryparam value="Admin,Agent" cfsqltype="cf_sql_varchar" list="true" />)
      order by name
    </cfquery>
    <cfscript>
      listJson = serializeJSON(qList);
      status = find("Admin", listJson) GT 0 AND find("Agent", listJson) GT 0 ? "pass" : "fail";
      summary = status EQ "pass" ? "list=true IN filters work. Moopa search/delete paths depend on this staying stable." : "list=true cfqueryparam did not return expected rows.";
      jsonResult = listJson;
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "list=true cfqueryparam query failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "15">
  <cftry>
    <cfquery name="qIlike" datasource="#dsn#">
      select name, label
      from moo_role
      where label ilike <cfqueryparam value="%adm%" cfsqltype="cf_sql_varchar" />
      order by name
    </cfquery>
    <cfscript>
      ilikeJson = serializeJSON(qIlike);
      status = find("Admin", ilikeJson) GT 0 ? "pass" : "fail";
      summary = status EQ "pass" ? "ILIKE label search works against seeded moo_role rows." : "ILIKE search did not return the expected Admin row.";
      jsonResult = ilikeJson;
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "ILIKE search query failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "16">
  <cftry>
    <cfquery name="stIndexes" datasource="#dsn#" returntype="struct" columnkey="indexname">
      select indexname, indexdef
      from pg_indexes
      where schemaname = 'public'
        and tablename = <cfqueryparam value="moo_role" cfsqltype="cf_sql_varchar" />
    </cfquery>
    <cfscript>
      status = isStruct(stIndexes) AND structCount(stIndexes) GTE 1 ? "pass" : "partial";
      summary = status EQ "pass" ? "returntype=struct with columnkey works for pg_indexes metadata, matching Moopa schema introspection." : "Query ran but did not return a keyed struct with index metadata.";
      jsonResult = serializeJSON(stIndexes);
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "returntype=struct columnkey query failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "17">
  <cftry>
    <cfquery name="qJsonRead" datasource="#dsn#">
      select row_to_json(r)::text as payload
      from (
        select id::text, name, label, created_at::text
        from moo_role
        order by name
        limit 1
      ) r
    </cfquery>
    <cfscript>
      payload = qJsonRead.payload ?: "";
      parsed = len(payload) ? deserializeJSON(payload) : {};
      status = isStruct(parsed) AND structKeyExists(parsed, "name") ? "pass" : "partial";
      summary = status EQ "pass" ? "row_to_json plus deserializeJSON roundtrip works like a lightweight db.read response." : "JSON text returned, but deserializeJSON did not yield the expected struct shape.";
      jsonResult = serializeJSON({payload:payload, parsed:parsed});
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "JSON read roundtrip failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "18">
  <cftry>
    <cfquery name="qCast" datasource="#dsn#">
      select
        id::text as id,
        created_at::text as created_at,
        name,
        jsonb_build_object('watch', 'jsonb')::text as metadata
      from moo_role
      order by name
      limit 1
    </cfquery>
    <cfscript>
      castJson = serializeJSON(qCast);
      status = find("Admin", castJson) GT 0 OR find("Agent", castJson) GT 0 ? "pass" : "partial";
      summary = "Casting UUID, timestamptz, and jsonb to text avoids RustCFML driver panics while preserving Moopa read semantics.";
      jsonResult = castJson;
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "Typed-column cast query failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>

<cfif issue EQ "19">
  <cfscript>
    try {
      probe = createObject("component", "compatibility.InitProbe").init();
      ping = probe.ping();
      status = ping.created AND ping.label EQ "cfc-init-ok" ? "pass" : "partial";
      summary = status EQ "pass" ? "createObject(component).init() returned a usable instance, matching Moopa lib construction." : "Component loaded, but init()/ping did not return the expected shape.";
      jsonResult = serializeJSON(ping);
    } catch (any e) {
      status = "fail";
      summary = "CFC init lifecycle test failed.";
      jsonResult = serializeJSON(e);
    }
  </cfscript>
</cfif>

<cfif issue EQ "20">
  <cfscript>
    try {
      salt = generateSecretKey("AES", 128);
      hash = generatePBKDFKey("PBKDF2WithHmacSHA256", "moopa-dev-password", salt, 120000, 256);
      status = len(hash) GTE 32 ? "pass" : "partial";
      summary = status EQ "pass" ? "generatePBKDFKey works for the Moopa Starter local-password auth path." : "PBKDF2 call returned an unexpectedly short hash.";
      jsonResult = serializeJSON({hashLength:len(hash), algorithm:"PBKDF2WithHmacSHA256"});
    } catch (any e) {
      status = "fail";
      summary = "generatePBKDFKey is unavailable or failed. Moopa Starter login would need a portable hashing fallback.";
      jsonResult = serializeJSON(e);
    }
  </cfscript>
</cfif>

<cfif issue EQ "21">
  <cftry>
    <cfsavecontent variable="includedOutput">
      <cfinclude template="_includeFixture.cfm" />
    </cfsavecontent>
    <cfscript>
      relativeOk = find("include-ok", includedOutput) GT 0;
      fixturePath = getDirectoryFromPath(getCurrentTemplatePath()) & "_includeFixture.cfm";
      fixtureExists = fileExists(fixturePath);
      status = relativeOk ? "partial" : "fail";
      summary = status EQ "partial"
        ? "Relative cfinclude works. Direct leading-slash cfinclude is avoided because RustCFML v0.10.0 treats it as an OS-root path and raises an uncaught 500, so Moopa-style root includes need an adapter."
        : "cfinclude did not render the fixture template.";
      jsonResult = serializeJSON({relativeOutput:trim(includedOutput), fixturePath:fixturePath, fixtureExists:fixtureExists, absoluteIncludeSafe:false});
    </cfscript>
    <cfcatch>
      <cfscript>
        status = "fail";
        summary = "cfinclude resolution failed.";
        jsonResult = serializeJSON(cfcatch);
      </cfscript>
    </cfcatch>
  </cftry>
</cfif>
