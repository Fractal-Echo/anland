#!/system/bin/sh
MODDIR=${0%/*}
SOCK=/data/local/tmp/display_daemon.sock
rm -f "$SOCK"
"$MODDIR/display_daemon" "$SOCK" &

(
  for _ in 1 2 3 4 5; do
    if [ -S "$SOCK" ]; then
      chmod 666 "$SOCK"
      exit 0
    fi
    sleep 1
  done
) &
