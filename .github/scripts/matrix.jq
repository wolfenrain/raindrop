# Expands package ci.yaml configs into the build matrix.
#
# Input: one { package, os, databases } object per package.
# Output: a matrix entry per OS and per database version combination.

# "postgres:16~" -> { value: "postgres:16", unstable: true }
def parse: { value: rtrimstr("~"), unstable: endswith("~") };

# Every way to pick one version of each database:
# [pg:16, pg:17, lite:3] -> [[pg:16, lite:3], [pg:17, lite:3]]
def combos:
  group_by(.value | split(":")[0])
  | reduce .[] as $versions ([[]];
      [ .[] as $combo | $versions[] as $db | $combo + [$db] ]);

[ .[]
  | .package as $package
  | (.os // [] | if length == 0
      then error("\($package)/ci.yaml must list at least one os")
      else . end | map(parse))[] as $os
  | ((.databases // []) | map(parse) | combos)[] as $dbs
  | { package: $package,
      os: $os.value,
      databases: ($dbs | map(.value)),
      experimental: ($os.unstable or any($dbs[]; .unstable)),
      name: "\($package) (\(([$os.value] + ($dbs | map(.value))) | join(", ")))" }
]
