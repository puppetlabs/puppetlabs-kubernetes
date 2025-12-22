#!/bin/bash
set -e

# Parameters from Bolt
collection=${PT_collection:-puppet7-nightly}
platform=${PT_platform:-}

# Normalize collection (puppetcore8* -> puppet8*)
if [[ "$collection" == puppetcore8* ]]; then
  collection="${collection/puppetcore8/puppet8}"
fi

# Only act for puppet8*
if [[ "$collection" != puppet8* ]]; then
  echo "Collection '$collection' not puppet8; skipping Java 17 enforcement."
  exit 0
fi

# Detect OS and version; only act on RHEL 8
osfamily="unsupported"
rhel_major=""
if [[ -f /etc/redhat-release ]]; then
  osfamily="redhat"
  if command -v rpm >/dev/null 2>&1; then
    rhel_major=$(rpm -E %rhel 2>/dev/null || true)
    # Some platforms may return literal %rhel; ignore
    [[ "$rhel_major" == "%rhel" ]] && rhel_major=""
  fi
  if [[ -z "$rhel_major" ]]; then
    rhel_major=$(awk '/release/ {for(i=1;i<=NF;i++){if($i=="release"){split($(i+1),a,".");print a[1];exit}}}' /etc/redhat-release 2>/dev/null)
  fi
fi

# Fallback: try to parse from provided platform (e.g., rhel-8)
if [[ -z "$rhel_major" && -n "$platform" ]]; then
  rhel_major=$(echo "$platform" | grep -Eo '[0-9]+' | head -n1 || true)
fi

if [[ "$osfamily" != "redhat" || "$rhel_major" != "8" ]]; then
  echo "Not RHEL 8 (detected family='$osfamily' version='$rhel_major'); skipping Java 17 enforcement."
  exit 0
fi

if [[ "$osfamily" == "redhat" && "$rhel_major" == "8" ]]; then
  # Install Java 17 headless
  (command -v dnf >/dev/null 2>&1 && dnf install -y java-17-openjdk-headless) || yum install -y java-17-openjdk-headless

  # Set JAVA_HOME for puppetserver
  if test -f /etc/sysconfig/puppetserver; then
    sed -i 's|^JAVA_HOME=.*|JAVA_HOME=/usr/lib/jvm/java-17-openjdk|' /etc/sysconfig/puppetserver || true
  else
    echo 'JAVA_HOME=/usr/lib/jvm/java-17-openjdk' >> /etc/sysconfig/puppetserver
  fi

  # Systemd drop-in to enforce environment
  mkdir -p /etc/systemd/system/puppetserver.service.d
  cat > /etc/systemd/system/puppetserver.service.d/java17.conf <<'EOF'
[Service]
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk"
Environment="PATH=/usr/lib/jvm/java-17-openjdk/bin:/opt/puppetlabs/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
EOF
  echo "Configured Java 17 for puppetserver on RedHat family."
fi

# Let the plan handle daemon-reload/restart
exit 0
