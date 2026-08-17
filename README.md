
# Table of Contents

-   [What](#what)
    -   [Features](#features)
-   [Why](#why)
-   [For Whom](#orgf29fd7d)
-   [How](#how)
    -   [Installation](#installation)
    -   [Use](#org7f133c4)
        -   [Details](#details)
-   [By Whom](#orgbdc30c7)

<h1 align="center">jessenieboer's Personal Workplace</h1>


<a id="what"></a>

# What

My accurately-but-uninspiringly-named work environment


<a id="features"></a>

## Features

-   A couple computers running NixOS and KDE Plasma
-   A growing set of toolboxes based on devenv
-   Personal config via home-manager:
    -   Extensive emacs config
    -   A Frankenstein's monster of security stuff: yubikey, gpg, bitwarden secrets manager, secretspec
    -   Dropbox integration via Maestral
    -   Cloud gaming via Boosteroid


<a id="why"></a>

# Why

-   I want to have things organized how it makes sense to me
-   I want things to be solid, dependable, and reproducible
-   Emacs gives me a way to build a work environment I can operate via a heavily customized set of keybindings, which helps me deal with a muscle issue that limits me


<a id="orgf29fd7d"></a>

# For Whom

Myself, and anyone who finds something useful in here


<a id="how"></a>

# How


<a id="installation"></a>

## Installation

This is mostly to remind myself how to do this:

bootstrapping from a new nixos install:
as root user, type the following into /etc/nixos/configuration.nix:
<a id="org9ad211f"></a>

then cd into .ssh,  ssh-keygen -K to get the stub file, rename the stub file to id<sub>ed25519</sub><sub>sk</sub>, delete the .pub file (assuming this is in github already. making this a public repo probably renders this unnecessary)

nixos rebuild switch

git clone git@github.com:jessenieboer/personal<sub>workplace</sub>

cd personal<sub>workplace</sub>/computers

nixos-generate-config &ndash;show-hardware-config >> hardware/hardware-configuration.nix

combine hardware/hardware-configuration.nix with the appropriate machine nix file in hardware/ (if putting this on hardware you haven't before)

mkpasswd -m sha-512 > /root/secrets/root.hash
mkpasswd -m sha-512 > /root/secrets/username.hash

nixos-rebuild switch &ndash;flake .#configname


<a id="org7f133c4"></a>

## Use

updating (as root in ~/)

cp -r *home/jessenieboer/kingdoms/Household/Jesse/personal<sub>workplace</sub>* .
cp *root/secrets/wifi-passwords.nix /root/personal<sub>workplace</sub>/computers/wifi.nix
nixos-rebuild switch &ndash;flake /root/personal<sub>workplace</sub>/computers*.#configname


<a id="details"></a>

### Details

-   License

    MIT


<a id="orgbdc30c7"></a>

# By Whom

Myself, with gratitude to basically everyone on the internet who shares info about NixOS, Emacs, and the other technologies in use. I doubt I've seen further than anyone else, but I'm definitely standing on the shoulders of giants.

