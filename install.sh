#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash install.sh [options]

Installs or updates this harness into the current project under .factory.

Options:
  -p, --path <dir>      Project directory to install into (default: current working directory)
  -r, --repo <url>      Git URL for this harness (default: local git remote or https://github.com/can1357/factory.git)
  -b, --branch <name>   Branch to install from (default: ${FACTORY_BRANCH:-main})
      --reinstall        Remove existing .factory and clone fresh
  -h, --help            Show this help text

After install, run:
  ./factory update    # pull latest harness changes into this project
EOF
}

project_dir="$PWD"
repo_url="${FACTORY_REPO_URL:-}"
branch="${FACTORY_BRANCH:-main}"
reinstall=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--path)
      project_dir="$2"
      shift 2
      ;;
    -r|--repo)
      repo_url="$2"
      shift 2
      ;;
    -b|--branch)
      branch="$2"
      shift 2
      ;;
    --reinstall)
      reinstall=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to install this harness"
  exit 1
fi

if [ -z "$repo_url" ]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -d "$script_dir/.git" ]; then
    repo_url="$(git -C "$script_dir" remote get-url origin)" || true
  fi
fi

if [ -z "$repo_url" ]; then
  repo_url="https://github.com/can1357/factory.git"
fi

project_dir="$(cd "$project_dir" && pwd)"
install_dir="$project_dir/.factory"

if [ -d "$install_dir" ] && [ "$reinstall" -ne 1 ]; then
  if [ ! -d "$install_dir/.git" ]; then
    echo "Existing $install_dir is not a git checkout; use --reinstall to replace it."
    exit 1
  fi

  echo "Updating harness in $install_dir"
  git -C "$install_dir" fetch --all --prune
  if git -C "$install_dir" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$install_dir" checkout "$branch"
  else
    git -C "$install_dir" checkout -B "$branch" "origin/$branch"
  fi
  git -C "$install_dir" pull --ff-only origin "$branch"
else
  if [ -d "$install_dir" ]; then
    rm -rf "$install_dir"
  fi

  echo "Installing harness from $repo_url ($branch) into $install_dir"
  git clone --depth 1 --single-branch --branch "$branch" "$repo_url" "$install_dir"
fi

if [ ! -x "$install_dir/bin/factory" ]; then
  echo "Install failed: $install_dir/bin/factory is missing"
  exit 1
fi

helper="$project_dir/factory"
ln -sfn "$install_dir/bin/factory" "$helper"
chmod +x "$helper"

echo "Installed. Run ./factory update to refresh the harness later."
