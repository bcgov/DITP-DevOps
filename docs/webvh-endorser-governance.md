# WebVH Witness Governance

This document defines governance for the **witness** used by WebVH issuers in the BC Government (provincial and municipal) digital trust ecosystem. It covers witnessing, allow lists (pre-approved DIDs/namespaces), and the approval process. Indy endorsement governance is out of scope and is defined elsewhere.

**Scope:** BC Gov only (provincial and municipal). Same audience as the [WebVH Issuer Onboarding Roadmap](./webvh-issuer-onboarding-roadmap.md).

**Relationship:** Issuers must complete the [onboarding roadmap](./webvh-issuer-onboarding-roadmap.md) and obtain governance approval (this document) before using the shared witness. Where applicable, DITP operations follow principles from the BCVH Governance Framework (Witness, Controller roles).

---

## 1. Roles and responsibilities

| Role | Who | Responsibility |
|------|-----|----------------|
| **Witness operator** | DITP | Operates the shared WebVH witness; maintains the witness allow list (pre-approved DIDs/namespaces); ensures availability and security of the service. |
| **Issuer** | BC Gov program (provincial or municipal) | Controller that requests witness attestation for WebVH transactions. Must be onboarded per the [WebVH Issuer Onboarding Roadmap](./webvh-issuer-onboarding-roadmap.md) and approved under this governance. |
| **Approver** | DITP (or delegated program office) | Reviews and approves or rejects witness requests. Maintains allow list entries per policy. |

DITP does not perform development work on behalf of issuers; issuers own their controller and integrations.

---

## 2. Witnessing

The **witness** attests to WebVH transactions (DID creation, schema and credential definition publication, etc.) so that those transactions are anchored in the verifiable history.

### 2.1 What the witness attests

- Controller (issuer) DID registration and updates.
- Publication of schemas, credential definitions, and revocation registries to the WebVH server.
- Other WebVH resource updates as defined by the WebVH protocol.

### 2.2 Who may request witnessing

- Only **onboarded issuers** that have completed the [WebVH Issuer Onboarding Roadmap](./webvh-issuer-onboarding-roadmap.md) and have been approved for use of the shared witness.
- The witness operator may maintain a **pre-approved list** of DIDs or namespaces (e.g. per issuer or per Traction tenant) that are allowed to submit witness requests. Requests from identities not on that list may be rejected or held for manual review.

### 2.3 Approval criteria for witness requests

A witness request may be approved when:

- The requesting identity (DID/namespace) is approved for witnessing (on allow list or otherwise pre-approved).
- The request matches the issuer’s approved scope (e.g. namespace, credential types) as established during onboarding.
- There are no policy or security concerns (e.g. duplicate or conflicting registration, abuse).

Otherwise the request is rejected or escalated for manual decision.

### 2.4 Process for approve/reject

- **Automated:** If the request matches allow list / pre-approved rules, the service may auto-approve (when so configured).
- **Manual:** Requests that do not match auto-approval rules are presented to the **approver** (e.g. via admin dashboard or operational tooling). The approver approves or rejects; rejections should be documented (reason, date).
- Issuers are notified of the outcome (success or rejection) through the normal WebVH flow (e.g. API response, webhook, or dashboard).

---

## 3. Allow list policy (witness)

### 3.1 Ownership and maintenance

- The **witness allow list** (pre-approved DIDs or namespaces for witness requests) is **owned and maintained by DITP** (or a delegated program office). Only authorized operators/approvers may add, change, or remove entries.
- Changes follow change control: add/remove is documented (who, when, rationale) and, where required, reviewed before or after apply.

### 3.2 Adding and removing entries

- **Add:** An entry is added only after the issuer is approved for the corresponding scope (onboarding and governance approval). Requests for new entries may come from the program or the issuer; DITP (or delegate) validates and applies.
- **Remove:** An entry is removed when the issuer is offboarded, when scope is reduced, or when a policy violation or risk is identified. Removal is documented and, if needed, the issuer’s witness access is suspended.
- **Wildcards / patterns:** Use of `*` or pattern-based entries (e.g. namespace prefix) is permitted only where explicitly allowed by policy; over-broad patterns are avoided to limit unintended auto-approval.

### 3.3 Review and audit

- The witness allow list is **reviewed periodically** (e.g. quarterly) to ensure entries still match current onboarding and program scope.
- An **audit trail** of allow list changes (and of manual approve/reject decisions, where feasible) is retained for compliance and incident review.

---

## 4. Approval process

### 4.1 Onboarding an issuer

1. Issuer completes the [WebVH Issuer Onboarding Roadmap](./webvh-issuer-onboarding-roadmap.md) (prerequisites, infrastructure, integration).
2. Governance approval is confirmed per this document (readiness to use the witness, scope of DIDs/namespaces and credential types).
3. DITP (or delegate) adds the issuer’s DID(s) or namespace(s) to the witness pre-approved list (when used), so that witness requests from that issuer are eligible for auto-approval or manual review per policy.

### 4.2 Submitting and approving witness requests

- **Submission:** The issuer’s agent (controller) submits witness requests through the normal WebVH witness flow.
- **Routing:** Requests either match the allow list / auto-approval rules (and are processed automatically) or are queued for **manual approval**.
- **Approval:** An authorized approver reviews pending requests (e.g. via admin dashboard or operational tooling), approves or rejects, and documents rejections.
- **Outcome:** The issuer’s agent receives the outcome; approved transactions are witnessed; rejected requests are not.

### 4.3 Timeframes and escalation

- **Target:** Manual approval is completed within **five business days** where possible; critical path or incident-driven requests may be prioritized. (Specific SLAs may be set by the program and updated here.)
- **Escalation:** Disputes or blocked requests are escalated to the DITP program office (or designated governance lead) for resolution. Repeated rejections or policy questions are documented and resolved per program process.

---

## 5. Offboarding and exceptions

### 5.1 Suspending or revoking witness access

- **Suspension:** The issuer’s DID(s) or namespace(s) are removed from the witness pre-approved list (or otherwise marked suspended). No new witness requests from that issuer are processed until access is restored.
- **Revocation / offboarding:** When an issuer exits the program or is revoked, their entries are removed from the witness allow list. Historical attested data remains in the verifiable history per retention policy.

### 5.2 Policy exceptions

- Requests for **exceptions** to this governance (e.g. temporary broader auto-approval, extended scope) must be submitted in writing to the DITP program office, with rationale, scope, and sunset date.
- Approved exceptions are logged and reviewed on a defined cadence (e.g. quarterly); they are removed or renewed per program decision.

### 5.3 Incidents

- Security or availability incidents affecting the witness follow DITP incident response and communication practices (e.g. [Aries Endorser Service Uptime Alert Workflow](./aries-endorser-service-alert-workflow.md)). Post-incident review may lead to temporary suspension of issuers or tightening of the allow list or approval policy.

---

## 6. Appendices

### 6.1 References

- [WebVH Issuer Onboarding Roadmap](./webvh-issuer-onboarding-roadmap.md)
- [Aries Endorser Service Uptime Alert Workflow](./aries-endorser-service-alert-workflow.md)
- BCVH Governance Framework (Witness, Controller roles) — where applicable for provincial WebVH operations

### 6.2 Related issues

- [DITP-DevOps #277](https://github.com/bcgov/DITP-DevOps/issues/277) — Review witness governance for WebVH issuers  
- [DITP-DevOps #275](https://github.com/bcgov/DITP-DevOps/issues/275) — Create onboarding roadmap for WebVH Issuers
