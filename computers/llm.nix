{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs;
  [
    ollama-vulkan
    vulkan-loader
    vulkan-tools
  ];
  
  services.ollama = {
    enable = true;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "30m";
    };
    loadModels = [ "llama3.2:1b" ];
    package = pkgs.ollama-vulkan;
  };
}
