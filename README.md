# nix-touchkio

Nix flake package for [TouchKio](https://github.com/leukipp/touchkio) — a touch-optimized kiosk browser for dashboards.

Packages pre-built binaries from GitHub releases (no source compilation needed).

## Usage

### As a flake input
```nix
{
  inputs.touchkio.url = "github:node-openclaw/nix-touchkio";

  # In your config:
  environment.systemPackages = [ inputs.touchkio.packages.aarch64-linux.default ];
}
```

### Direct run
```bash
nix run github:node-openclaw/nix-touchkio
```

## Supported platforms
- `x86_64-linux`
- `aarch64-linux`
