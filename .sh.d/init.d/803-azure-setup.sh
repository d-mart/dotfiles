# Azure (az cli) tooling

command -v az &> /dev/null || return 0

# Interactively switch the active Azure subscription with fzf.
# Pass -r/--refresh to update the local subscription cache first.
function azsub() {
  if [[ "$1" == "-r" || "$1" == "--refresh" ]]; then
    echo "Refreshing Azure subscription cache..."
    az account list --refresh > /dev/null
  fi

  local selection
  selection=$(az account list --all --query "[].[isDefault && '*' || ' ', name, id, state]" -o tsv | \
    awk -F'\t' '{printf "%-2s %-45s %-38s (%s)\n", $1, $2, $3, $4}' | \
    fzf --height 40% --layout=reverse --border --prompt="Azure Subscription > " \
        --header="   NAME                                          SUBSCRIPTION ID                        STATE")

  if [[ -n "$selection" ]]; then
    # Subscription ID is the second-to-last column (names may contain spaces)
    local sub_id
    sub_id=$(echo "$selection" | awk '{print $(NF-1)}')

    az account set --subscription "$sub_id"
    echo "Switched active subscription to: $(az account show --query name -o tsv) ($sub_id)"
  fi
}

# Show the active subscription, user and tenant
alias azwho='az account show --query "{name:name, id:id, user:user.name, tenant:tenantId}" -o yaml'

# Interactively pick a default resource group with fzf (applies to the active subscription).
# Pass -c/--clear to unset the default.
function azrg() {
  if [[ "$1" == "-c" || "$1" == "--clear" ]]; then
    az configure --defaults group=
    echo "Cleared default resource group"
    return
  fi

  local current rg
  current=$(az config get defaults.group --query value -o tsv 2>/dev/null)

  rg=$(az group list --query "[].[name, location]" -o tsv | \
    awk -F'\t' '{printf "%-50s %s\n", $1, $2}' | \
    fzf --height 40% --layout=reverse --border --prompt="Resource Group > " \
        --header="Current default: ${current:-<none>}" | \
    awk '{print $1}')

  if [[ -n "$rg" ]]; then
    az configure --defaults group="$rg"
    echo "Default resource group: $rg"
  fi
}
