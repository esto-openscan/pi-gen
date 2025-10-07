#!/bin/bash -e

echo "Configuring OpenScan3 base components"

install -m 755 -D files/usr/local/bin/openscan3 "${ROOTFS_DIR}/usr/local/bin/openscan3"
install -m 644 -D files/etc/systemd/system/openscan3.service "${ROOTFS_DIR}/etc/systemd/system/openscan3.service"

on_chroot <<'EOF'
set -e

adduser --system --group --home /opt/openscan3 openscan
for grp in camera video render plugdev input i2c spi; do
  groupadd -f "$grp"
  adduser openscan "$grp"
done

curl -LsSf https://astral.sh/uv/install.sh | sh
mv /root/.local/bin/uv /usr/local/bin/uv

rm -rf /opt/openscan3

git clone --depth 1 https://github.com/OpenScan-org/OpenScan3.git /opt/openscan3
chown -R openscan:openscan /opt/openscan3

runuser -u openscan -- /usr/local/bin/uv sync --frozen --project /opt/openscan3

chmod +x /usr/local/bin/openscan3
systemctl enable openscan3
EOF
