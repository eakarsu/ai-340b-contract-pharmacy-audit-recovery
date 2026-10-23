// Feature pack: search/filter, CSV/JSON export, and deterministic domain AI fallback.
// No provider calls here: fallback results are labelled aiGenerated:false.
export const FALLBACK_LABEL = "Deterministic fallback — not AI-generated";
const text = (v) => v == null ? "" : String(v);
export function filterRecords(rows, { q = "", status = "", risk = "" } = {}) {
  const needle = String(q || "").trim().toLowerCase();
  return (rows || []).filter((row) => {
    if (status && String(row.status ?? row.state ?? "") !== status) return false;
    if (risk && String(row.risk ?? "") !== risk) return false;
    if (!needle) return true;
    return JSON.stringify(row ?? {}).toLowerCase().includes(needle);
  });
}
function csvCell(value) {
  if (value === null || value === undefined) return "";
  let s = typeof value === "object" ? JSON.stringify(value) : String(value);
  if (/^[=+\-@]/.test(s)) s = "'" + s;
  return /[",\n]/.test(s) ? '"' + s.replaceAll('"', '""') + '"' : s;
}
export function toCsv(rows, columns) {
  const cols = columns && columns.length ? columns : [...new Set((rows || []).flatMap((r) => Object.keys(r || {})))];
  if (!cols.length) return "";
  return [cols.join(","), ...(rows || []).map((r) => cols.map((c) => csvCell(r?.[c])).join(","))].join("\n");
}
export function buildExport(rows, format = "json") {
  const f = String(format || "json").toLowerCase();
  if (f === "csv") return { contentType: "text/csv; charset=utf-8", body: toCsv(rows || []) };
  if (f === "json") return { contentType: "application/json; charset=utf-8", body: JSON.stringify(rows || [], null, 2) };
  throw Object.assign(new Error("Choose JSON or CSV"), { status: 422 });
}
function base(kind, headline, rows, sections, metrics) {
  return { aiGenerated: false, label: FALLBACK_LABEL, source: "deterministic-fallback", kind, headline, recordsConsidered: (rows || []).length, metrics, sections };
}
const num = (v) => { const n = Number(v); return Number.isFinite(n) ? n : 0; };
const totalAmount = (rows) => (rows || []).reduce((s, r) => s + num(r?.amount), 0);
const countBy = (rows, key) => (rows || []).reduce((m, r) => { const k = text(r?.[key] ?? r?.state) || "(empty)"; m[k] = (m[k] || 0) + 1; return m; }, {});
const attention = (rows) => (rows || []).filter((r) => ["High", "Critical"].includes(r?.risk) || ["Review", "Investigating", "review", "analyzing"].includes(r?.status ?? r?.state)).length;
const gaps = (rows) => (rows || []).filter((r) => !text(r?.owner).trim() || !(r?.due_date ?? r?.dueAt ?? r?.due_at) || !text(r?.reference ?? r?.title).trim());

export function auditTriageSummary(rows = []) {
  const byRisk = countBy(rows, "risk");
  return base("audit-triage", "340B audit triage summary (deterministic)", rows, [
    { title: "Records reviewed", detail: String(rows.length) },
    { title: "High / Critical risk", detail: String((byRisk.High || 0) + (byRisk.Critical || 0)) },
    { title: "Attention queue", detail: String(attention(rows)) },
    { title: "Review note", detail: "Operational triage only — validate against source dispense, accumulator, and encounter records. No clinical or regulatory advice." },
  ], [{ label: "Records", value: rows.length }, { label: "High risk", value: byRisk.High || 0 }, { label: "Critical risk", value: byRisk.Critical || 0 }]);
}
export function recoveryExposureSummary(rows = []) {
  return base("recovery-exposure", "340B recovery exposure summary (deterministic)", rows, [
    { title: "Records reviewed", detail: String(rows.length) },
    { title: "Total represented amount", detail: String(totalAmount(rows)) },
    { title: "By state", detail: JSON.stringify(countBy(rows, "state")) },
  ], [{ label: "Records", value: rows.length }, { label: "Total amount", value: totalAmount(rows) }]);
}
export function evidenceGapCheck(rows = []) {
  const g = gaps(rows);
  return base("evidence-gap", "340B evidence gap check (deterministic)", rows, [
    { title: "Records reviewed", detail: String(rows.length) },
    { title: "Records missing owner, due date, or reference", detail: String(g.length) },
    { title: "Gap references", detail: g.slice(0, 10).map((r) => text(r.reference ?? r.title) || "(empty)").join(", ") || "(none)" },
  ], [{ label: "Records", value: rows.length }, { label: "Gaps", value: g.length }]);
}
const AI_FALLBACKS = { "audit-triage": auditTriageSummary, "recovery-exposure": recoveryExposureSummary, "evidence-gap": evidenceGapCheck };

export const AI_FALLBACK_KINDS = Object.keys(AI_FALLBACKS);
export function runAiFallback(rows, kind) {
  const fn = AI_FALLBACKS[kind];
  if (!fn) throw Object.assign(new Error("Unknown fallback kind: " + kind), { status: 422 });
  return fn(rows || []);
}
