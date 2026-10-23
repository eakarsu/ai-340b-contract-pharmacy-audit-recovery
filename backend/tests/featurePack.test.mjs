import test from "node:test";
import assert from "node:assert/strict";
import { filterRecords, toCsv, buildExport, runAiFallback, AI_FALLBACK_KINDS } from "../featurePack.mjs";
const rows = [
  { reference: "A-1", title: "Alpha review", status: "Open", state: "intake", risk: "High", amount: 0, owner: "", active: false, note: "" },
  { reference: "B-2", title: "Beta check", status: "Closed", state: "closed", risk: "Low", amount: 25, owner: "Sam", due_date: "2026-01-01" },
];
test("search/filter matches q, status and risk", () => {
  assert.equal(filterRecords(rows, { q: "alpha" }).length, 1);
  assert.equal(filterRecords(rows, { status: "Closed" }).length, 1);
  assert.equal(filterRecords(rows, { risk: "High" })[0].reference, "A-1");
  assert.equal(filterRecords(rows, { q: "missing" }).length, 0);
});
test("CSV/JSON export preserves false, 0 and empty", () => {
  const csv = toCsv(rows);
  assert.ok(csv.includes("false")); assert.ok(csv.split("\n")[1].includes(",0,"));
  assert.equal(JSON.parse(buildExport(rows, "json").body)[0].active, false);
  assert.equal(JSON.parse(buildExport(rows, "json").body)[0].amount, 0);
  assert.throws(() => buildExport(rows, "xml"), /JSON or CSV/);
});
test("deterministic AI fallback is labelled aiGenerated:false with sections", () => {
  assert.ok(AI_FALLBACK_KINDS.length >= 3);
  for (const kind of AI_FALLBACK_KINDS) {
    const r = runAiFallback(rows, kind);
    assert.equal(r.aiGenerated, false); assert.match(r.label, /not AI-generated/i);
    assert.ok(r.sections.length >= 2); assert.equal(r.recordsConsidered, 2);
  }
  assert.equal(runAiFallback([], AI_FALLBACK_KINDS[0]).recordsConsidered, 0);
  assert.throws(() => runAiFallback(rows, "nope"), /Unknown fallback/);
});
