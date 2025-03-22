#!/bin/bash
set -e
# You can specify extensions to be downloaded via GitHub here. You MUST specify a target folder below as well, or shit will break :)
extensions=( Telshin/Spoilers Pavelovich/WikiBanner wikimedia/mediawiki-extensions-OpenIDConnect wikimedia/mediawiki-extensions-DarkMode edwardspec/mediawiki-aws-s3 ComputerScienceHouse/CSHWikiUserSig )
targets=( Spoilers WikiBanner OpenIDConnect DarkMode AWS CSHUserSig )

for i in "${!extensions[@]}"; do
    extension=${extensions[$i]}
    target=${targets[$i]}
    echo Downloading $extension...
    wget https://github.com/$extension/archive/master.zip
    unzip master.zip
    rm master.zip

    unzipped=${extension#*/}"-master"
    target_dir=/var/www/html/extensions/$target/
    echo Moving $unzipped to $target_dir ...
    mv $unzipped $target_dir
    echo
done
