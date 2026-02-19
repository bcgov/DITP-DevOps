# WebVH Issuer Onboarding Roadmap

This roadmap describes how BC Government issuers (provincial and municipal) onboard to **did:webvh** for AnonCreds issuance. It covers both **new issuers** (no existing Indy footprint) and **existing Indy issuers** migrating to did:webvh.

**Who owns what:**

- **DITP** — Owns and operates the **ACA-Py issuer agent**. Provides shared WebVH infrastructure (server and witness), integration support, and DevOps; **does not** perform development work on the issuer’s behalf.
- **Issuer** — Owns and operates only the **controller** (and any integrations). Uses the controller to drive DIDs, schemas, credential definitions, and issuance against the DITP-owned agent.

**Target state:** Issuers are encouraged to migrate **from** a single ACA-Py instance **toward** a **Traction tenant** (Traction uses ACA-Py). In that model, DITP operates the agent; the issuer operates their controller and uses the tenant for all issuance.

**Two paths:**

- **Path A: New issuer** — No Indy; onboarding from scratch to did:webvh.
- **Path B: Indy migrant** — Already issuing on Indy; adding did:webvh (dual issuance) then optionally moving to did:webvh-only.

Multiple issuers can be onboarded in parallel; timelines below are indicative and may be adjusted (TBD).

---

## Prerequisites

Before starting onboarding, ensure:

