#!/usr/bin/env bash

dry_run="0"

if [ -z "$XDG_CONFIG_HOME" ]; then
    echo "XDG_CONFIG_HOME not set, using ~/.config"
    XDG_CONFIG_HOME="$HOME/.config"
fi

if [ -z "$DEV_ENV" ]; then
    echo "Error: env var DEV_ENV must be set (path to your configs)"
    exit 1
fi

if [[ $1 == "--dry" ]]; then
    dry_run="1"
    echo "=== DRY RUN MODE (no changes will be made) ==="
fi

log() {
    if [[ $dry_run == "1" ]]; then
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}

log "Environment: $DEV_ENV"

symlink_files() {
    local src_dir="$1"
    local target_dir="$2"

    log "Creating symlinks from: $src_dir → $target_dir"

    pushd "$src_dir" &> /dev/null || exit 1
    (
        find . -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' item; do
            local item_name="${item#./}"
            local src_item="$src_dir/$item_name"
            local target_item="$target_dir/$item_name"

            # Удаляем существующий файл/папку (если не dry run)
            if [[ -e "$target_item" || -L "$target_item" ]]; then
                log "  Removing existing: $target_item"
                [[ $dry_run == "0" ]] && rm -rf "$target_item"
            fi

            # Создаём симлинк
            log "  Creating symlink: $src_item → $target_item"
            if [[ $dry_run == "0" ]]; then
                mkdir -p "$(dirname "$target_item")"  # Создаём родительские папки, если нужно
                ln -s "$src_item" "$target_item"
            fi
        done
    )
    popd &> /dev/null || exit 1
}

symlink_file() {
    local src_file="$1"
    local target_file="$2"

    if [[ -e "$target_file" || -L "$target_file" ]]; then
        log "Removing existing: $target_file"
        [[ $dry_run == "0" ]] && rm -rf "$target_file"
    fi

    log "Creating symlink: $src_file → $target_file"
    if [[ $dry_run == "0" ]]; then
        mkdir -p "$(dirname "$target_file")"
        ln -s "$src_file" "$target_file"
    fi
}

symlink_files "$DEV_ENV/env/.config" "$XDG_CONFIG_HOME"
symlink_files "$DEV_ENV/env/.local" "$HOME/.local"

symlink_file "$DEV_ENV/env/.zsh_profile" "$HOME/.zsh_profile"
symlink_file "$DEV_ENV/env/.zshrc" "$HOME/.zshrc"

# Перезагружаем Hyprland (если используется)
if [[ $dry_run == "0" ]] && command -v hyprctl &> /dev/null; then
    log "Reloading Hyprland..."
    hyprctl reload
fi

log "Done! All configs are now symlinked."
