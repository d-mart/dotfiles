# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true
# cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
# but wait, we do actually want a system-wide package
syspip() {
    PIP_REQUIRE_VIRTUALENV='' pip "$@"
}
