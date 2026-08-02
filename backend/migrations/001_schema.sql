CREATE TABLE IF NOT EXISTS app_users(
  id BIGSERIAL PRIMARY KEY,email TEXT UNIQUE NOT NULL,name TEXT NOT NULL,role TEXT NOT NULL,password_hash TEXT NOT NULL,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS workflow_cases(
  id BIGSERIAL PRIMARY KEY,workflow_id TEXT NOT NULL,reference TEXT UNIQUE NOT NULL,subject TEXT NOT NULL,owner TEXT NOT NULL,state TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,payload JSONB NOT NULL DEFAULT '{}'::jsonb,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS audit_events(
  id BIGSERIAL PRIMARY KEY,event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),actor TEXT NOT NULL,action TEXT NOT NULL,object_type TEXT NOT NULL,object_reference TEXT NOT NULL,detail TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS saved_analyses(
  id BIGSERIAL PRIMARY KEY,workflow_id TEXT NOT NULL,actor TEXT NOT NULL,analysis_type TEXT NOT NULL,inputs JSONB NOT NULL,result JSONB NOT NULL,provider TEXT NOT NULL,model TEXT,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS integration_state(
  id TEXT PRIMARY KEY,name TEXT NOT NULL,category TEXT NOT NULL,mode TEXT NOT NULL,status TEXT NOT NULL,last_tested TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_workflow_cases_workflow ON workflow_cases(workflow_id);
CREATE INDEX IF NOT EXISTS idx_workflow_cases_due ON workflow_cases(due_date);
CREATE INDEX IF NOT EXISTS idx_audit_events_time ON audit_events(event_time DESC);

CREATE TABLE IF NOT EXISTS "op_eligibility"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_coveredEntity" TEXT NOT NULL,
  "data_patientId" TEXT NOT NULL,
  "data_encounterDate" DATE NOT NULL,
  "data_eligibilityBasis" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_eligibility_due ON "op_eligibility"(due_date);

CREATE TABLE IF NOT EXISTS "op_dispense_reconcile"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_pharmacy" TEXT NOT NULL,
  "data_ndc" TEXT NOT NULL,
  "data_dispenseQuantity" NUMERIC(16,2) NOT NULL,
  "data_purchaseOrder" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_dispense_reconcile_due ON "op_dispense_reconcile"(due_date);

CREATE TABLE IF NOT EXISTS "op_duplicate_discount"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_claimReference" TEXT NOT NULL,
  "data_payerType" TEXT NOT NULL,
  "data_state" TEXT NOT NULL,
  "data_carveStatus" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_duplicate_discount_due ON "op_duplicate_discount"(due_date);

CREATE TABLE IF NOT EXISTS "op_diversion"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_dispenseId" TEXT NOT NULL,
  "data_riskSignal" TEXT NOT NULL,
  "data_riskLevel" TEXT NOT NULL,
  "data_reviewNotes" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_diversion_due ON "op_diversion"(due_date);

CREATE TABLE IF NOT EXISTS "op_manufacturer_dispute"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_manufacturer" TEXT NOT NULL,
  "data_drug" TEXT NOT NULL,
  "data_disputedAmount" NUMERIC(16,2) NOT NULL,
  "data_disputeNarrative" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_manufacturer_dispute_due ON "op_manufacturer_dispute"(due_date);

CREATE TABLE IF NOT EXISTS "op_independent_audit"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_auditPeriod" TEXT NOT NULL,
  "data_pharmacyCount" NUMERIC(16,2) NOT NULL,
  "data_scope" TEXT NOT NULL,
  "data_leadAuditor" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_independent_audit_due ON "op_independent_audit"(due_date);

CREATE TABLE IF NOT EXISTS "op_savings"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_period" TEXT NOT NULL,
  "data_claimPopulation" NUMERIC(16,2) NOT NULL,
  "data_estimatedValue" NUMERIC(16,2) NOT NULL,
  "data_assumptions" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_savings_due ON "op_savings"(due_date);

CREATE TABLE IF NOT EXISTS "op_corrective_action"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_finding" TEXT NOT NULL,
  "data_rootCause" TEXT NOT NULL,
  "data_owner" TEXT NOT NULL,
  "data_targetDate" DATE NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_corrective_action_due ON "op_corrective_action"(due_date);

CREATE TABLE IF NOT EXISTS "op_covered_entities"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_entityId" TEXT NOT NULL,
  "data_entityType" TEXT NOT NULL,
  "data_parentOrganization" TEXT NOT NULL,
  "data_recertificationDate" DATE NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_covered_entities_due ON "op_covered_entities"(due_date);

CREATE TABLE IF NOT EXISTS "op_pharmacy_network"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_pharmacy" TEXT NOT NULL,
  "data_npi" TEXT NOT NULL,
  "data_tpa" TEXT NOT NULL,
  "data_contractStatus" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_pharmacy_network_due ON "op_pharmacy_network"(due_date);

CREATE TABLE IF NOT EXISTS "op_medicaid_matrix"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_state" TEXT NOT NULL,
  "data_billingNpi" TEXT NOT NULL,
  "data_carveStatus" TEXT NOT NULL,
  "data_effectiveDate" DATE NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_medicaid_matrix_due ON "op_medicaid_matrix"(due_date);

CREATE TABLE IF NOT EXISTS "op_manufacturer_policies"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_manufacturer" TEXT NOT NULL,
  "data_restriction" TEXT NOT NULL,
  "data_effectiveDate" DATE NOT NULL,
  "data_responseStrategy" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_manufacturer_policies_due ON "op_manufacturer_policies"(due_date);
