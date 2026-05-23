<cfscript>
issue = url.issue ?: "01";
</cfscript>
<cfinclude template="run.cfm" />
<!doctype html>
<html>
<head>
  <title><cfoutput>#title#</cfoutput></title>
  <style>
    body{font-family:system-ui,sans-serif;max-width:980px;margin:3rem auto;padding:0 1rem;line-height:1.5;background:#faf7f0;color:#172033}
    a{color:#0f6849;font-weight:800}.actions{display:flex;gap:.5rem;flex-wrap:wrap;margin:1rem 0}
    a.button{display:inline-flex;border-radius:999px;padding:.45rem .7rem;text-decoration:none;font-weight:800;background:#e8f5ef;color:#0f6849;border:1px solid #bfe5d4}
    a.button.secondary{background:#f3eefc;color:#593089;border-color:#decdf6}
    .panel{background:#fffdfa;border:1px solid #ded7c9;border-radius:1.25rem;padding:1rem;margin:1rem 0;box-shadow:0 14px 34px rgba(20,30,50,.07)}
    .status{display:inline-flex;border-radius:999px;padding:.35rem .65rem;font-weight:900;text-transform:uppercase}.pass{background:#dff7eb;color:#0f6849}.partial,.manual,.untested{background:#fff0c8;color:#805400}.fail{background:#ffe1df;color:#9d2520}
    pre{overflow:auto;background:#172033;color:#f8f3e8;padding:1rem;border-radius:.8rem}
  </style>
</head>
<body>
  <div class="actions">
    <a class="button secondary" href="index.cfm">← Compatibility tests</a>
    <a class="button secondary" href="explain.cfm?issue=<cfoutput>#issue#</cfoutput>">Explanation</a>
    <a class="button" href="test.cfm?issue=<cfoutput>#issue#</cfoutput>">Run again</a>
  </div>
  <h1><cfoutput>#title#</cfoutput></h1>
  <cfinclude template="result.cfm" />
</body>
</html>
