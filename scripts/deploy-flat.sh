#!/bin/sh
# Deploy skills flat: each skill directory under SOURCE becomes TARGET/<skill-name>/, holding its
# markdown files. MANIFEST lists the skills deployed here, so later runs remove only skills they own.
#
# Usage: deploy-flat.sh SOURCE TARGET MANIFEST
set -eu

source=$1
target=$2
manifest=$3

if [ ! -d "$source" ]; then
	echo "Skills source is not a directory: $source" >&2
	exit 1
fi

new_manifest=$(mktemp)
skill_list=$(mktemp)
trap 'rm -f "$new_manifest" "$skill_list"' EXIT

find "$source" -type f -name SKILL.md | sort > "$skill_list"

# Validate every skill before copying anything.
while IFS= read -r skill_file; do
	skill_name=$(basename "$(dirname "$skill_file")")
	if grep -Fxq "$skill_name" "$new_manifest"; then
		echo "Duplicate skill name: $skill_name" >&2
		exit 1
	fi
	if [ -e "$target/$skill_name" ] && ! { [ -f "$manifest" ] && grep -Fxq "$skill_name" "$manifest"; }; then
		echo "Not overwriting $target/$skill_name: it was not deployed from this repository" >&2
		exit 1
	fi
	printf '%s\n' "$skill_name" >> "$new_manifest"
done < "$skill_list"

mkdir -p "$target"
while IFS= read -r skill_file; do
	skill_dir=$(dirname "$skill_file")
	skill_name=$(basename "$skill_dir")
	rsync -a --delete --include='*.md' --include='*/' --exclude='*' "$skill_dir/" "$target/$skill_name/"
	echo "Deployed to $target/$skill_name"
done < "$skill_list"

if [ -f "$manifest" ]; then
	while IFS= read -r old_skill; do
		case "$old_skill" in
			'' | . | .. | */*) continue ;;
		esac
		if ! grep -Fxq "$old_skill" "$new_manifest"; then
			rm -rf "$target/$old_skill"
			echo "Removed stale skill $target/$old_skill"
		fi
	done < "$manifest"
fi
sort -u "$new_manifest" > "$manifest"
