### run the project with logging to file and allocation logs enabled

`odin run src -- -log-path:2026/15-07-2026.log -log-alloc`

### build the project with recommended struct style

`odin build src -vet -strict-style -vet-tabs -disallow-do -warnings-as-errors`
