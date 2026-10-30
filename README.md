<h1 align="center">My personal workplace</h1>

<p align="center">My accurately-but-uninspiringly-named work environment</p>


# What

My NixOS machines, home-manager config, and a library of devenv toolboxes that other projects import.


## Features

-   A couple computers running NixOS and KDE Plasma
-   A growing set of toolboxes based on devenv
    -   Each toolbox can import others; most import `standard_project`, which brings in emacs, git, glossary, and readme
    -   Toolboxes seed their files into a project's `.toolboxes/` directory, including agent skills under `practices/skills`
    -   Smoke tests for the toolboxes live in `toolboxes/_smoke_tests`
-   Personal config via home-manager:
    -   Extensive emacs config
    -   A Frankenstein's monster of security stuff: yubikey, gpg, bitwarden secrets manager, secretspec
    -   Dropbox integration via Maestral
    -   Cloud gaming via Boosteroid


# Why

-   I want to have things organized how it makes sense to me
-   I want things to be solid, dependable, and reproducible
-   Emacs gives me a way to build a work environment I can operate via a heavily customized set of keybindings, which helps me deal with a muscle issue that limits me


# For Whom

Myself, and anyone who finds something useful in here


# How


## Installation

This is mostly to remind myself how to do this:

bootstrapping from a new nixos install:
as root user, type the following into /etc/nixos/configuration.nix:
<a id="org794077e"></a>

then cd into .ssh,  ssh-keygen -K to get the stub file, rename the stub file to id\_ed25519\_sk, delete the .pub file (assuming this is in github already. making this a public repo probably renders this unnecessary)

nixos rebuild switch

git clone git@github.com:jessenieboer/personal\_workplace

cd personal\_workplace/computers

nixos-generate-config &ndash;show-hardware-config >> hardware/hardware-configuration.nix

combine hardware/hardware-configuration.nix with the appropriate machine nix file in hardware/ (if putting this on hardware you haven't before)

mkpasswd -m sha-512 > /root/secrets/root.hash
mkpasswd -m sha-512 > /root/secrets/username.hash

nixos-rebuild switch &ndash;flake .#configname


## Use

updating (as root in ~/)

cp -r *home/jessenieboer/kingdoms/Household/Jesse/personal\_workplace* .
cp /root/secrets/wifi-passwords.nix /root/personal\_workplace/computers/wifi.nix
nixos-rebuild switch &ndash;flake /root/personal\_workplace/computers#configname

using toolboxes in a project:

-   add the toolboxes you want to the project's `devenv.yaml` imports, e.g. `- /toolboxes/standard_project`
-   run `devenv shell` to seed `.toolboxes/`
-   run `programs/refresh_toolboxes.sh` to update and rebuild every toolbox (`--dry-run` to list them, or pass toolbox names)


### Details

-   Toolbox structure

    directories for programs, settings, templates, and practices

-   AI use

    skills are included in practices/skills in a toolbox; agents should be able to pick them up. my personal suite of agents is in the grok bot toolbox.

-   License

    [MIT](LICENSE)


# By Whom

Myself, with gratitude to basically everyone on the internet who shares info about NixOS, Emacs, and the other technologies in use. I doubt I've seen further than anyone else, but I'm definitely standing on the shoulders of giants.

