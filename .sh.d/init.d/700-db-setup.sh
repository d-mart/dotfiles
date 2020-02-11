
# run with a heroku app name to connect to the database
function pc() {
  heroku_app="$1"
  setting_name="${2:-DATABASE_URL}"
  pgcli $(heroku config:get "$setting_name" --app="$heroku_app")
}
