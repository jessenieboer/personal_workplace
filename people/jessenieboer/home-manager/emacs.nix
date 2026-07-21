{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
let
  # v0.9.9.3 "d0c392bbb0a1f7775d3a1e98220f4bdc043ab63b"/"sha256-yWPNgifEckRi42xcj7e4iPHgOPIQU8z6dLvGAAKYDSA="
  # latest: "0f65be08ead0c9bc882fad5a4dcb604448e366a6"/"sha256-+/iNJDJ/bvn6cs7457fEgoC5TxJ9bfXUlV+pXl6vP28="
  gptel = pkgs.emacsPackages.trivialBuild {
    pname = "gptel";
    version = "v0.9.9.3";
    src = pkgs.fetchFromGitHub {
      owner = "karthink";
      repo = "gptel";
      rev = "5c82ff85be0beed57a923935e18b9c4d1a8d0858";
      hash = "sha256-+/iNJDJ/bvn6cs7457fEgoC5TxJ9bfXUlV+pXl6vP28=";
    };
    packageRequires = with pkgs.emacsPackages; [
      transient
      markdown-mode
    ];
    #dontUnpack = true;
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out/share/emacs/site-lisp/gptel
      cp -r $src/* $out/share/emacs/site-lisp/gptel/
    '';
  };

  gptel-agent = pkgs.emacsPackages.trivialBuild {
    pname = "gptel-agent";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "karthink";
      repo = "gptel-agent";
      rev = "f8cab0368918672a329ea3caf5cd64b6db1722eb";
      hash = "sha256-5uxJDypbnYK8gYQ/mnf5oTbufV5pxPvZPawf99At9uc";
    };
    packageRequires = with pkgs.emacsPackages; [
      gptel
    ];
    #dontUnpack = true;
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out/share/emacs/site-lisp/gptel-agent
      cp -r $src/* $out/share/emacs/site-lisp/gptel-agent/
    '';
  };

  # try to bypass ssl issues
  # orgPkg = pkgs.emacsPackages.trivialBuild {
  #   pname = "org";
  #   version = "9.7.30";
  #   src = pkgs.fetchgit {
  #     url = "https://git.savannah.gnu.org/git/emacs/org-mode.git";
  #     rev = "release_9.7.30";
  #     hash = "sha256-Or19x+RPUjDH/WRsw3BcIPTOSAIzGzWaHXlo5YUVmBU=";
  #   };
  #   buildPhase = "true";
  #   installPhase = ''
  #     mkdir -p $out/share/emacs/site-lisp/org
  #     cp -r lisp/* $out/share/emacs/site-lisp/org/
  #   '';
  # };

  pgmacs = pkgs.emacsPackages.trivialBuild {
    pname = "pgmacs";
    version = "0.26";
    src = fetchFromGitHub {
      owner = "emarsden";
      repo = "pgmacs";
      rev = "1daac9fab38532d89ff6a153bdaa51a2b8c26c9a"; # Replace with specific commit for stability, e.g., "a1b2c3d..."
      sha256 = "0wa2ccds1n27rbqdwm4qys6ykqivd782q8vdml8gj0fmywfc6f4f"; # Run `nix-prefetch-url --unpack https://github.com/emarsden/pgmacs/archive/refs/tags/v0.26.tar.gz`
    };
    dontUnpack = true;
    buildPhase = "true"; # No compilation needed
    installPhase = ''
      mkdir -p $out/share/emacs/site-lisp/pgmacs
      cp -r $src/* $out/share/emacs/site-lisp/pgmacs/
    '';
  };

  # provided by the supercollider_scel install
  scel = pkgs.emacsPackages.trivialBuild {
    pname = "scel";
    version = supercollider.version; # Matches the SuperCollider version for consistency
    src = "${supercollider_scel}/share/emacs/site-lisp/SuperCollider/";
    dontUnpack = true; # Skip unpacking since src is already a directory
    buildPhase = "true"; # No compilation needed for SCEL
    installPhase = ''
      mkdir -p $out/share/emacs/site-lisp/scel
      cp -r $src/. $out/share/emacs/site-lisp/scel/
    '';
  };

  bitwarden = pkgs.emacsPackages.trivialBuild {
    pname = "bitwarden";
    version = "0.1";
    src = fetchFromGitHub {
      owner = "seanfarley";
      repo = "emacs-bitwarden";
      rev = "50c0078d356e0ac0bcaf26b40113700ba4123ec3";
      sha256 = "111z6k29wrry1gvm1qkwclh3hl7p5lp3nwdv6kn8w3214yh28c77";
    };
    # buildInputs = [ pkgs.emacs ];
    nativeBuildInputs = [ pkgs.bitwarden-cli ];
    buildPhase = "true"; # No compilation needed
    installPhase = ''
      mkdir -p $out/share/emacs/site-lisp/bitwarden
      cp -r $src/* $out/share/emacs/site-lisp/bitwarden/
    '';
  };

  # org-jira = pkgs.emacsPackages.trivialBuild {
    #   pname = "org-jira";
    #   version = "4.4.2";
    #   src = fetchFromGitHub {
      #     owner = "ahungry";
      #     repo = "org-jira";
      #     rev = "ac625b080545a1ade22d070c23624f71b7ab02b5";
      #     sha256 = "1mg7p9y4d4m6b6qkjvdz6lqby3kvvdb7qcjqgkrf75rzv0rsn1h2";
      #   };
      #   buildPhase = "true";
      #   installPhase = ''
      #     mkdir -p $out/share/emacs/site-lisp/org-jira
      #     cp -r $src/* $out/share/emacs/site-lisp/org-jira/
      #   '';
      # };

      myEmacs = (
        emacsWithPackagesFromUsePackage {
          alwaysEnsure = true;
          # alwaysTangle = true;

          # This points to the file in this directory in the nix store and I don't think it's actually used as initial config. The actual config org-dotemacs uses gets dumped into the user's home dir.
          config = ../config-files/.emacs;
          package = emacs-unstable;
          extraEmacsPackages =
            epkgs:
            (with epkgs; [
              # configuration
              org-dotemacs

              # host environment
              async
              esup
              use-package

              # essential emacs
              ## control via keyboard
              major-mode-hydra

              # enhanced emacs
              ## customizing emacs's appearance
              all-the-icons
              default-text-scale
              golden-ratio
              ### themes
              solarized-theme
              ## general
              consult
              embark
              embark-consult
              marginalia
              orderless
              vertico
              ## working with buffers
              centaur-tabs
              ## working with windows
              popper
              windswap
              ## reading text
              hide-lines
              imenu-list
              origami
              pdf-tools
              ## working with the file system
              dired-ranger
              dired-subtree
              treemacs
              ## editing text
              cape
              corfu
              xclip
              undo-fu
              ## working with projects
              # specified emacs
              ## using the org system
              emacsql
              htmlize
              org
              # orgPkg
              #org-edna
              #org-fancy-priorities
              #org-roam
              #org-super-agenda
              org-tidy
              # poly-org
              # polymode
              # using bitwarden
              bitwarden
              # using jira
              # org-jira
              ## using source control
              magit
              ## using postgres
              csv-mode
              pg
              pgmacs
              ## writing code
              ### code in general
              copilot
              copilot-chat
              dap-mode
              envrc
              flycheck
              flycheck-posframe
              gptel
              gptel-agent
              lsp-mode
              lsp-ui
              mcp
              ### bdd
              feature-mode
              ### html
              web-mode
              ### markdown
              grip-mode
              ox-gfm
              ### nix
              nix-mode
              ### prolog
              ob-prolog
              sweeprolog
              ### python
              lsp-pyright
              python-pytest
              ## supercollider
              scel
              ######### old
              # quick-peek
              # scrollable-quick-peek
              # transpose-frame
              # window-purpose
              # persp-mode
              # org-ql
              # w3m
              # dired-single
              # treemacs-magit
              # treemacs-persp
            ]);
        }
      );
in
{

  # fonts.fontconfig.enable = true;

  home = {

    file.".dotemacs.org".source = ../config-files/.dotemacs.org;
    file.".emacs".source = ../config-files/.emacs;

    packages = with pkgs; [
      bitwarden-cli
      cacert
      nodejs # for mcp
      source-code-pro
    ];

    stateVersion = "25.11";
  };

  programs = {
    emacs = {
      enable = true;
      package = myEmacs;
    };
  };
}
