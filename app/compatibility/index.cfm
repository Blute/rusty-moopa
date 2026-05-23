<cfinclude template="lib.cfm" />
<cfscript>
statusLabels = {pass:"Working", partial:"Partial", manual:"Manual", fail:"Blocked", untested:"Untested"};
statusCounts = {pass:0, partial:0, manual:0, fail:0, untested:0};
groupOrder = ["fail", "partial", "manual", "pass"];
groupLabels = {
  fail:"Needs attention first",
  partial:"Working with caveats",
  manual:"Manual verification",
  pass:"Working today"
};
groupNotes = {
  fail:"These are the blockers most likely to break Moopa runtime behavior.",
  partial:"These have a route forward, but the caveat matters before calling the migration safe.",
  manual:"These need a server, rewrite, or browser-level check outside the smoke harness.",
  pass:"These patterns work in the current local container. Keep watching them on RustCFML upgrades."
};
statusByIssue = {
  "01":"pass",
  "02":"partial",
  "03":"pass",
  "04":"partial",
  "05":"pass",
  "06":"fail",
  "07":"partial",
  "08":"partial",
  "09":"partial",
  "10":"partial",
  "11":"partial",
  "12":"fail",
  "13":"pass",
  "14":"pass",
  "15":"pass",
  "16":"partial",
  "17":"partial",
  "18":"pass",
  "19":"pass",
  "20":"pass",
  "21":"partial"
};
notesByIssue = {
  "01":"Document-root mapping resolves. Moopa-specific /moopa, /apps, and /shared mappings still need bootstrap config.",
  "02":"Core custom tag rendering works, but caller write-back is not reliable. Tags that mutate caller scope need an adapter.",
  "03":"A narrow urlrewrite.xml probe forwards /rewrite-test/moopa-route to /_moopa.cfm and preserves query-string values.",
  "04":"Docker env vars are readable with getEnvironmentVariable(). Lucee's server.system.environment should not be assumed.",
  "05":"PostgreSQL connects through RUSTCFML_DSN_URL against the local seeded database.",
  "06":"cfqueryparam attributeCollection does not pass Moopa's dynamic CRUD parameter style. This blocks save/update until adapted or fixed upstream.",
  "07":"returntype=array works. Keyed struct query shapes still need a Moopa-specific fallback or upstream parity.",
  "08":"Safe row_to_json text reads work. Direct UUID and timestamptz columns have previously panicked the RustCFML driver.",
  "09":"Some Java shims exist, but RustCFML is not a JVM. Replace or isolate Java-dependent Moopa helpers.",
  "10":"A minimal cfthread join can run. Production semantics still need validation before relying on background work.",
  "11":"Session scope works in a single local process. Production needs an explicit session/state strategy.",
  "12":"CFC methods behave like classic local mode. Unscoped assignments can leak into variables scope.",
  "13":"Explicit cfqueryparam binding works and should remain a protected baseline.",
  "14":"cfqueryparam list=true works for IN filters used by searches and relationship writes.",
  "15":"ILIKE label search works against the seeded role rows.",
  "16":"Metadata query runs, but returntype=struct columnkey is not proven equivalent to Lucee.",
  "17":"JSON text reads are viable, but the parser/result shape still needs careful handling.",
  "18":"Casting UUID, timestamptz, and jsonb to text avoids driver conversion crashes.",
  "19":"createObject(component).init() returns a usable CFC instance.",
  "20":"generatePBKDFKey works for the Starter local-password login path.",
  "21":"Relative cfinclude works. Leading-slash root includes are unsafe because RustCFML treats them like OS-root paths."
};
rows = [];
for (i = 1; i <= arrayLen(issues); i++) {
  base = issues[i];
  row = duplicate(base);
  row.status = structKeyExists(statusByIssue, base.id) ? statusByIssue[base.id] : "untested";
  row.statusLabel = statusLabels[row.status];
  row.note = structKeyExists(notesByIssue, base.id) ? notesByIssue[base.id] : base.blurb;
  arrayAppend(rows, row);
  statusCounts[row.status] = statusCounts[row.status] + 1;
}
totalIssues = arrayLen(rows);
passPercent = totalIssues ? int((statusCounts.pass / totalIssues) * 100) : 0;
attentionCount = statusCounts.fail + statusCounts.partial;
</cfscript>
<!doctype html>
<html>
<head>
  <title>Moopa RustCFML compatibility</title>
  <style>
    :root{
      color-scheme:light;
      --paper:oklch(97.7% .010 82);
      --surface:oklch(99.1% .006 82);
      --surface-2:oklch(95.2% .014 82);
      --ink:oklch(21% .022 248);
      --muted:oklch(47% .026 248);
      --line:oklch(86.5% .015 82);
      --accent:oklch(45% .105 166);
      --accent-soft:oklch(91% .050 166);
      --good:oklch(44% .115 158);
      --good-soft:oklch(92% .048 158);
      --warn:oklch(54% .118 72);
      --warn-soft:oklch(92% .062 72);
      --bad:oklch(48% .155 31);
      --bad-soft:oklch(92% .050 31);
      --info:oklch(47% .105 265);
      --info-soft:oklch(92% .044 265);
      --radius:16px;
      --shadow:0 18px 45px oklch(38% .025 248 / .09);
    }
    *{box-sizing:border-box}
    body{margin:0;background:var(--paper);color:var(--ink);font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif;font-size:15px;line-height:1.5}
    a{color:var(--accent);font-weight:750;text-decoration:none}a:hover{text-decoration:underline}
    .shell{max-width:1180px;margin:0 auto;padding:34px 20px 56px}
    .topbar{display:flex;align-items:center;justify-content:space-between;gap:1rem;margin-bottom:26px}
    .crumb{font-size:.78rem;font-weight:850;letter-spacing:.08em;text-transform:uppercase;color:var(--muted)}
    .top-actions{display:flex;gap:.55rem;flex-wrap:wrap}.button{display:inline-flex;align-items:center;gap:.35rem;border:1px solid var(--line);border-radius:999px;background:var(--surface);color:var(--ink);padding:.48rem .72rem;font-size:.88rem;font-weight:800;box-shadow:0 1px 0 oklch(100% 0 0 / .65)}.button.primary{background:var(--accent);border-color:var(--accent);color:oklch(98% .006 166)}
    .hero{display:grid;grid-template-columns:minmax(0,1.2fr) minmax(280px,.8fr);gap:24px;align-items:end;margin-bottom:24px}
    h1{font-size:2.15rem;line-height:1.05;letter-spacing:-.045em;margin:.35rem 0 .75rem}.lede{max-width:72ch;color:var(--muted);font-size:1rem;margin:0}.truth{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:18px;box-shadow:var(--shadow)}
    .truth strong{display:block;font-size:.82rem;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin-bottom:.45rem}.truth p{margin:0;color:var(--ink);font-weight:650}.truth .bad{color:var(--bad)}.truth .warn{color:var(--warn)}.truth .good{color:var(--good)}
    .overview{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:16px 18px 18px;margin-bottom:22px;box-shadow:var(--shadow)}
    .overview-head{display:flex;align-items:center;justify-content:space-between;gap:1rem;margin-bottom:12px}.overview-title{font-weight:900}.overview-note{color:var(--muted);font-size:.88rem}.bar{display:flex;height:12px;overflow:hidden;border-radius:999px;background:var(--surface-2);border:1px solid var(--line)}.seg.pass{background:var(--good)}.seg.partial{background:var(--warn)}.seg.manual{background:var(--info)}.seg.fail{background:var(--bad)}
    .chips{display:flex;gap:.55rem;flex-wrap:wrap;margin-top:12px}.chip{display:inline-flex;align-items:center;gap:.45rem;border:1px solid var(--line);border-radius:999px;background:var(--surface);padding:.38rem .62rem;font-weight:800;font-size:.86rem}.dot{width:.58rem;height:.58rem;border-radius:999px;background:var(--muted)}.dot.pass{background:var(--good)}.dot.partial{background:var(--warn)}.dot.manual{background:var(--info)}.dot.fail{background:var(--bad)}
    .callout{margin:0 0 26px;padding:12px 14px;border:1px solid oklch(83% .080 72);border-radius:14px;background:var(--warn-soft);color:oklch(36% .080 72);font-weight:650}.callout code{font-weight:850}
    .section{margin-top:28px}.section h2{font-size:1.05rem;margin:0 0 8px;letter-spacing:-.015em}.section-note{color:var(--muted);margin:0 0 12px;font-size:.92rem}.list{border:1px solid var(--line);border-radius:var(--radius);overflow:hidden;background:var(--surface);box-shadow:var(--shadow)}
    .row{display:grid;grid-template-columns:96px minmax(180px,.9fr) minmax(0,1.35fr) 176px;gap:16px;align-items:start;padding:14px 16px;border-top:1px solid var(--line)}.row:first-child{border-top:0}.row:hover{background:oklch(97.4% .012 82)}
    .idline{display:flex;align-items:center;gap:.45rem;white-space:nowrap}.num{font-variant-numeric:tabular-nums;font-weight:900;color:var(--muted)}.tier{font-size:.72rem;text-transform:uppercase;letter-spacing:.07em;border:1px solid var(--line);border-radius:999px;padding:.12rem .35rem;color:var(--muted);font-weight:850}
    .title{font-weight:900;color:var(--ink);margin-bottom:.18rem}.blurb,.summary{color:var(--muted);margin:0}.summary{font-size:.91rem}.status{display:inline-flex;align-items:center;justify-content:center;border-radius:999px;padding:.28rem .54rem;font-size:.78rem;font-weight:900;text-transform:uppercase;letter-spacing:.035em;border:1px solid transparent;white-space:nowrap}.status.pass{background:var(--good-soft);color:var(--good);border-color:oklch(82% .070 158)}.status.partial{background:var(--warn-soft);color:var(--warn);border-color:oklch(83% .080 72)}.status.manual{background:var(--info-soft);color:var(--info);border-color:oklch(83% .060 265)}.status.fail{background:var(--bad-soft);color:var(--bad);border-color:oklch(83% .070 31)}.status.untested{background:var(--surface-2);color:var(--muted);border-color:var(--line)}
    .actions{display:flex;gap:.45rem;justify-content:flex-end;flex-wrap:wrap}.link-pill{border:1px solid var(--line);border-radius:999px;padding:.32rem .52rem;font-size:.82rem;font-weight:850;background:var(--surface)}
    @media(max-width:900px){.hero{grid-template-columns:1fr}.row{grid-template-columns:1fr;gap:8px}.actions{justify-content:flex-start}.topbar,.overview-head{align-items:flex-start;flex-direction:column}}
  </style>
