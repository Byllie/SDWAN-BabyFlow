set -e

DB=/etc/openvswitch/conf.db
RUNDIR=/var/run/openvswitch
SCHEMA=/usr/share/openvswitch/vswitch.ovsschema

modprobe openvswitch 2>/dev/null || true

mkdir -p /etc/openvswitch "$RUNDIR"

if [ ! -e "$DB" ]; then
    ovsdb-tool create "$DB" "$SCHEMA"
fi

ovsdb-server "$DB" \
    --remote=punix:$RUNDIR/db.sock \
    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
    --private-key=db:Open_vSwitch,SSL,private_key \
    --certificate=db:Open_vSwitch,SSL,certificate \
    --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
    --pidfile=$RUNDIR/ovsdb-server.pid \
    --detach --log-file

ovs-vsctl --no-wait init


ovs-vswitchd \
    --pidfile=$RUNDIR/ovs-vswitchd.pid \
    --detach --log-file

for i in $(seq 1 30); do
  if ovs-vsctl show >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

ovs-vsctl --may-exist --no-wait add-br br0

for i in $(seq 1 15); do
  ip link set br0 up 2>/dev/null && break
  sleep 1
done


(
  while true; do
    for ifc in /sys/class/net/*; do
      name=$(basename "$ifc")
      if [[ "$name" =~ ^eth[0-9]+$ ]] && [ "$name" != "eth0" ]; then
        ovs-vsctl --may-exist --no-wait add-port br0 "$name" 2>/dev/null || true
      fi
    done
    sleep 1
  done
) &

ovs-vsctl show
echo "OVS prêt sur $(hostname)"

while true; do sleep 3600; done

