{ pkgs, ... }:

{
  # LibreOffice. Also gives Emacs DocView `soffice` (via ~/.nix-profile/bin)
  # to render .docx/.odt/.xlsx/.pptx as pages.
  home.packages = with pkgs; [
    libreoffice
  ];
}
