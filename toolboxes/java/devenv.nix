{ config, pkgs, lib, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };

  # No Java skills in trailofbits/skills or wshobson/agents (its
  # jvm-languages plugin ships agents only), so the guide stands alone.
  practicesTasks = tt.practices {
    name = "java";
    local = ./practices;
  };
in
{
  config = {
    enterShell = ''
      ${tt.announce "java"}
      if [ -t 1 ]; then
        echo "Java version: $(java -version 2>&1 | sed -n 1p)"
        echo "Maven version: $(mvn --version 2>/dev/null | sed -n 1p)"
        echo "google-java-format version: $(google-java-format --version 2>&1)"
        echo "xmllint version: $(xmllint --version 2>&1 | sed -n 1p)"
      fi
    '';

    env = {
      MAVEN_ARGS = "--no-transfer-progress";
    };

    # JDK 21: the LTS that nixpkgs 26.05 (and unstable) ship as pkgs.jdk,
    # so maven and jdtls built against it come from the binary cache.
    # Bump to pkgs.jdk25 together with maven.compiler.release in pom.xml.
    languages.java = {
      enable = true;
      jdk.package = pkgs.jdk21;
      lsp.enable = true;
      maven.enable = true;
    };

    packages = with pkgs; [
      google-java-format
      libxml2 # xmllint: check pom.xml and other XML
    ];

    tasks = practicesTasks
      // tt.gitSettings "java" ./settings
      // tt.seed {
        name = "java"; task = "copy_pom_template";
        src = ./templates/pom.xml; dest = "pom.xml";
      };
  };
}
