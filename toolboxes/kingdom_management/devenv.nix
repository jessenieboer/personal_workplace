{ config, lib, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "kingdom management"}
    '';
  };

  options = {
    kingdom_management_toolbox = {
      project_name = lib.mkOption {
        default = baseNameOf config.devenv.root;
        description = "The name of this project";
        example = "My cool project";
        type = lib.types.strMatching "[^[:space:]]+";
      };

      project_benefit = lib.mkOption {
        default = "";
        description = "The good thing this project is aiming at";
        example = "My cool project";
        type = lib.types.str;
      };

      workers = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.strMatching "[^[:space:]]+";
              description = "Name of worker (one word, no spaces)";
              example = "Jane";
            };

            email = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Email address of the worker (optional)";
              example = "jane.doe@example.com";
            };
          };
        });
        default = [ ];
        description = "List of workers for this project";
        example = [
          { name = "Alice"; email = "alice@example.com"; }
          { name = "Bob"; }
        ];
      };
    };
  };
}
