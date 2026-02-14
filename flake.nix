{
  description = "TouchKio - Nix package (pre-built binary from GitHub releases)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
  let
    version = "1.4.2";

    mkTouchkio = system: let
      pkgs = import nixpkgs { inherit system; };
      archMap = {
        "x86_64-linux" = { arch = "x64"; hash = "sha256-9x3BehMA7j6V3Wy4CdsMIz4isn9PNILgTuFLuCfszPo="; };
        "aarch64-linux" = { arch = "arm64"; hash = "sha256-Jkdv/KcKxdc3uKa9K7yal3l5UGR55e1Pd6Ydrw7n/cU="; };
      };
      archInfo = archMap.${system};
    in pkgs.stdenvNoCC.mkDerivation {
      pname = "touchkio";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/leukipp/touchkio/releases/download/v${version}/touchkio-linux-${archInfo.arch}-${version}.zip";
        hash = archInfo.hash;
      };

      nativeBuildInputs = with pkgs; [ unzip autoPatchelfHook makeWrapper ];

      buildInputs = with pkgs; [
        alsa-lib
        at-spi2-atk
        cairo
        cups
        dbus
        expat
        glib
        gtk3
        libdrm
        libxkbcommon
        mesa
        nspr
        nss
        pango
        systemd
        xorg.libX11
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXrandr
        xorg.libxcb
      ];

      unpackPhase = ''
        unzip $src -d source
      '';

      installPhase = ''
        mkdir -p $out/opt/touchkio $out/bin
        cp -r source/* $out/opt/touchkio/
        chmod +x $out/opt/touchkio/touchkio

        makeWrapper $out/opt/touchkio/touchkio $out/bin/touchkio \
          --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [
            pkgs.libGL
            pkgs.mesa
          ]}"
      '';

      meta = with pkgs.lib; {
        description = "Touch-optimized kiosk browser for dashboards";
        homepage = "https://github.com/leukipp/touchkio";
        license = licenses.mit;
        platforms = [ "x86_64-linux" "aarch64-linux" ];
        mainProgram = "touchkio";
      };
    };
  in {
    packages.aarch64-linux.default = mkTouchkio "aarch64-linux";
    packages.aarch64-linux.touchkio = mkTouchkio "aarch64-linux";
    packages.x86_64-linux.default = mkTouchkio "x86_64-linux";
    packages.x86_64-linux.touchkio = mkTouchkio "x86_64-linux";

    overlays.default = final: prev: {
      touchkio = self.packages.${final.system}.touchkio;
    };
  };
}
