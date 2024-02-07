#!/bin/bash

# git --version
# git config user.name "GitHub Actions Bot"
# git config user.email "<>"

#Ensure module name is passed into script
module=$1
if [[ -z "$module" ]]; then
    echo "Module not set"
    exit 1
else
    printf "🏗️  Releasing $module...\n\n"
fi

#Get current version of module to be released
current_version_full=`git tag --sort=taggerdate | grep $module | tail -1`
if [[ -z "$current_version_full" ]]; then
    echo "Couldn't find version"
    exit 1
else
    printf "📝  Current version: $current_version_full\n\n"
fi

#Get shortened semvar from current version
regex="([0-9]+.[0-9]+.[0-9]+)"
if [[ $current_version_full =~ $regex ]]; then
    current_version_short=${BASH_REMATCH[1]}
    # echo "Current short version: $current_version_short"
else
  echo "No match found"
  exit 1
fi

#Increment current version
new_version_short=`./scripts/increment-version.sh $current_version_short $2`
# echo "New short version: $new_version_short"

#Construct final version string
new_version_long="$module-v$new_version_short"
printf "✨  New version: $new_version_long\n\n"

#Create and push new git tag
git tag $new_version_long
git push origin --tags