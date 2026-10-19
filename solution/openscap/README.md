# Stretch goal — OpenSCAP / CIS hardening

Expansion Pack stretch #1: harden with **CIS** (or another profile) using `oscap` and `scap-security-guide`.

```bash
sudo dnf install -y openscap-scanner scap-security-guide
# Example scan (profile IDs vary by RHEL version — list first):
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml | less
sudo oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis \
  --results /tmp/fl-cis-results.xml \
  --report /tmp/fl-cis-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
```

Remediation: follow Red Hat docs for OpenSCAP remediation; re-seal image afterward.  
Keep HTML report for the presentation stretch slide (no secrets inside).