</head>
<body>
  <main class="shell">
    <div class="topbar">
      <div class="crumb">Rusty compatibility harness</div>
      <div class="top-actions">
        <a class="button primary" href="index.cfm">Refresh matrix</a>
      </div>
    </div>

    <section class="hero">
      <div>
        <h1>Moopa on RustCFML, current truth</h1>
        <p class="lede">A migration dashboard sorted by action needed. Start with blockers, scan caveats, then use the green rows as regression checks when RustCFML changes.</p>
      </div>
      <div class="truth">
        <strong>At a glance</strong>
        <p><cfoutput><span class="bad">#statusCounts.fail# blocked</span>, <span class="warn">#statusCounts.partial# partial</span>, #statusCounts.manual# manual, and <span class="good">#statusCounts.pass# working</span> out of #totalIssues# checks.</cfoutput></p>
      </div>
    </section>

    <section class="overview" aria-label="Suite summary">
      <div class="overview-head">
        <div class="overview-title"><cfoutput>#attentionCount# checks need migration work</cfoutput></div>
        <div class="overview-note"><cfoutput>#passPercent#% are fully green in the latest local baseline.</cfoutput></div>
      </div>
      <div class="bar" aria-hidden="true">
        <cfoutput>
          <span class="seg fail" style="width:#totalIssues ? (statusCounts.fail / totalIssues) * 100 : 0#%"></span>
          <span class="seg partial" style="width:#totalIssues ? (statusCounts.partial / totalIssues) * 100 : 0#%"></span>
          <span class="seg manual" style="width:#totalIssues ? (statusCounts.manual / totalIssues) * 100 : 0#%"></span>
          <span class="seg pass" style="width:#totalIssues ? (statusCounts.pass / totalIssues) * 100 : 0#%"></span>
        </cfoutput>
      </div>
      <div class="chips">
        <cfoutput>
          <span class="chip"><span class="dot fail"></span>#statusCounts.fail# blocked</span>
          <span class="chip"><span class="dot partial"></span>#statusCounts.partial# partial</span>
          <span class="chip"><span class="dot manual"></span>#statusCounts.manual# manual</span>
          <span class="chip"><span class="dot pass"></span>#statusCounts.pass# working</span>
        </cfoutput>
      </div>
    </section>

    <p class="callout">Note: this summary uses the latest known local baseline. The <code>Details</code> link runs the individual smoke test. Running all tests inside one request is avoided because RustCFML currently reuses included template state in a way that can report false greens.</p>

    <cfloop from="1" to="#arrayLen(groupOrder)#" index="groupIndex">
      <cfset groupStatus = groupOrder[groupIndex] />
      <cfif statusCounts[groupStatus] GT 0>
        <section class="section">
          <h2><cfoutput>#groupLabels[groupStatus]#</cfoutput></h2>
          <p class="section-note"><cfoutput>#groupNotes[groupStatus]#</cfoutput></p>
          <div class="list">
            <cfloop from="1" to="#arrayLen(rows)#" index="resultIndex">
              <cfset item = rows[resultIndex] />
              <cfif item.status EQ groupStatus>
                <div class="row">
                  <div class="idline">
                    <span class="num"><cfoutput>#item.id#</cfoutput></span>
                    <span class="tier"><cfoutput>#item.tier#</cfoutput></span>
                  </div>
                  <div>
                    <div class="title"><cfoutput>#item.title#</cfoutput></div>
                    <p class="blurb"><cfoutput>#item.blurb#</cfoutput></p>
                  </div>
                  <p class="summary"><cfoutput>#item.note#</cfoutput></p>
                  <div class="actions">
                    <span class="status <cfoutput>#item.status#</cfoutput>"><cfoutput>#item.statusLabel#</cfoutput></span>
                    <a class="link-pill" href="explain.cfm?issue=<cfoutput>#item.id#</cfoutput>&run=1">Details</a>
                  </div>
                </div>
              </cfif>
            </cfloop>
          </div>
        </section>
      </cfif>
    </cfloop>
  </main>
</body>
</html>
