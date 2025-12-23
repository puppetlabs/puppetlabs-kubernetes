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

  # Register Java 17 with alternatives and select it; repair any bad symlink chains
  if [[ -x /usr/lib/jvm/java-17-openjdk/bin/java ]]; then
    rm -f /usr/bin/java /bin/java /etc/alternatives/java || true
    alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk/bin/java 200000 || true
    alternatives --set java /usr/lib/jvm/java-17-openjdk/bin/java || true
    # Ensure alternatives link exists even if alternatives didn't create it
    ln -sf /usr/lib/jvm/java-17-openjdk/bin/java /etc/alternatives/java || true
    ln -sf /etc/alternatives/java /usr/bin/java || true
    ln -sf /etc/alternatives/java /bin/java || true
  fi

  # Set JAVA_HOME for puppetserver
  if test -f /etc/sysconfig/puppetserver; then
    sed -i 's|^JAVA_HOME=.*|JAVA_HOME=/usr/lib/jvm/java-17-openjdk|' /etc/sysconfig/puppetserver || true
  else
    echo 'JAVA_HOME=/usr/lib/jvm/java-17-openjdk' >> /etc/sysconfig/puppetserver
  fi

  # Ensure conservative JVM heap to avoid OOM on small runners
  if grep -qE '^[#\s]*JAVA_ARGS=' /etc/sysconfig/puppetserver; then
    sed -i -E 's/-Xms[0-9]+[mMgG]/-Xms512m/g' /etc/sysconfig/puppetserver || true
    sed -i -E 's/-Xmx[0-9]+[mMgG]/-Xmx1024m/g' /etc/sysconfig/puppetserver || true
  else
    echo 'JAVA_ARGS="-Xms512m -Xmx1024m"' >> /etc/sysconfig/puppetserver
  fi

  # Systemd drop-in to enforce environment
  mkdir -p /etc/systemd/system/puppetserver.service.d
  cat > /etc/systemd/system/puppetserver.service.d/java17.conf <<'EOF'
[Service]
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk"
Environment="PATH=/usr/lib/jvm/java-17-openjdk/bin:/opt/puppetlabs/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
EOF
  echo "Configured Java 17 for puppetserver on RedHat family."
  # Reload systemd to pick up drop-in; restart handled by plan
  systemctl daemon-reload || true

  # Ensure required dirs and ownership to prevent startup crashes
  install -d -m 0755 -o puppet -g puppet /opt/puppetlabs/server/data/puppetserver || true
  install -d -m 0755 -o puppet -g puppet /var/log/puppetlabs/puppetserver || true
  touch /var/log/puppetlabs/puppetserver/puppetserver.log || true
  chown puppet:puppet /var/log/puppetlabs/puppetserver/puppetserver.log || true

  # Initialize CA if not present (idempotent)
  if [[ ! -d /etc/puppetlabs/puppet/ssl/ca ]]; then
    /opt/puppetlabs/bin/puppetserver ca setup || true
  fi

  # Raise file descriptor limits for the service
  mkdir -p /etc/systemd/system/puppetserver.service.d
  cat > /etc/systemd/system/puppetserver.service.d/limits.conf <<'EOF'
[Service]
LimitNOFILE=32768
EOF
  systemctl daemon-reload || true
fi

# Let the plan handle daemon-reload/restart
exit 0
