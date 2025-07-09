
function ir() {
  iredis="$(asdf where python)/bin/iredis"
  host="${1:-127.0.0.1}"
  port="${2:-6379}"
  db_num="${3:-0}"

  $iredis --rainbow -h "$host" -p "$port" -n "$db_num"
}
