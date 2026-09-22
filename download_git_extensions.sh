#!/bin/bash
set -e
# You can specify extensions to be downloaded via GitHub here. You MUST specify a target folder below as well, or shit will break :)
extensions=( Telshin/Spoilers Pavelovich/WikiBanner wikimedia/mediawiki-extensions-OpenIDConnect wikimedia/mediawiki-extensions-DarkMode edwardspec/mediawiki-aws-s3 ComputerScienceHouse/wiki-user-sig wikimedia/mediawiki-extensions-PluggableAuth wikimedia/mediawiki-extensions-Elastica wikimedia/mediawiki-extensions-CirrusSearch )
targets=( Spoilers WikiBanner OpenIDConnect DarkMode AWS CSHUserSig PluggableAuth Elastica CirrusSearch )
refs=( master master master master master master master REL1_46 REL1_46 )

for i in "${!extensions[@]}"; do
    extension=${extensions[$i]}
    target=${targets[$i]}
    ref=${refs[$i]}

    echo Downloading $extension...
    wget https://github.com/$extension/archive/$ref.zip
    unzip $ref.zip
    rm $ref.zip

    unzipped=${extension#*/}"-$ref"
    target_dir=/var/www/html/extensions/$target/
    echo Moving $unzipped to $target_dir ...
    mv $unzipped $target_dir
    echo
done
