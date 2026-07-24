{ config, inputs, lib, pkgs, unstable, ... }:
{
  home = {
    # initialize the password store if it's not already initialized
    activation.passInit = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f "${config.xdg.dataHome}/password-store/.gpg-id" ]; then
      echo "Initializing pass password store..."
      ${pkgs.pass}/bin/pass init "$(pass show .gpg-id 2>/dev/null || echo '${config.programs.password-store.settings.PASSWORD_STORE_KEY}')"
      else
      echo "Pass store already initialized."
      fi
    '';

    file = {
      ".config/secretspec/config.toml".text = ''
      [defaults]
      provider = "bws"
      profile = "default"

      [defaults.providers]
      jessenieboer_home_manager = { uri = "bws://ff39ba56-1bfb-46cf-af64-b42601032d0f", credentials = { access_token = "jessenieboer_access_token" } }
      jessenieboer_access_token = "pass://jessenieboer_secretspec_bws_access_token"
      '';
    };

    packages = with pkgs; [
      (pkgs.rustPlatform.buildRustPackage {
        pname = "secretspec";
        version = "0.16.0";

        # to update: nix-prefetch-github cachix secretspec --rev v0.16.0
        src = pkgs.fetchFromGitHub {
          owner = "cachix";
          repo = "secretspec";
          rev = "454546d7cca26f604eea8e8bf85673d7d01d400d";
          hash = "sha256-TL9S/NFwL9q7h6ImGosGpB7T08HhDFy1v04YLLvVsto=";
        };

        buildAndTestSubdir = "secretspec";
        cargoHash = "sha256-+8FGPk/84gW0+LeCufr+uEpWdy35QI2tlgkFRnv6Ycg=";
        
        #cargoBuildFlags = [ "--package" "secretspec" "--features" "bws" ];
        #buildFeatures = [ "bws" ];

        # Optional: native build inputs if needed
        nativeBuildInputs = [ pkg-config ];
        buildInputs = [ dbus openssl ];  # often needed for Rust crates

        meta = {
          mainProgram = "secretspec";
        };
      })
      bitwarden-cli
      #bitwarden-desktop
      bws #bitwarden secrets manager
      jq # for parsing json from bws      
      yubikey-manager
      rustc
      cargo
      clippy
      rustfmt
      rust-analyzer
    ];
  };

  programs = {
    gpg = {
      enable = true;
      publicKeys = [
        {
          text = ''
            -----BEGIN PGP PUBLIC KEY BLOCK-----
            Comment: 2BC2 1C27 9427 FEE6 2E20  1117 F29D E2CB E4F3 FCE5
            Comment: Jesse Nieboer <jessenieboer@protonmail.com>

            xjMEaaHi1hYJKwYBBAHaRw8BAQdAgxFrMdnwBjzIUzwpkwMy7D49i44K3O8jqA6c
            y7/sdhzNK0plc3NlIE5pZWJvZXIgPGplc3NlbmllYm9lckBwcm90b25tYWlsLmNv
            bT7CrwQTFgoAVxsUgAAAAAAEAA5tYW51MiwyLjUrMS4xMSwyLDECGwMFCwkIBwIC
            IgIGFQoJCAsCBBYCAwECHgcCF4AWIQQrwhwnlCf+5i4gERfyneLL5PP85QUCaaHm
            bwAKCRDyneLL5PP85b7IAQCxMryEBKkSUvXlHc8o7pO4EKsHS1Lwht/OnPOD4rtE
            UwEA51iT2CXnYBcPANeLgJcvZZRL0l8fCDtmtfRdc7EwjwHCtQQTFgoAXRYhBCvC
            HCeUJ/7mLiARF/Kd4svk8/zlBQJpoeLWGxSAAAAAAAQADm1hbnUyLDIuNSsxLjEx
            LDIsMQIbAwUJBaTkygULCQgHAgIiAgYVCgkICwIEFgIDAQIeBwIXgAAKCRDyneLL
            5PP85WWyAQCBmEklgDBEBJC6BrJrcwaKgjSPCl+ltl1pCWWu2+1qgwEA/ZMw2nv+
            sweky2rbMfSfFSbxxVJbIGKHnhzBRvIRwwPOOARpoeLWEgorBgEEAZdVAQUBAQdA
            JXh2B+hepgGzyPMD1g8RA4lJmSgFBopIb7qonDnWnBQDAQgHwpQEGBYKADwbFIAA
            AAAABAAObWFudTIsMi41KzEuMTEsMiwxAhsMFiEEK8IcJ5Qn/uYuIBEX8p3iy+Tz
            /OUFAmmh5oMACgkQ8p3iy+Tz/OUZdgD7BJgWBAIh4N9NDQmpPNj2Qta5ajJmqRV3
            mH3IGYlDp6MBALQac8v9g6XZQ2EY3uKOdpb150yFx/ubu6YSjcPCFUMI
            =yw5/
            -----END PGP PUBLIC KEY BLOCK-----
          '';
          trust = "ultimate";
        }
      ];

      # YubiKey best practice on NixOS
      scdaemonSettings = {
        disable-ccid = true;
      };

      settings = {
        no-comments = true;
        no-emit-version = true;
        keyserver = "hkps://keys.openpgp.org";
      };
    };
    password-store = {
      enable = true;
      package = pkgs.pass;
      settings = {
        PASSWORD_STORE_KEY = "2BC21C279427FEE62E201117F29DE2CBE4F3FCE5"; # my gpg key id
      };
    };


    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "github.com" = {
          AddKeysToAgent = "yes";
          HostName = "github.com";
          IdentitiesOnly = true;
          # stub files that point to private key on a Yubikey
          IdentityFile = [
            "/home/jessenieboer/.ssh/id_ed25519_sk"           # main YubiKey
            "/home/jessenieboer/.ssh/id_ed25519_sk_spare"     # spare YubiKey
          ];
          User = "git";
        };
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-qt;
  };
}
