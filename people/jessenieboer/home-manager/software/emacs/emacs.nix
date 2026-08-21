{ config, lib, pkgs, unstable, ... }: {

  home = {
    packages = with pkgs; [
      nerd-fonts.hack
      source-code-pro
    ];
    sessionVariables = {
      EMACS_CONFIG_HOME = "${config.xdg.configHome}/emacs";
    };
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: with epkgs;
    let
      buffer-focus-hook = epkgs.trivialBuild {
        pname = "buffer-focus-hook";
	      version = "0.1";
	      src = pkgs.fetchFromGitHub {
	        owner = "mschuldt";
	        repo = "buffer-focus-hook";
	        rev = "master"; # todo: pin commit
	        hash = "sha256-5JVSzquPQ2Lms9mMn7zbrHa9EjxzM+K34y97pjuyIZ8=";
	      };
	      meta = {
	        description = "Buffer focus hooks for emacs";
	        homepage = "https://github.com/mschuldt/buffer-focus-hook";
	        license = pkgs.lib.licenses.gpl3Plus;
	      };
      };
    in [
      buffer-focus-hook
      consult
      default-text-scale
      dirvish
      eat
      eca
      envrc
      flycheck
      flycheck-posframe
      golden-ratio
      unstable.emacsPackages.gptel
      unstable.emacsPackages.gptel-agent
      htmlize
      lsp-mode
      lsp-pyright
      lsp-ui
      magit
      major-mode-hydra
      marginalia
      markdown-mode
      mcp
      nix-mode
      orderless
      org
      org-tidy
      origami
      popper
      python-pytest
      solarized-theme
      undo-fu
      unstable.emacsPackages.easysession
      vertico
      windswap
    ];
  };

  systemd.user.services.emacs = {
    Unit = {
      Description = "Emacs text editor";
      After = [ "graphical-session.target" "plasma-kwin_wayland.service" ];
      Wants = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.emacs-pgtk}/bin/emacs --fg-daemon";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 4";
      ExecStop = "${pkgs.emacs-pgtk}/bin/emacsclient --eval '(kill-emacs)'";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  xdg.configFile."emacs" = {
    recursive = true;
    source = ./config;
  };

  # todo: desktop entries

  # xdg.desktopEntries.emacsclient = {
    #   #categories = [ "Development" ]; todo categorize stuff
    #   comment = "Edit text";
    #   exec = ''
    #     -c 'if [ -n "\$*" ]; then exec ${emacs}/bin/emacsclient --alternate-editor= --reuse-frame "\$@"; else exec emacsclient --alternate-editor= --create-frame; fi' sh %F
    #   '';
    #   genericName = "Text editor";
    #   icon = "emacs";
    #   name = "Emacs";
    #   startupNotify = true;
    # };

    # xdg.desktopEntries.emacs = {
      #   name = "Emacs (system)";
      #   noDisplay = true;
      # };
}