1. **AIPv2 / askar-anoncreds** — Your issuer agent must be on (or moving to) the `askar-anoncreds` wallet type and AIPv2. If you are still on legacy Indy/askar, complete the controller migration first. See [Upgrading to AIPv2](https://github.com/openwallet-foundation/acapy/blob/main/docs/features/upgradingToAipv2.md).
2. **Governance approval** — Readiness and approval to use WebVH must be confirmed per BC Gov / DITP governance. *(Governance document to be linked here when available.)*
3. **Intake (TBD)** — Formal DITP intake or ticket process may apply before infrastructure work; confirm with DITP.

---

## Stage 0: Pre-requisites and governance

| Owner   | Actions |
|---------|--------|
| Issuer  | Confirm AIPv2/askar-anoncreds readiness; complete any governance checklist; scope namespace/identifier and credential types for did:webvh. |
| DITP    | Confirm governance/approval status; answer intake questions if applicable. |

**Typical duration:** 2–4 weeks (depends on governance and AIPv2 readiness).

**Outcome:** Issuer is approved to proceed; DITP has scope (namespace, identifiers, environments).

---

## Stage 1: Environment and infrastructure

WebVH server and witness are **always DITP-provisioned shared/platform** (no issuer-dedicated instances). DITP stands up or confirms access to:

- Shared **did:webvh** server (e.g. [didwebvh-server-py](https://github.com/decentralized-identity/didwebvh-server-py)).
- **Witness** service for attesting DID and resource publications.
- Networking and namespaces as needed.

**Environments:**

- **DITP-managed Dev/Test/Prod** — Issuer uses DITP-provided environments; DITP provisions tenant/namespace and connectivity.
- **Issuer’s own infra** — Issuer may run their own environments (e.g. their own OCP/Kubernetes) and **own only their controller**. The goal is to onboard them as **Traction tenants** (single ACA-Py instance per tenant, operated by DITP); the issuer migrates toward using that tenant and continues to own and operate only the controller. DITP provides integration support and access to the shared WebVH server and witness.

| Owner | Actions |
|-------|--------|
| DITP  | Provision or confirm shared WebVH server and witness; provide issuer with server URL, witness config/invitation, and any tenant/namespace details. |
| Issuer | Confirm connectivity from the DITP-owned agent (or Traction tenant) to the WebVH server; obtain credentials/configuration needed for Stage 2. |

**Typical duration:** 2–4 weeks.

**References:** See existing DITP/DevOps docs for rollout and environment practices (e.g. [Performing a Rollout](./performing-a-rollout.md)).

---

## Stage 2: Issuer integration

**DITP** owns and operates the ACA-Py issuer agent (or the Traction tenant’s ACA-Py); the **issuer** owns and operates only the **controller**. The WebVH plugin is enabled on the agent; the issuer uses the controller to drive DID creation, schema/cred def registration, and issuance. **DITP** provides **integration support only** (no development work).

**Steps (with DITP support):**

1. **DITP** ensures the **WebVH plugin** is installed and enabled on the ACA-Py agent (or Traction tenant instance). See [WebVH plugin README](https://github.com/openwallet-foundation/acapy-plugins/tree/main/webvh).
2. **Witness** is configured (self-witnessing or connection to the DITP-provisioned witness; invitation/URL from Stage 1).
3. **Issuer** uses the **controller** to **create a did:webvh DID** (namespace/identifier as scoped in Stage 0).
4. **Issuer** uses the controller to **register schemas and credential definitions** under that DID on the WebVH server (same AnonCreds API; different `issuerId`).
5. **Issuer** issues a **first test credential** via the controller and verifies resolution/verification.

**Indy migrants:** Existing Indy issuance can stay unchanged; this stage adds did:webvh alongside it. Re-register only the schemas/cred defs you want to use for did:webvh (same attribute definitions, new DID).

| Owner | Actions |
|-------|--------|
| Issuer | Use the controller to create DID, register schema/cred def, issue test credential; own controller configuration and operations. |
| DITP  | Operate the agent (ACA-Py); ensure WebVH plugin and witness config; integration support: answer config questions, troubleshoot connectivity and WebVH server access; no custom development. |

**Typical duration:** 2–4 weeks.

**Reference:** [Migrating AnonCreds from Indy to did:webvh](https://github.com/openwallet-foundation/acapy/blob/main/docs/deploying/IndyToWebVHMigration.md) (acapy repo).

---

## Stage 3: Dual issuance (Path B — Indy migrants only)

Only for **Path B** (existing Indy issuers). Run Indy and did:webvh issuance in parallel.

**Steps:**

1. Continue issuing **Indy** credentials for existing holders and verifiers that are not yet did:webvh-ready.
2. Issue **did:webvh** credentials for new use cases or new holders/verifiers that support did:webvh resolution.
3. **Communicate** with your verifier ecosystem so they can add did:webvh resolution where needed.
4. Plan the timing for eventually stopping new Indy issuance (optional; legacy Indy credentials remain valid).

| Owner | Actions |
|-------|--------|
| Issuer | Run dual issuance; coordinate with verifiers; decide when to stop new Indy issuance (if at all). |
| DITP  | Support integration and operations; no development. |

**Typical duration:** 4–12 weeks (variable; depends on verifier readiness and policy).

---

## Stage 4: Production and cutover

**Go-live for did:webvh issuance:**

1. Confirm **production** WebVH server URL and witness configuration.
2. Confirm **monitoring and alerting** — WebVH issuer components are added to monitoring per DITP standards. See existing DITP alert and runbook docs, for example:
   - [Aries Endorser Service Uptime Alert Workflow](./aries-endorser-service-alert-workflow.md)
   - [Aries Mediator Service Uptime Alert Workflow](./aries-mediator-service-alert-workflow.md)
3. Execute go-live (deploy/switch to production config); verify first production credentials.
4. **Rollback plan** — Know how to revert controller or agent config or pause did:webvh issuance if needed (DITP for agent; issuer for controller).
5. **Indy migrants (optional):** When ready, stop new Indy issuance; existing Indy credentials remain valid and verifiable.

| Owner | Actions |
|-------|--------|
| Issuer | Cut over to production; validate issuance and verification; follow rollback plan if needed. |
| DITP  | Ensure production WebVH/witness and monitoring are in place; support during cutover. |

**Typical duration:** 1–2 weeks.

---

## Stage 5: Steady state

- **BAU** — Issuer operates the controller; DITP operates the ACA-Py agent (or Traction tenant) and shared WebVH server and witness.
- **Compliance and upgrades** — Apply policy and upgrade cycles (ACA-Py, plugin, DITP platform) as per BC Gov and DITP standards.
- **Support** — DITP provides integration and infra support; issuer owns application and credential lifecycle.

---

## Timelines summary

| Path | Stages | Typical end-to-end |
|------|--------|---------------------|
| **Path A: New issuer** | 0 → 1 → 2 → 4 → 5 | ~8–14 weeks |
| **Path B: Indy migrant** | 0 → 1 → 2 → 3 → 4 → 5 | ~12–26 weeks (includes dual issuance) |

*Durations are indicative; multiple issuers can be onboarded in parallel. Specific targets TBD.*

---

## Appendices

### Links

- [ACA-Py — Upgrading to AIPv2](https://github.com/openwallet-foundation/acapy/blob/main/docs/features/upgradingToAipv2.md)
- [ACA-Py — Migrating AnonCreds from Indy to did:webvh](https://github.com/openwallet-foundation/acapy/blob/main/docs/deploying/IndyToWebVHMigration.md)
- [did:webvh specification](https://identity.foundation/didwebvh/)
- [didwebvh-server-py](https://github.com/decentralized-identity/didwebvh-server-py)
- [WebVH plugin (acapy-plugins)](https://github.com/openwallet-foundation/acapy-plugins/tree/main/webvh)
- **Governance doc** — *(to be linked when available)*
- DITP DevOps: [Performing a Rollout](./performing-a-rollout.md), [Aries Endorser Service Alert Workflow](./aries-endorser-service-alert-workflow.md), [Aries Mediator Service Alert Workflow](./aries-mediator-service-alert-workflow.md)

### Related

- [DITP-DevOps #275](https://github.com/bcgov/DITP-DevOps/issues/275) — Create onboarding roadmap for WebVH Issuers  
- [acapy #3885](https://github.com/openwallet-foundation/acapy/issues/3885) — Indy → WebVH migration
