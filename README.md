# factory

A lightweight bootstrap + updater for your personal AI harness repository.

## Install in a new project

From the target project root:

```bash
curl -fsSL https://raw.githubusercontent.com/can1357/factory/main/install.sh | bash
```

This command:
- clones this repo into `.factory` in the current directory
- updates `.factory` on subsequent runs
- creates a `./factory` helper script

## Use the helper in an installed project

```bash
./factory status   # check harness git state
./factory update   # pull latest updates from the harness remote
./factory path     # print installed harness directory
```

## Options

- `--path <dir>` install into a different directory
- `--repo <url>` install from a fork/custom remote
- `--branch <name>` choose branch (default: `main`)
- `--reinstall` replace an existing `.factory` directory
- `-h|--help` show install script usage

Examples:

```bash
# Install to a specific project
curl -fsSL https://raw.githubusercontent.com/can1357/factory/main/install.sh | bash -s -- --path ~/projects/my-next-project

# Install from a fork
curl -fsSL https://raw.githubusercontent.com/can1357/factory/main/install.sh | bash -s -- --repo https://github.com/<you>/<your-harness-repo>.git
```

If this repository is renamed, just update the raw URL in your command.
