{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  tor,
  trezord,
}:

let
  pname = "trezor-suite";
  version = "25.6.3";

  suffix =
    {
      aarch64-linux = "linux-arm64";
      x86_64-linux = "linux-x86_64";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/trezor/trezor-suite/releases/download/v${version}/Trezor-Suite-${version}-${suffix}.AppImage";
    hash =
      {
        # curl -Lfs https://github.com/trezor/trezor-suite/releases/download/v${version}/latest-linux{-arm64,}.yml | grep ^sha512 | sed 's/: /-/'
        aarch64-linux = "sha512-uOfunT0I/Yt07r0J6/OFYN17N0V41oIJZqieineFVJW0Q+pLQc7Bvme4lfwa1l/gF9ciwwStEJRo3uuWDehFaw==";
        x86_64-linux = "sha512-OkLee1qCM9jCZiiBOwYwiN0BasGa/OUHqJ4b4qMmr3u69EbchI5rvS3XfZ5GhkCI+9x32CAjUvRxlflAenC8RQ==";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

in

appimageTools.wrapType2 rec {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    mkdir -p $out/bin $out/share/${pname} $out/share/${pname}/resources

    cp -a ${appimageContents}/locales/ $out/share/${pname}
    cp -a ${appimageContents}/resources/app*.* $out/share/${pname}/resources
    cp -a ${appimageContents}/resources/images/ $out/share/${pname}/resources

    wrapProgram $out/bin/trezor-suite \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D ${appimageContents}/resources/images/desktop/512x512.png $out/share/icons/hicolor/512x512/apps/${pname}.png
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname}'

    # symlink system binaries instead bundled ones
    mkdir -p $out/share/${pname}/resources/bin/{bridge,tor}
    ln -sf ${trezord}/bin/trezord-go $out/share/${pname}/resources/bin/bridge/trezord
    ln -sf ${tor}/bin/tor $out/share/${pname}/resources/bin/tor/tor
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Trezor Suite - Desktop App for managing crypto";
    homepage = "https://suite.trezor.io";
    changelog = "https://github.com/trezor/trezor-suite/releases/tag/v${version}";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ prusnak ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "trezor-suite";
  };
}
