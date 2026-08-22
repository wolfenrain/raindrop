#!/usr/bin/env bash
#
# Builds the CI matrix from the ci.yaml every package is required to have,
# and prints it as a "matrix=..." output for the workflow.
set -euo pipefail

package_configs() {
  dart run melos list --no-private --json |
    jq -r '.[] | [.name, .location] | @tsv' |
    while IFS=$'\t' read -r package location; do
      if [ ! -f "$location/ci.yaml" ]; then
        echo "$package is missing a ci.yaml" >&2
        exit 1
      fi
      yq -o=json -I0 '.' "$location/ci.yaml" |
        jq -c --arg package "$package" '{ package: $package } + .'
    done
}

echo "matrix=$(package_configs | jq -cs -f "$(dirname "$0")/matrix.jq")"
