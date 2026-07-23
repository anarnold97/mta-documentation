#!/usr/bin/env bash
set -euo pipefail

TOPIC_DIR="docs/topics/developer-lightspeed"

# ── 1. Remove the old combined procedure file ─────────────────────────────────
rm -f "${TOPIC_DIR}/proc_reenable-llm-proxy.adoc"

# ── 2. Create the new assembly ────────────────────────────────────────────────
cat > "${TOPIC_DIR}/assembly_reenable-llm-proxy-after-incident.adoc" << 'EOF'
// Assembly included in the following assemblies:
//
// * docs/developer-lightspeed-guide/master.adoc

:_mod-docs-content-type: ASSEMBLY
[id="reenable-llm-proxy_{context}"]
= Re-enable the LLM proxy after an incident

[role="_abstract"]
Re-enable the proxy only after your security team confirms that the incident is resolved and the environment is safe.

include::proc_reenable-proxy-using-web-console.adoc[leveloffset=+1]

include::proc_reenable-proxy-using-cli.adoc[leveloffset=+1]
EOF

# ── 3. Create the web console procedure module ────────────────────────────────
cat > "${TOPIC_DIR}/proc_reenable-proxy-using-web-console.adoc" << 'EOF'
// Module included in the following assemblies:
//
// * docs/developer-lightspeed-guide/assembly_reenable-llm-proxy-after-incident.adoc

:_mod-docs-content-type: PROCEDURE
[id="reenable-proxy-using-web-console_{context}"]
= Re-enable the proxy by using the {ocp-short} web console

[role="_abstract"]
You can re-enable the LLM proxy by using the {ocp-short} web console to restore functionality.

.Procedure

. Click *Operators* > *Installed Operators*.
. Click the *Tackle* instance.
. Click *Actions* > *Edit Tackle*.
. Set the `kai_llm_proxy_enabled` field to `true`:
+
[source,yaml]
----
spec:
  kai_llm_proxy_enabled: true
----
. Click *Save*.
+
Wait for the proxy pod to reach the `Running` status.
EOF

# ── 4. Create the CLI procedure module ───────────────────────────────────────
cat > "${TOPIC_DIR}/proc_reenable-proxy-using-cli.adoc" << 'EOF'
// Module included in the following assemblies:
//
// * docs/developer-lightspeed-guide/assembly_reenable-llm-proxy-after-incident.adoc

:_mod-docs-content-type: PROCEDURE
[id="reenable-proxy-using-cli_{context}"]
= Re-enable the proxy by using the CLI

[role="_abstract"]
You can re-enable the LLM proxy by using the command-line interface (CLI) to restore functionality.

.Procedure

. Patch the Tackle custom resource (CR) to enable the LLM proxy:
+
[source,terminal,subs="+quotes"]
----
$ oc patch tackle __<tackle_instance_name>__ -n __<mta_namespace>__ \
  --type=merge -p '{"spec":{"kai_llm_proxy_enabled":true}}'
----
+
where:
+
`<tackle_instance_name>`:: Specifies the name of your Tackle instance.
`<mta_namespace>`:: Specifies the name of the {ProductShortName} namespace.

.Verification

. Verify that a proxy pod is running:
+
[source,terminal,subs="+quotes"]
----
$ oc get pods -n __<mta_namespace>__ | grep proxy
----
+
where:
+
`<mta_namespace>`:: Specifies the name of the {ProductShortName} namespace.
+
. Ask a developer to submit a test query from their integrated development environment (IDE) and confirm that a valid response is returned.
EOF

# ── 5. Update the parent assembly to point at the new assembly ────────────────
sed -i 's|include::proc_reenable-llm-proxy\.adoc\[leveloffset=+1\]|include::assembly_reenable-llm-proxy-after-incident.adoc[leveloffset=+1]|' \
    "${TOPIC_DIR}/assembly_emergency-llm-proxy-shutdown.adoc"

echo "Done. Files changed:"
echo "  removed:  ${TOPIC_DIR}/proc_reenable-llm-proxy.adoc"
echo "  created:  ${TOPIC_DIR}/assembly_reenable-llm-proxy-after-incident.adoc"
echo "  created:  ${TOPIC_DIR}/proc_reenable-proxy-using-web-console.adoc"
echo "  created:  ${TOPIC_DIR}/proc_reenable-proxy-using-cli.adoc"
echo "  modified: ${TOPIC_DIR}/assembly_emergency-llm-proxy-shutdown.adoc"
