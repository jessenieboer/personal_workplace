# voxtype-toggle plasmoid (vendored)

KDE Plasma 6 panel applet that toggles voxtype recording and shows its state.

- Author: James Eversole <james@eversole.co>
- License: ISC (see `LICENSE`; notice must stay with the files)
- Upstream: `https://git.eversole.co/James/voxtype-toggle-plasmashell`
  (404 as of 2026-10-08; repo no longer listed under the author's profile)
- Vendored from: rev `cda2a43a880ce724598959a49b7ec6be54b8d81b`
  (flake.lock narHash `sha256-+nvMfIYASXw7s+lSTS9LNixmPh8pRLmmpN1ox5SP/nY=`),
  copied from the local nix store source `/nix/store/wlnhl943gxp65q43nvi9p3hcv8wf9nb5-source`.
  Only the applet package itself (`metadata.json`, `contents/`) plus `LICENSE` were kept;
  upstream's `flake.nix`, `default.nix` and `README.md` were dropped.

## Local changes

- `contents/ui/main.qml`: the daemon is re-checked on every poll instead of only once
  at startup, so the icon recovers on its own if voxtype starts after plasmashell or
  restarts (previously it could stay stuck on the "not running" warning icon).

Installed by `../voxtype.nix` into `~/.local/share/plasma/plasmoids/org.eversole.voxtype-toggle`
(nucbox only).
