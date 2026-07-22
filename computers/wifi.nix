# edit locally and create a local copy named something else so you can keep the data when you pull updates
{ config, lib, pkgs, ... }: {

  config.networking.wireless.networks = {
    "wifi name here" = {
      psk = "wifi password here";
    };
  };
}
