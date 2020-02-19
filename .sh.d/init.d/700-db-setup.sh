
# run with a heroku app name to connect to the database
function pc() {
  heroku_app="$1"
  setting_name="${2:-DATABASE_URL}"
  pgcli $(heroku config:get "$setting_name" --app="$heroku_app")
}

function ir() {
  iredis="$(asdf where python)/bin/iredis"
  host="${1:-127.0.0.1}"
  port="${2:-6379}"
  db_num="${3:-0}"

  $iredis --rainbow -h "$host" -p "$port" -n "$db_num"
}
