#!/usr/bin/env bash

# ------- Configuration -------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"
BACKUP_DIR="${HOME}/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ------- Functions -------

# Create symlink with backup handling
link_file() {
  local src="$1"
  local dest="$2"

  # Create parent directory if needed
  mkdir -p "$(dirname "$dest")"

  # Handle existing files
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ ! -d "$BACKUP_DIR" ]; then
      mkdir -p "$BACKUP_DIR"
    fi
    echo -e "${YELLOW}Backing up ${dest} to ${BACKUP_DIR}${NC}"
    mv "$dest" "$BACKUP_DIR/"
  fi

  echo -e "${GREEN}Linking ${src} to ${dest}${NC}"
  ln -s "$src" "$dest"
}

# ------- Main Installation -------

echo -e "${GREEN}Installing dotfiles...${NC}"
echo -e "Dotfiles directory: ${YELLOW}${DOTFILES_DIR}${NC}"
echo -e "Target directory: ${YELLOW}${TARGET_DIR}${NC}"
echo ""

# List of packages to install (excluding sway-related stuff)
PACKAGES=(
  "alacritty"
  "applications"
  "fish"
  "fuzzel"
  "nvim"
  "tmux"
  "vifm"
  "waybar"
  "yazi"
)

for package in "${PACKAGES[@]}"; do
  package_dir="${DOTFILES_DIR}/${package}"
  
  if [ ! -d "$package_dir" ]; then
    echo -e "${YELLOW}Warning: Package ${package} not found${NC}"
    continue
  fi

  echo -e "${GREEN}Processing ${package}...${NC}"

  # Find all files in package directory (excluding .git files)
  while IFS= read -r -d '' file; do
    # Get relative path
    rel_path="${file#$package_dir/}"
    
    # Remove leading .config/ or .local/ if present
    if [[ "$rel_path" =~ ^\.(config|local)/(.*) ]]; then
      target_rel_path="${BASH_REMATCH[2]}"
    else
      target_rel_path="$rel_path"
    fi
    
    # Determine target path
    if [[ "$file" == *"/.config/"* ]]; then
      target_path="${TARGET_DIR}/.config/${target_rel_path}"
    elif [[ "$file" == *"/.local/"* ]]; then
      target_path="${TARGET_DIR}/.local/${target_rel_path}"
    else
      target_path="${TARGET_DIR}/${rel_path}"
    fi

    link_file "$file" "$target_path"
  done < <(find "$package_dir" -type f -not -path '*/.git/*' -print0)
done

# ------- Post-installation -------

# Set strict permissions for sensitive files
if [ -f "${TARGET_DIR}/.ssh/config" ]; then
  chmod 600 "${TARGET_DIR}/.ssh/config"
  echo -e "${GREEN}Set strict permissions for ~/.ssh/config${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
if [ -d "$BACKUP_DIR" ]; then
  echo -e "Backups were saved to ${YELLOW}${BACKUP_DIR}${NC}"
fi
